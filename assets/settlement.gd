extends Panel

func show_settlement(winner):
	if get_parent().player_id == winner:
		$result.text = "YOU WIN"
	else:
		$result.text = "YOU LOSE"
	self.show()

func _on_confirm_toggled(button_pressed):
	if button_pressed:
		Sdk.close_channel(funcref(self, "on_channel_closed"))

func on_channel_closed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://title.tscn")
