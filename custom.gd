extends Node2D

onready var born   = $born_point.position
onready var anchor = $anchor

var width = 1140
var step = 200
var running = false

var cards_pool = [
	"res://assets/cards/card.tscn",
	"res://assets/cards/card.tscn",
	"res://assets/cards/card.tscn",
	"res://assets/cards/card.tscn",
	"res://assets/cards/card.tscn",
	"res://assets/cards/card.tscn"
]

func add_card(card_path):
	cards_pool.push_back(card_path)
	if running == false:
		run()

func next():
	running = false
	run()

func _ready():
# warning-ignore:return_value_discarded
	$Tween.connect("tween_all_completed", self, "next")
	run()

func run():
	if cards_pool.empty():
		return
	var card = load(cards_pool.pop_front()).instance()
	anchor.add_child(card)
	card.get_node("frame").connect("card_spell", self, "card_spelled")
	card.position = born
	sort_out(0.3)
	running = true

func sort_out(interval):
	var step_num = anchor.get_child_count() - 1
	for i in anchor.get_child_count():
		var x = (width - step_num * step) / 2 + i * step
		var card = anchor.get_child(i)
		$Tween.interpolate_property(
			card, "position",
			card.position, Vector2(x, 0), interval,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
	$Tween.start()

func card_spelled(card):
	card.free()
	sort_out(0.15)
