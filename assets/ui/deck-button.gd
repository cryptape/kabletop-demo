extends Sprite

onready var tween = $"/root/controller/Tween"
onready var parent = get_parent()
onready var old_scale = self.scale
onready var new_scale = old_scale * 1.125

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

func _on_click_input_event(_viewport, event, _shape_idx):
	if event.is_pressed() \
			and event.button_index == BUTTON_LEFT:
		parent.click_button(self)
