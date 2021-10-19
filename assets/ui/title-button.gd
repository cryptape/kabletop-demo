extends Node2D

onready var controller = get_node("/root/controller")
onready var tween = controller.get_node("Tween")
onready var origin_modulate = $light_frame.modulate

func _on_mouse_check_mouse_entered():
	tween.interpolate_property(
		$light_frame, "modulate",
		origin_modulate, Color("ffffffff"), 0.1
	)
	tween.start()

func _on_mouse_check_mouse_exited():
	tween.interpolate_property(
		$light_frame, "modulate",
		Color("ffffffff"), origin_modulate, 0.1
	)
	tween.start()

func _on_mouse_check_input_event(_viewport, event, _shape_idx):
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
		controller.click_menu(self)
