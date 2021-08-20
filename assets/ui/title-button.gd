extends Node2D

onready var controller = get_node("/root/controller")
onready var tween = controller.get_node("Tween")

func _on_mouse_check_mouse_entered():
	tween.interpolate_property(
		$light_frame, "modulate",
		Color("00ffffff"), Color("ffffffff"), 0.1
	)
	tween.start()

func _on_mouse_check_mouse_exited():
	tween.interpolate_property(
		$light_frame, "modulate",
		Color("ffffffff"), Color("00ffffff"), 0.1
	)
	tween.start()

func _on_mouse_check_input_event(_viewport, event, _shape_idx):
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
		controller.click_menu(self)
