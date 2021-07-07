extends Control

onready var controller = get_parent()

func _on_sdk_gui_input(event):
	if event.is_pressed():
		controller.add_player_energy(2)
		controller.add_player_hp(5)
		controller.add_opposite_energy(2)
		controller.add_opposite_hp(5)
		controller.add_round(1)
