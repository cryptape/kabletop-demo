extends Control

onready var controller = $"/root/controller"
onready var tween = controller.get_node("Tween")
onready var nickname = $frame/nickname
onready var staking_ckb = $frame/prefix_staking/staking_ckb
onready var bet_ckb = $frame/prefix_bet/bet_ckb

var locked = false
var mouse_in = false
var client_info = null

func lock_toggle():
	if locked:
		locked = false
		if !mouse_in:
			_on_mouse_check_mouse_exited()
	else:
		locked = true
		if !mouse_in:
			_on_mouse_check_mouse_entered()

func set_info(info):
	client_info = info
	nickname.text = info.nickname
	staking_ckb.text = String(info.staking_ckb) + " CKB"
	bet_ckb.text = String(info.bet_ckb) + " CKB"

func _on_mouse_check_mouse_entered():
	mouse_in = true
	controller.enter_client(self)
	if !locked:
		tween.interpolate_property(
			$light_frame, "modulate",
			Color("00ffffff"), Color("ffffffff"), 0.1
		)
		tween.start()

func _on_mouse_check_mouse_exited():
	mouse_in = false
	controller.leave_client(self)
	if !locked:
		tween.interpolate_property(
			$light_frame, "modulate",
			Color("ffffffff"), Color("00ffffff"), 0.1
		)
		tween.start()

func _on_mouse_check_gui_input(event):
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
		controller.choose_client(self)
