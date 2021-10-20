extends Panel

var win = false
var winner = 0

func _ready():
	Sdk.connect("channel_status", self, "_on_sdk_channel_status")

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
	hide()
	if win:
		Wait.set_wait(funcref(self, "on_channel_closed"), null)
		Sdk.close_channel(funcref(Wait, "set_result"))
	else:
		Wait.set_wait(
			funcref(self, "on_channel_closed"), "等待通道关闭交易提交中..."
		)

func _on_sdk_channel_status(status, tx_hash):
	if !status:
		Wait.set_result(true, tx_hash)
