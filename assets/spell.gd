extends Area2D

onready var special = $"../cards/special"
onready var custom = $"../cards/custom"
onready var sdk = $"../sdk"

func _ready():
	sdk.load_lua("./lua/main.lua")
	special.connect("special_card_spelled", self, "on_card_spelled")
	custom.connect("custom_card_spelled", self, "on_card_spelled")
	
func on_card_spelled(card):
	var v = card.attribute
	var code = "card_spelled('%s')" % v.name
	sdk.run_lua(code)

func _on_spell_input_event(viewport, event, shape_idx):
	var ctrl = $"/root/controller"
	if event.is_pressed():
		ctrl.add_player_energy(2)
		ctrl.add_player_hp(10)
		ctrl.damage_player("firebomb")
