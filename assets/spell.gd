extends Area2D

onready var special = $"../cards/special"
onready var custom = $"../cards/custom"
onready var sdk = $"../sdk"
onready var controller = $"/root/controller"

var ROLE = 4
var ID_ONE = 1
var ID_TWO = 2

func _ready():
	special.connect("special_card_spelled", self, "on_special_card_spelled")
	custom.connect("custom_card_spelled", self, "on_custom_card_spelled")

	controller.player_id = ID_ONE
	controller.set_player_role(ID_ONE, ROLE)
	controller.set_player_role(ID_TWO, 2)
	controller.set_player_hp(ID_ONE, 30)
	controller.set_player_hp(ID_TWO, 30)

func init_sdk():
	var cards = [
		"b9aaddf96f7f5c742950611835c040af6b7024ad",
		"b9aaddf96f7f5c742950611835c040af6b7024ad",
		"b9aaddf96f7f5c742950611835c040af6b7024ad",
		"10ad3f5012ce514f409e4da4c011c24a31443488",
		"f37dfa5b009ea001acd3617886d9efecf31bb153",
		"f37dfa5b009ea001acd3617886d9efecf31bb153",
		"10ad3f5012ce514f409e4da4c011c24a31443488",
		"7375f9e28095638cb5761795f3d67fae1837129b",
		"7375f9e28095638cb5761795f3d67fae1837129b",
	]
	sdk.set_entry("./lua/boost.lua")	
	sdk.create_channel("ws://127.0.0.1:11550", cards)
	run("game = Tabletop.new(%d, Role.Cultist, %d)" % [ROLE, ID_ONE])
	run(
		"game:draw_card()\n" +
		"game:draw_card()\n" +
		"game:draw_card()\n" +
		"game:draw_card()\n" +
		"game:draw_card()\n" +
		"game:draw_card()\n"
	)
	
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
	sdk.run(code, false)
	
func switch_round():
	sdk.run("game:switch_round()", true)

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
	print("client disconnect")

func _on_start_button_toggled(button_pressed):
	if button_pressed:
		$start_button.queue_free()
		init_sdk()
