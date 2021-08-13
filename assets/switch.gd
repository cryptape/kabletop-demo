extends Sprite

onready var tween = $Tween
onready var origin_modulate = self.self_modulate
var enable = true
var hover = false

func set_enable(_enable):
	if !_enable and hover:
		_on_click_mouse_exited()
	enable = _enable

func _on_click_mouse_entered():
	if enable:
		tween.interpolate_property(
			self, "scale", self.scale, Vector2(0.48, 0.48), 0.1
		)
		tween.interpolate_property(
			self, "self_modulate", origin_modulate, Color("ffffffff"), 0.1
		)
		tween.start()
		hover = true

func _on_click_mouse_exited():
	if enable:
		tween.interpolate_property(
			self, "scale", self.scale, Vector2(0.4, 0.4), 0.1
		)
		tween.interpolate_property(
			self, "self_modulate", Color("ffffffff"), origin_modulate, 0.1
		)
		tween.start()
		hover = false

func _on_click_input_event(_viewport, event, _shape_idx):
	if event.is_pressed() \
			and event.button_index == BUTTON_LEFT \
			and enable:
		var spell = $"/root/controller/spell"
		spell.switch_round()
