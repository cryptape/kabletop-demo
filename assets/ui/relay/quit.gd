extends Sprite

func _on_click_mouse_entered():
	$text.set("custom_colors/font_color", Color("ffd181"))

func _on_click_mouse_exited():
	$text.set("custom_colors/font_color", Color("ffffff"))

func _on_click_input_event(_viewport, event, _shape_idx):
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
		Sdk.shutdown()
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://title.tscn")
