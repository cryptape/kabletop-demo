extends Node

onready var controller = $"/root/controller"
onready var special_card = $special
onready var custom_cards = $custom/anchor
	
func set_enable(node):
	controller.dragging_card = node
	var nodes = special_card.get_children()
	nodes.append_array(custom_cards.get_children())
	for card in nodes:
		card.apply_enable()

func reset_all():
	var nodes = special_card.get_children()
	nodes.append_array(custom_cards.get_children())
	for card in nodes:
		card.reset()
