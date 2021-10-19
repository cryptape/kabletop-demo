extends Node2D

onready var battleclient  = $background/battleclient
onready var battleserver  = $background/battleserver
onready var deckmanage    = $background/deckmanage
onready var herochoose    = $background/herochoose
onready var ui            = $coverlayer
onready var ui_server     = $coverlayer/server
onready var ui_client     = $coverlayer/client

var connected = false

func _ready():
	var overview = $background/deckmanage/overview
	overview.text = "%d/40" % Sdk.get_nfts_count(0)
	var hero = $background/herochoose/hero
	hero.text = Config.get_hero_name()
	Sdk.set_entry("./lua/boost.lua")
	Sdk.connect("connect_status", self, "_on_sdk_connect_status")
	get_node("/root").call_deferred("move_child", self, 0)
	Config.reset_game_ready()

func click_menu(menu):
	if menu == battleclient:
		ui.show()
		ui_server.hide()
		ui_client.show()
	elif menu == battleserver:
		ui.show()
		ui_server.show()
		ui_client.hide()
	elif menu == deckmanage:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://deck.tscn")
	elif menu == herochoose:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://hero.tscn")
	else:
		assert(false, "bad menu")

func on_channel_opened(ok):
	if ok:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://main.tscn")

func on_shutdown():
	Sdk.shutdown()

func _on_sdk_connect_status(mode, status):
	if mode == "SERVER":
		if status == true:
			Wait.set_manual_cancel("等待通道创建交易提交中...", "连接成功:")
			connected = true
		elif connected:
			Wait.set_manual_cancel(
				"通道创建失败，点击[取消]回到主界面",
				"链接已断开:",
				funcref(Wait, "hide")
			)
			connected = false

func _on_confirm_pressed():
	if Config.player_hero == 0 or Sdk.get_nfts_count(0) == 0:
		ui.hide()
		Wait.set_manual_cancel(
			"请先确保卡牌和英雄都已进行了选择",
			"操作失败:",
			funcref(Wait, "hide")
		)
		return
	if ui_client.visible:
		var nickname = $coverlayer/client/nickname.text
		var staking_ckb = int($coverlayer/client/staking_ckb.text)
		var bet_ckb = int($coverlayer/client/bet_ckb.text)
		var socket = "ws://" + $coverlayer/client/socket.text
		ui.hide()
		Wait.set_wait(null, "服务器连接中...")
		var error = Sdk.connect_to(socket)
		if error != null:
			Wait.set_failed(error, "服务器连接失败:")
			return
		# 连接本地p2p服务器
		if Config.native_mode:
			Wait.set_wait(funcref(self, "on_channel_opened"), null)
			error = Sdk.create_channel(
				staking_ckb, bet_ckb, funcref(Wait, "set_result")
			)
			if error != null:
				Sdk.shutdown()
				Wait.set_failed(error, null)
			else:
				Config.player_name = nickname
		# 连接远程中转服务器
		else:
			Wait.hide()
			Config.player_name = nickname
			Config.player_staking_ckb = staking_ckb
			Config.player_bet_ckb = bet_ckb
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://relay.tscn")
	else:
		var nickname = $coverlayer/server/nickname.text
		var staking_ckb = int($coverlayer/server/staking_ckb.text)
		var bet_ckb = int($coverlayer/server/bet_ckb.text)
		var socket = "0.0.0.0:" + $coverlayer/server/port.text
		ui.hide()
		Wait.set_wait(funcref(self, "on_channel_opened"), "服务器创建中...")
		var error = Sdk.listen_at(
			socket, staking_ckb, bet_ckb, funcref(Wait, "set_result")
		)
		if error != null:
			Wait.set_failed(error, "服务器创建失败:")
		else:
			Wait.set_manual_cancel(
				"连接成功自动进入对战，点击[取消]可关闭服务器",
				"等待客户端连接中...",
				funcref(self, "on_shutdown")
			)
			Config.player_name = nickname

func _on_coverclose_pressed():
	$coverlayer.hide()
