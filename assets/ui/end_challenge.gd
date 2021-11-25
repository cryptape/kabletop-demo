extends Sprite

onready var origin_color = $text.get("custom_colors/font_color")
onready var controller = $"/root/controller"

func _ready():
	self.visible = Config.challenge_mode

func finish_challenge(game_over):
	if !game_over and controller.player_id == controller.acting_player_id:
		Wait.set_manual_cancel(
			"请先结束当前回合再结束挑战", "结束挑战失败：", funcref(Wait, "hide")
		)
		return
	var script_hash = Config.challenge_info.script_hash
	Wait.set_wait(funcref(self, "on_channel_challenged"), "通道挑战中...")
	Sdk.challenge_channel(script_hash, funcref(Wait, "set_result"))

func _on_click_mouse_entered():
	$text.set("custom_colors/font_color", Color("db4d4d"))

func _on_click_mouse_exited():
	$text.set("custom_colors/font_color", origin_color)

func _on_click_input_event(_viewport, event, _shape_idx):
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
		finish_challenge(false)

func on_channel_challenged(_ok):
	if Config.native_mode:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://title.tscn")
	else:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://relay.tscn")
