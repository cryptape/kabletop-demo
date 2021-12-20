extends Control

onready var native_selected = $"native/selected"
onready var relay_selected = $"relay/selected"

func _ready():
	Config.native_mode = native_selected.visible

func _on_native_click_pressed():
	native_selected.show()
	relay_selected.hide()
	Config.native_mode = true

func _on_relay_click_pressed():
	native_selected.hide()
	relay_selected.show()
	Config.native_mode = false
