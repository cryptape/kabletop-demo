use kabletop_godot_util::{
	cache, p2p::{
		server, hook, GodotType
	},
	lua::{
		highlevel::Lua, ffi::lua_Event
	}
};
use lazy_static::*;
use std::{
	convert::TryInto, collections::HashMap, io::{
		stdout, Write, stdin
	}, sync::{
		Mutex, mpsc::sync_channel as channel
	}
};

lazy_static! {
	static ref SERVER: Mutex<Server> = Mutex::new(Server::new("../lua/boost.lua", "0.0.0.0:11550", 2));
}

struct Server {
	player_id:  i64,
	lua:        Option<Lua>,
	entry:      String,
	socket:     String,
	hand_cards: Vec<String>
}

impl Server {
	fn new(path: &str, socket: &str, id: i64) -> Self {
		Server {
			player_id:  id,
			lua:        None,
			entry:      String::from(path),
			socket:     String::from(socket),
			hand_cards: Vec::new()
		}
	}

	fn listen(&self) {
		println!("[SERVER] server listen at {}", self.socket);
		server::listen(self.socket.as_str(), |connected| {
			let mut demo_server = SERVER.lock().unwrap();
			if !connected {
				if let Some(lua) = demo_server.lua.as_ref() {
					lua.close();
				}
				demo_server.lua = None;
				demo_server.discard_cards();
				println!("[SERVER] client disconnected.");
			} else {
				cache::init(cache::PLAYER_TYPE::TWO);
				cache::set_playing_nfts(
					vec![
						"10ad3f5012ce514f409e4da4c011c24a31443488",
						"10ad3f5012ce514f409e4da4c011c24a31443488",
						"10ad3f5012ce514f409e4da4c011c24a31443488",
						"10ad3f5012ce514f409e4da4c011c24a31443488",
						"f37dfa5b009ea001acd3617886d9efecf31bb153",
						"97bff01bcad316a4b534ef221bd66da97018df90",
						"36248218d2808d668ae3c0d35990c12712f6b9d2",
						"36248218d2808d668ae3c0d35990c12712f6b9d2",
						"36248218d2808d668ae3c0d35990c12712f6b9d2"
					]
					.iter()
					.map(|&hash| {
						let mut nft = [0u8; 20];
						let bytes = hex::decode(hash).expect("decode nft");
						nft.copy_from_slice(bytes.as_slice());
						nft
					})
					.collect::<Vec<_>>()
				);
				cache::set_godot_callback(String::from("start_game"), Box::new(|_: String, _: HashMap<String, GodotType>| {
					let mut response = HashMap::new();
					response.insert(String::from("role"), GodotType::I64(1));
					response
				}));
				println!("[SERVER] client connected.");
			}
		})
	}

	fn get_id(&self) -> i64 {
		self.player_id
	}

	fn get_cards(&self) -> &Vec<String> {
		&self.hand_cards
	}

	fn discard_cards(&mut self) {
		self.hand_cards = vec![];
	}

	fn add_card(&mut self, nft: String) {
		self.hand_cards.push(nft);
	}

	fn use_card(&mut self, offset: usize) -> bool {
		if offset < self.hand_cards.len() + 1 {
			self.hand_cards.remove(offset - 1);
			self.run_code(format!("game:spell_card({})", offset), true);
			true
		} else {
			false
		}
	}

	fn run_code(&mut self, code: String, sync: bool) {
		self
			.lua
			.as_ref()
			.expect("no client connected")
			.run(code.clone())
			.iter()
			.for_each(|event| {
				println!("[SERVER] [EVENT] {:?}", event);
				if let lua_Event::String(name) = &event[0] {
					if name == &String::from("draw") {
						if let lua_Event::Number(value) = &event[1] {
							if value == &self.get_id() {
								if let lua_Event::String(nft) = &event[2] {
									self.add_card(nft.clone())
								}
							}
						}
					}
				}
			});
		if sync {
			server::sync_operation(code).unwrap();
		}
	}
}

fn from_nfts(value: Vec<[u8; 20]>) -> Vec<String> {
	value
		.iter()
		.map(|v| hex::encode(v))
		.collect::<_>()
}

fn run_code(code: String, sync: bool) {
	SERVER
		.lock()
		.unwrap()
		.run_code(code, sync)
}

fn randomseed(seed: &[u8]) {
	let seed = {
		assert!(seed.len() >= 16);
		&seed[..16]
	};
	let seed_1 = i64::from_le_bytes(seed[..8].try_into().unwrap());
	let seed_2 = i64::from_le_bytes(seed[8..].try_into().unwrap());
	run_code(format!("math.randomseed({}, {})", seed_1, seed_2), false);
}

fn check_disconnected() -> bool {
	SERVER
		.lock()
		.unwrap()
		.lua
		.is_none()
}

fn main() {
	let (sender, receiver) = channel(1);

	hook::add("open_kabletop_channel", |hash| {
		println!("[SERVER] receive open_kabletop_channel");
		{
			let mut demo_server = SERVER.lock().unwrap();
			assert!(demo_server.lua.is_none());
			let channel = cache::get_clone();
			let mut ckb_time: i64 = 0;
			for i in 0..8 {
				ckb_time = (ckb_time << 8) | (channel.script_hash[i] as i64 >> 1);
			}
			let mut ckb_clock: i64 = 0;
			for i in 8..16 {
				ckb_clock = (ckb_clock << 8) | (channel.script_hash[i] as i64 >> 1);
			}
			let lua = Lua::new(ckb_time, ckb_clock);
			lua.inject_nfts(from_nfts(channel.opponent_nfts.clone()), from_nfts(channel.user_nfts.clone()));
			lua.boost(demo_server.entry.clone());
			demo_server.lua = Some(lua);
		}
		randomseed(hash);
	});

	hook::add("sync_operation", |operation| {
		let operation = String::from_utf8(operation.clone()).unwrap();
		println!("[SERVER] receive sync_operation => {}", operation.replace("\n", "\\n"));
		run_code(operation, false);
	});

	hook::add("switch_round", move |signature| {
		println!("[SERVER] receive switch_round");
		randomseed(signature);
		if cache::get_clone().round == 2 {
			run_code(String::from("game:draw_card(6)"), true);
		}
		sender.send(1).unwrap();
	});

	SERVER
		.lock()
		.unwrap()
		.listen();

	loop {
		println!("[SERVER] waiting server playing turn...");
		receiver.recv().unwrap();

		loop {
			println!("1: show cards  2: spell card  3: switch round  4: exit");
			print!(">> ");
			stdout().flush().unwrap();
			let mut command = String::new();
			stdin().read_line(&mut command).unwrap();
			if check_disconnected() {
				break
			}
			match command[..1].parse() {
				Ok(1) => {
					println!("{:?}", SERVER.lock().unwrap().get_cards());
				},
				Ok(2) => loop {
					print!("insert card offset: ");
					stdout().flush().unwrap();
					let mut choose = String::new();
					stdin().read_line(&mut choose).unwrap();
					if check_disconnected() {
						break
					}
					if let Ok(offset) = choose[..1].parse::<usize>() {
						SERVER.lock().unwrap().use_card(offset);
					} else {
						break
					}
				},
				Ok(3) => {
					run_code(String::from("game:switch_round()"), true);
					let signature = server::switch_round().unwrap();
					randomseed(&signature);
					println!("[SERVER] move round to {}", cache::get_clone().round);
					break
				},
				Ok(4) => return,
				_ => print!("bad command {}, just skip", command)
			}
			if check_disconnected() {
				break
			}
		}
	}
}
