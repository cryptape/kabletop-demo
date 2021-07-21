extends Node2D

onready var tween = $"../Tween"
onready var parent = get_parent()

signal special_card_spelled

func set_role_card(role):
	if self.get_child_count() > 0:
		self.get_child(0).free()
	var native_card = parent.get_native_card(role)
	var card = load("res://assets/cards/special.tscn").instance()
	card.set_info(native_card)
	card.connect("card_spell", self, "card_spelled")
	self.add_child(card)
	
func card_spelled(card):
	card.reset()
	card.scale = Vector2(1.4, 1.4)
	card.modulate = Color("00ffffff")
	tween.interpolate_property(
		card, "scale", card.scale, Vector2.ONE, 0.3
	)
	tween.interpolate_property(
		card, "modulate", card.modulate, Color("ffffffff"), 0.3
	)
	tween.start()
	var energy = get_node("/root/controller/panel/player_energy")
	if energy.try_cost_energy(card.info.cost):
		emit_signal("special_card_spelled", card)
	else:
		# 弹出错误提示
		pass
