extends Panel

var win = false
var winner = 0

func show_settlement(player_id):
	if player_id == winner:
		win = true
		$result.text = "YOU WIN"
	else:
		win = false
		$result.text = "YOU LOSE"
	self.show()

func on_channel_closed(_ok):
	if Config.native_mode:
		Sdk.shutdown()
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://title.tscn")
	else:
		Sdk.disconnect_client_via_replay()
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://relay.tscn")

func _on_confirm_pressed():
	if win:
		hide()
		Wait.set_wait(funcref(self, "on_channel_closed"), null)
		Sdk.close_channel(funcref(Wait, "set_result"))
	else:
		on_channel_closed(null)
