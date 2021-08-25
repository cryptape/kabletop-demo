extends Area2D

onready var special = $"../cards/special"
onready var custom = $"../cards/custom"
onready var controller = $"/root/controller"

var ID_ONE = 1
var ID_TWO = 2
var FIRSTHAND = false
var LUA_QUEUE = []

func _ready():
	special.connect("special_card_spelled", self, "on_special_card_spelled")
	custom.connect("custom_card_spelled", self, "on_custom_card_spelled")
	Sdk.connect("disconnect", self, "_on_sdk_disconnect")
	Sdk.connect("lua_events", self, "_on_sdk_lua_events")
	Sdk.connect("p2p_message_reply", self, "_on_sdk_p2p_message_reply")
	
	controller.player_id = ID_ONE
	controller.set_player_role(ID_ONE, Config.player_hero)
	controller.set_player_hp(ID_ONE, 30)
	controller.set_player_hp(ID_TWO, 30)
	Sdk.send_p2p_message("start_game", {
		"role": Config.player_hero
	})
	FIRSTHAND = Sdk.is_firsthand()
	
func _process(_delta):
	if !LUA_QUEUE.empty():
		for status in LUA_QUEUE:
			Sdk.run(status.code, status.close_round)
		LUA_QUEUE = []
	
func on_special_card_spelled(_card):
	assert(controller.acting_player_id == controller.player_id)
	run("game:spell_card(0)")

func on_custom_card_spelled(card):
	assert(controller.acting_player_id == controller.player_id)
	var offset = 0
	for child in card.get_parent().get_children():
		offset += 1
		if child == card:
			break
	run("game:spell_card(%d)" % offset)

func run(code):
	LUA_QUEUE.push_back({
		code = code,
		close_round = false
	})
	
func switch_round():
	LUA_QUEUE.push_back({
		code = "game:switch_round()",
		close_round = true
	})

func _on_sdk_lua_events(events):
	for params in events:
		print(params)
		var event = params[0]
		var player_id = params[1]
		match event:
			"draw":
				var card_hash = params[2]
				controller.add_player_card(player_id, card_hash)
			"damage":
				var hp = params[2]
				var effect = params[3]
				controller.set_player_hp(player_id, hp, true)
				controller.damage_player(player_id, effect, true)
			"heal":
				var hp = params[2]
				controller.set_player_hp(player_id, hp, true)
				controller.heal_player(player_id, true)
			"empower", "cost":
				var energy = params[2]
				controller.set_player_energy(player_id, energy, true)
			"strip":
				var buffs = params[2]
				print("strip buffs = ", buffs)
			"buff":
				var id = params[2]
				var offset = params[3]
				var life = params[4]
				if offset <= 0:
					controller.add_player_buff(player_id, id, life, true)
				else:
					controller.update_player_buff(player_id, offset - 1, life)
			"spell_end":
				var card_offset = params[2] - 1
				var hash_code = params[3]
				controller.apply_change(player_id, card_offset, hash_code)
			"new_round":
				var current_round = params[2]
				controller.set_acting_player(player_id)
				controller.set_round(current_round)
			_:
				print("unknown event " + event)

func _on_sdk_disconnect():
	assert(false, "server disconnected")
	
func _on_sdk_p2p_message_reply(message, parameters):
	match message:
		"start_game":
			Config.opposite_hero = parameters["role"]
			assert(Config.opposite_hero > 0)
			controller.set_player_role(ID_TWO, Config.opposite_hero)
			if FIRSTHAND:
				run("game = Tabletop.new(%d, %d, %d)" % [
					Config.player_hero, Config.opposite_hero, ID_ONE
				])
				run("game:draw_card(6)")
