extends Area2D

onready var special = $"../cards/special"
onready var custom = $"../cards/custom"
onready var sdk = $"../sdk"
onready var controller = get_node("/root/controller")

var ROLE = 4
var ID_ONE = 1
var ID_TWO = 2

func _ready():
	special.connect("special_card_spelled", self, "on_special_card_spelled")
	custom.connect("custom_card_spelled", self, "on_custom_card_spelled")

	controller.set_player_role(ID_ONE, ROLE)
	controller.set_player_hp(ID_ONE, 30)
	controller.set_player_hp(ID_TWO, 30)
	
	var cards = [
		"b9aaddf96f7f5c742950611835c040af6b7024ad",
		"b9aaddf96f7f5c742950611835c040af6b7024ad",
		"b9aaddf96f7f5c742950611835c040af6b7024ad",
		"b9aaddf96f7f5c742950611835c040af6b7024ad",
		"f37dfa5b009ea001acd3617886d9efecf31bb153",
		"f37dfa5b009ea001acd3617886d9efecf31bb153",
		"97bff01bcad316a4b534ef221bd66da97018df90",
		"7375f9e28095638cb5761795f3d67fae1837129b",
		"7375f9e28095638cb5761795f3d67fae1837129b",
	]
	init_sdk(cards, cards)

func init_sdk(nfts_1, nfts_2):
	sdk.preload_nfts(nfts_1, nfts_2)
	sdk.boost("./lua/boost.lua")
	run("math.randomseed(0, 0)")
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
	run("game:spell_card(0)")

func on_custom_card_spelled(card):
	var offset = 0
	for child in card.get_parent().get_children():
		offset += 1
		if child == card:
			break
	run("game:spell_card(%d)" % offset)

func run(code):
	var events = sdk.run(code)
	for params in events:
		print(params)
		var event = params[0]
		var player_id = params[1]
		match event:
			"draw":
				var card_hash = params[2]
				controller.add_player_card(player_id, card_hash)
			"damage", "heal":
				var hp = params[2]
				var effect = params[3]
				controller.set_player_hp(player_id, hp)
				controller.damage_player(player_id, effect)
			"empower", "cost":
				var energy = params[2]
				controller.set_player_energy(player_id, energy)
			_:
				print("unknown event " + event)
