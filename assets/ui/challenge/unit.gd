extends Control

onready var controller = $"/root/controller"
onready var tween = controller.get_node("Tween")

onready var user1_pkhash = $anchor/player1_args
onready var user1_deck = $anchor/player1_args/deck
onready var user1_decksize = $anchor/player1_args/deck/number
onready var user1_challenge = $anchor/player1_args/challenge
onready var user2_pkhash = $anchor/player2_args
onready var user2_deck = $anchor/player2_args/deck
onready var user2_decksize = $anchor/player2_args/deck/number
onready var user2_challenge = $anchor/player2_args/challenge
onready var staking_ckb = $anchor/staking_ckb/number
onready var bet_ckb = $anchor/bet_ckb/number
onready var round_count = $anchor/round/number
onready var remain_block = $anchor/remain_block/number

var locked = false
var enable = true
var mouse_in = false
var info = null
var close_enable = false
var frame_color = "ffffff"

func set_info(unit):
	info = unit
	user1_pkhash.text = "Player1 (%s...):" % unit.user1_pkhash.substr(0, 8)
	user1_decksize.text = String(unit.user1_nfts.size())
	user2_pkhash.text = "Player2 (%s...):" % unit.user2_pkhash.substr(0, 8)
	user2_decksize.text = String(unit.user2_nfts.size())
	staking_ckb.text = "%d CKB" % unit.staking_ckb
	bet_ckb.text = "%d CKB" % unit.bet_ckb
	round_count.text = String(unit.round_count)
	user1_challenge.visible = unit.challenger == 1
	user2_challenge.visible = unit.challenger == 2
	if unit.challenger == 0:
		remain_block.text = "N/A"
	else:
		remain_block.text = String(unit.block_countdown)
		if unit.challenger == unit.user_type:
			if unit.block_countdown == 0:
				enable = true
				close_enable = true
				frame_color = "64dc43"
			else:
				enable = false
			
	if unit.user_type == 1:
		user1_pkhash.set("custom_colors/font_color", Color("8aba68"))
		user1_deck.set("custom_colors/font_color", Color("8aba68"))
		user1_decksize.set("custom_colors/font_color", Color("8aba68"))
	else:
		user2_pkhash.set("custom_colors/font_color", Color("8aba68"))
		user2_deck.set("custom_colors/font_color", Color("8aba68"))
		user2_decksize.set("custom_colors/font_color", Color("8aba68"))

func lock_toggle():
	if !enable:
		return
	if locked:
		locked = false
		if !mouse_in:
			_on_mouse_check_mouse_exited()
	else:
		locked = true
		if !mouse_in:
			_on_mouse_check_mouse_entered()
	
func _on_mouse_check_mouse_entered():
	if !enable:
		return
	mouse_in = true
	if !locked:
		tween.interpolate_property(
			$light_frame, "modulate",
			Color("00ffffff"), Color("ff" + frame_color), 0.1
		)
		tween.start()

func _on_mouse_check_mouse_exited():
	if !enable:
		return
	mouse_in = false
	if !locked:
		tween.interpolate_property(
			$light_frame, "modulate",
			Color("ff" + frame_color), Color("00ffffff"), 0.1
		)
		tween.start()

func _on_mouse_check_gui_input(event):
	if enable and event.is_pressed() and event.button_index == BUTTON_LEFT:
		controller.choose_unit(self)
