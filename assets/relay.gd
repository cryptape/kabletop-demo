extends Node2D

onready var connect_menu = $menus/connect
onready var register_menu = $menus/register

func _ready():
	Sdk.connect("connect_status", self, "_on_connect_status")
	Sdk.connect("channel_status", self, "_on_channel_status")
	get_node("/root").call_deferred("move_child", self, 0)
	Config.reset_vars()

func click_menu(menu):
	match menu:
		connect_menu:
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://hall.tscn")
		register_menu:
			Wait.set_wait(
				funcref(self, "on_channel_opened"), "向中转服务器注册中..."
			)
			var error = Sdk.register_relay(
				Config.player_name,
				Config.player_staking_ckb,
				Config.player_bet_ckb
			)
			if error != null:
				Wait.set_manual_confirm(
					error, "注册失败：", funcref(self, "on_return")
				)
			else:
				Wait.set_manual_cancel(
					"连接成功自动进入对战，点击[取消]可返回中转服务器",
					"等待客户端连接中...",
					funcref(self, "on_unregister")
				)

func on_return(_ok = true):
	Sdk.shutdown()
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://title.tscn")

func on_unregister():
	var error = Sdk.unregister_relay()
	if error != null:
		Wait.set_manual_cancel(
			error, "取消注册失败：", funcref(Wait, "hide")
		)
	else:
		Wait.hide()

func on_channel_opened(ok):
	if ok:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://main.tscn")

func _on_connect_status(mode, status):
	if mode == "CLIENT" and status == false:
		Wait.set_manual_cancel(
			"与中转服务器断开连接，点击[取消]按钮回到主界面",
			"网络连接错误:",
			funcref(self, "on_return")
		)
	elif mode == "PARTNER":
		if status:
			Wait.set_manual_cancel("等待通道创建交易提交中...", "连接成功:")
		elif Wait.visible:
			Wait.set_manual_cancel(
				"对手客户端已断开连接", "连接失败:", funcref(Wait, "hide")
			)

func _on_channel_status(status, tx_hash):
	Wait.set_result(status, tx_hash)
