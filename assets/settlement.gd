extends Panel

onready var end_challenge = get_node("../challenge")

var win = false
var winner = 0
var manual = false
var channel_closed_hash = null

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
		if !Config.challenge_mode:
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
		if Config.challenge_mode and manual:
			end_challenge.finish_challenge(true)
		else:
			Wait.set_wait(funcref(self, "on_channel_closed"), "通道关闭中...")
			Sdk.close_channel(Config.challenge_mode, funcref(Wait, "set_result"))
	else:
		if Config.challenge_mode:
			if Config.challenge_info.operations.empty():
				on_channel_closed(true)
			else:
				Wait.set_wait(
					funcref(self, "on_channel_closed"), "通道关闭中..."
				)
				Sdk.close_channel(true, funcref(Wait, "set_result"))
		else:
			if channel_closed_hash != null:
				Wait.set_manual_confirm(
					channel_closed_hash,
					null,
					funcref(self, "on_channel_closed")
				)
			else:
				Wait.set_wait(
					funcref(self, "on_channel_closed"), "等待通道关闭中..."
				)

func _on_sdk_channel_status(status, tx_hash):
	if !status:
		if Wait.visible:
			Wait.set_result(true, tx_hash)
		else:
			channel_closed_hash = tx_hash
