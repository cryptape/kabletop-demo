use kabletop_godot_util::{
	cache, ckb::{
		server, hook
	},
	lua::{
		highlevel::Lua, ffi::lua_Event
	}
};
use lazy_static::*;
use std::sync::{
	Mutex, mpsc::sync_channel as channel
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
				demo_server.lua.as_ref().unwrap().close();
				demo_server.lua = None;
				println!("[SERVER] client disconnected.");
			} else {
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

	fn add_card(&mut self, nft: String) {
		self.hand_cards.push(nft);
	}

	fn use_card(&mut self, offset: usize) -> bool {
		if offset < self.hand_cards.len() + 1 {
			self.hand_cards.remove(offset - 1);
			run_code(format!("game:spell_card({})", offset));
			true
		} else {
			false
		}
	}
}

fn from_nfts(value: Vec<[u8; 20]>) -> Vec<String> {
	value
		.iter()
		.map(|v| hex::encode(v))
		.collect::<_>()
}

fn run_code(code: String) {
	let mut server = SERVER.lock().unwrap();
	server
		.lua
		.as_ref()
		.expect("no client connected")
		.run(code)
		.iter()
		.for_each(|event| {
			println!("[SERVER] [EVENT] {:?}", event);
			if let lua_Event::String(name) = &event[0] {
				if name == &String::from("draw") {
					if let lua_Event::Number(value) = &event[1] {
						if value == &server.get_id() {
							if let lua_Event::String(nft) = &event[2] {
								server.add_card(nft.clone())
							}
						}
					}
				}
			}
		});
}

fn main() {
	let (sender, receiver) = channel(1);

	hook::add("open_kabletop_channel", |_| {
		println!("[SERVER] receive open_kabletop_channel");
		let mut demo_server = SERVER.lock().unwrap();
		assert!(demo_server.lua.is_none());
		let clone = cache::get_clone();
		let mut ckb_time: i64 = 0;
		for i in 0..8 {
			ckb_time = (ckb_time << 8) | (clone.script_hash[i] as i64 >> 1);
		}
		let mut ckb_clock: i64 = 0;
		for i in 8..16 {
			ckb_clock = (ckb_clock << 8) | (clone.script_hash[i] as i64 >> 1);
		}
		let lua = Lua::new(ckb_time, ckb_clock);
		lua.inject_nfts(from_nfts(clone.user_nfts), from_nfts(clone.opponent_nfts));
		lua.boost(demo_server.entry.clone());
		demo_server.lua = Some(lua);
	});

	hook::add("sync_operation", |operation| {
		let operation = String::from_utf8(operation.clone()).unwrap();
		println!("[SERVER] receive sync_operation => {}", operation.replace("\n", "\\n"));
		run_code(operation);
	});

	hook::add("switch_round", move |round| {
		println!("[SERVER] receive switch_round");
		if round[0] == 1 {
			run_code(
				String::from("game:draw()\n") +
				"game:draw()\n" +
				"game:draw()\n" +
				"game:draw()\n" +
				"game:draw()\n" +
				"game:draw()\n"
			);
		}
		sender.send(1).unwrap();
	});

	cache::init(cache::PLAYER_TYPE::TWO);
	cache::set_playing_nfts(
		vec![
			"b9aaddf96f7f5c742950611835c040af6b7024ad",
			"b9aaddf96f7f5c742950611835c040af6b7024ad",
			"b9aaddf96f7f5c742950611835c040af6b7024ad",
			"b9aaddf96f7f5c742950611835c040af6b7024ad",
			"f37dfa5b009ea001acd3617886d9efecf31bb153",
			"f37dfa5b009ea001acd3617886d9efecf31bb153",
			"97bff01bcad316a4b534ef221bd66da97018df90",
			"7375f9e28095638cb5761795f3d67fae1837129b",
			"7375f9e28095638cb5761795f3d67fae1837129b"
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

	SERVER
		.lock()
		.unwrap()
		.listen();

	loop {
		receiver.recv().unwrap();

		loop {
			println!("1: show cards\n2: spell card\n3: switch round\n4: exit");
			print!(">> ");
			let mut command = String::new();
			std::io::stdin().read_line(&mut command).unwrap();

			match command.as_str() {
				"1" => {
					println!("{:?}", SERVER.lock().unwrap().get_cards());
				},
				"2" => loop {
					println!("0: exit\nx: card offset");
					print!("<< ");
					std::io::stdin().read_line(&mut command).unwrap();
					if let Ok(offset) = command.parse::<usize>() {
						if SERVER.lock().unwrap().use_card(offset) {
							break
						}
					}
				},
				"3" => {
					run_code(String::from("kabletop:switch_round()"));
					let round = server::switch_round();
					println!("[SERVER] move round to {}", round);
				},
				"4" => return,
				_   => break
			}
		}
	}
}
