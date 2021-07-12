extends Area2D

onready var controller = self.get_parent()

func _on_sdk_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		controller.add_player_hp(10)
		controller.add_opposite_hp(10)
		controller.add_player_energy(2)
		controller.add_opposite_energy(2)
		controller.damage_player("bomb")
		controller.damage_opposite("deathfire")
