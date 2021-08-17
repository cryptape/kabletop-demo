extends Sprite

onready var tween = get_node("../Tween")
onready var controller = get_parent()

func _on_click_mouse_entered():
	tween.interpolate_property(
		self, "scale", self.scale, Vector2(1.35, 1.35), 0.1
	)
	tween.start()

func _on_click_mouse_exited():
	tween.interpolate_property(
		self, "scale", self.scale, Vector2(1.2, 1.2), 0.1
	)
	tween.start()

func _on_click_input_event(_viewport, event, _shape_idx):
	if event.is_pressed() \
			and event.button_index == BUTTON_LEFT:
		controller.click_button(self)
