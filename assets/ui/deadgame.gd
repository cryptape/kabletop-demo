extends Sprite

func _on_challenge_input_event(_viewport, event, _shape_idx):
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://challenge.tscn")

func _on_challenge_mouse_entered():
	$name.set("custom_colors/font_color", Color("c8d855"))

func _on_challenge_mouse_exited():
	$name.set("custom_colors/font_color", Color("ffffff"))
