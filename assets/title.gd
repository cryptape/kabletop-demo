extends Node2D

onready var battleclient  = $background/battleclient
onready var battleserver  = $background/battleserver
onready var deckmanage    = $background/deckmanage
onready var herochoose    = $background/herochoose
onready var ui            = $coverlayer
onready var ui_server     = $coverlayer/server
onready var ui_client     = $coverlayer/client

func _ready():
	var overview = $background/deckmanage/overview
	var nfts = Sdk.get_nfts()
	var total = 0
	for i in nfts:
		total += nfts[i]
	overview.text = "%d/40" % total
	var hero = $background/herochoose/hero
	hero.text = Config.get_hero_name()
	Sdk.set_entry("./lua/boost.lua")
	get_node("/root").call_deferred("move_child", self, 0)

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

func _on_confirm_pressed():
	if ui_client.visible:
		var socket = "ws://" + $coverlayer/client/socket.text
		ui.hide()
		Wait.set_wait(null, "服务器连接中...")
		var error = Sdk.connect_to(socket)
		if error != null:
			Wait.set_failed(error, "服务器连接失败:")
			return
		Wait.set_wait(funcref(self, "on_channel_opened"), null)
		error = Sdk.create_channel(funcref(Wait, "set_result"))
		if error != null:
			Wait.set_failed(error, null)
	else:
		var socket = "0.0.0.0:" + $coverlayer/server/port.text
		ui.hide()
		Wait.set_wait(funcref(self, "on_channel_opened"), "服务器创建中...")
		var error = Sdk.listen_at(
			socket, Config.player_hero, funcref(Wait, "set_result")
		)
		if error != null:
			Wait.set_failed(error, "服务器创建失败:")
		else:
			Wait.set_manual_cancel(
				"连接成功自动进入对战，点击[确定]可关闭服务器",
				"等待客户端连接中...",
				funcref(self, "on_shutdown")
			)
