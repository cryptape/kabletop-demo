extends Node2D

onready var born   = $born_point.position
onready var anchor = $anchor
onready var tween  = $"../Tween"
onready var controller = $"/root/controller"

var width = 1140
var step = 200
var running = false

signal custom_card_spelled

var cards_pool = []
var cards_drop = []

func add_card(card_hash):
	var meta = Config.get_card(card_hash)
	cards_pool.push_back(meta)
	if running == false:
		run()
		
func del_card(offset, card_hash):
	if offset < anchor.get_child_count():
		var _hash = anchor.get_child(offset).info._hash
		assert(_hash == card_hash, "bad hash %s != %s" % [_hash, card_hash])
		cards_drop.push_back(offset)
		if running == false:
			run()

func next():
	tween.disconnect("tween_all_completed", self, "next")
	for card in anchor.get_children():
		card.update_origin_global_position()
	running = false
	run()
	
func drop_done():
	tween.disconnect("tween_completed", self, "drop_done")
	sort_out(0.15)

func run():
	if !cards_pool.empty():
		var card = load("res://assets/cards/card.tscn").instance()
		card.set_info(cards_pool.pop_front())
		card.connect("card_spell", self, "card_spelled")
		card.position = born
		anchor.add_child(card)
		card.apply_enable()
		sort_out(0.3)
		running = true
		controller.short_deck(controller.player_id, 1)
	if !cards_drop.empty():
		var card = anchor.get_child(cards_drop.pop_front())
		tween.interpolate_property(
			card, "position",
			card.position, card.position + Vector2(0, 50), 0.2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		tween.connect("tween_completed", self, "drop_done")
		tween.start()
		running = true

func sort_out(interval):
	var valid_children = []
	for node in anchor.get_children():
		if !node.is_queued_for_deletion():
			valid_children.push_back(node)
	var step_num = valid_children.size() - 1
	for i in valid_children.size():
		var x = (width - step_num * step) / 2 + i * step
		var card = valid_children[i]
		tween.interpolate_property(
			card, "position",
			card.position, Vector2(x, 0), interval,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
# warning-ignore:return_value_discarded
	tween.connect("tween_all_completed", self, "next")
	tween.start()

func card_spelled(card):
	var energy = get_node("/root/controller/panel/player_energy")
	if controller.acting_player_id == controller.player_id \
			and energy.try_cost_energy(card.info.cost):
		card.queue_free()
		sort_out(0.15)
		emit_event(card)
	else:
		card.reset()
		card.scale = Vector2(1.4, 1.4)
		card.modulate = Color("00ffffff")
		tween.interpolate_property(
			card, "scale", card.scale, Vector2.ONE, 0.3
		)
		tween.interpolate_property(
			card, "modulate", card.modulate, Color("ffffffff"), 0.3
		)
		tween.start()
		
func emit_event(card):
	emit_signal("custom_card_spelled", card)
