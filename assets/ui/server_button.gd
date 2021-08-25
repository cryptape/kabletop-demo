extends Sprite

onready var controller = get_node("/root/controller")
onready var tween = controller.get_node("Tween")
onready var old_scale = self.scale
onready var new_scale = self.scale * 1.05

func _on_click_input_event(_viewport, event, _shape_idx):
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
		controller.stop_server()
		self.hide()

func _on_click_mouse_entered():
	tween.interpolate_property(
		self, "scale", old_scale, new_scale, 0.1
	)
	tween.start()

func _on_click_mouse_exited():
	tween.interpolate_property(
		self, "scale", new_scale, old_scale, 0.1
	)
	tween.start()
