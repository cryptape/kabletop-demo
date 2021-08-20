extends Node2D

onready var battleclient = $background/battleclient
onready var battleserver = $background/battleserver
onready var deckmanage   = $background/deckmanage
onready var statistic    = $background/statistic

func click_menu(menu):
	if menu == battleclient:
		print("click battleclient")
	elif menu == battleserver:
		print("click battleserver")
	elif menu == deckmanage:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://deck.tscn")
	else:
		print("click statistic")
