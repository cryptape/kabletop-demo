extends Sprite

onready var tween = $Tween
onready var origin_modulate = self.self_modulate
var enable = true

func set_enable(_enable):
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

func _on_click_mouse_exited():
	if enable:
		tween.interpolate_property(
			self, "scale", self.scale, Vector2(0.4, 0.4), 0.1
		)
		tween.interpolate_property(
			self, "self_modulate", Color("ffffffff"), origin_modulate, 0.1
		)
		tween.start()

func _on_click_input_event(_viewport, event, _shape_idx):
	if event.is_pressed() and enable:
		var ctrl = $"/root/controller"
		if event.button_index == BUTTON_LEFT:
			var spell = ctrl.get_node("spell")
			spell.run(
				"game:switch_round()" +
				"game:draw_card()\n" +
				"game:draw_card()\n" +
				"game:draw_card()\n" +
				"game:draw_card()\n" +
				"game:draw_card()\n" +
				"game:draw_card()\n" +
				"game:spell_card(3)" +
				"game:spell_card(3)" +
				"game:spell_card(1)"
			)
		else:
			ctrl.spell_tiny(0, "7375f9e28095638cb5761795f3d67fae1837129b")
