extends Node2D

onready var battleclient  = $background/battleclient
onready var battleserver  = $background/battleserver
onready var deckmanage    = $background/deckmanage
onready var herochoose    = $background/herochoose
onready var ui            = $coverlayer
onready var ui_server     = $coverlayer/server
onready var ui_client     = $coverlayer/client
onready var server_cancel = $background/battleserver/cancel

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

func stop_server():
	pass

func _on_confirm_toggled(button_pressed):
	assert(ui.visible == true)
	if button_pressed:
		if ui_client.visible:
			var socket = "ws://" + $coverlayer/client/socket.text
			if !Sdk.create_channel(socket, funcref(self, "on_channel_opened")):
				print("channel creation failed")
				# 弹出提示
		else:
			var socket = "ws://0.0.0.0:" + $coverlayer/server/port.text
			print("listen at ", socket)
			server_cancel.show()
			server_cancel.get_node("serverinfo").text = socket

func on_channel_opened():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://main.tscn")
