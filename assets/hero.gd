extends Node2D

var dragging_card = self

func _ready():
	var heros = [2, 4, 1, 3]
	var specials = $background/special_cards
	for i in specials.get_child_count():
		var hero = heros[i]
		var card_info = Config.NativeNFTs[hero]
		specials.get_child(i).set_info(card_info)

func get_back():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://title.tscn")

func _on_ironclad_toggled(button_pressed):
	if button_pressed:
		Config.player_hero = 2
		get_back()

func _on_silent_toggled(button_pressed):
	if button_pressed:
		Config.player_hero = 4
		get_back()

func _on_cultist_toggled(button_pressed):
	if button_pressed:
		Config.player_hero = 1
		get_back()

func _on_chosen_toggled(button_pressed):
	if button_pressed:
		Config.player_hero = 3
		get_back()
