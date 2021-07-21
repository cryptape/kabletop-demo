extends Node2D

onready var born   = $born_point.position
onready var anchor = $anchor
onready var tween  = $"../Tween"

var width = 1140
var step = 200
var running = false

signal custom_card_spelled

class Card:
	var icon = 0
	var name = ""
	var cost = 0
	var description = ""
	static func generate(icon, name, cost, desc):
		var new_card = Card.new()
		new_card.icon = icon
		new_card.name = name
		new_card.cost = cost
		new_card.description = desc
		return new_card
	

var cards_pool = []

func add_card(card_path):
	cards_pool.push_back(card_path)
	if running == false:
		run()

func next():
	running = false
	run()

func _ready():
	cards_pool.push_back(Card.generate(0, "增强", 3, "到下一回合为止，受到的所有伤害-1"))
	cards_pool.push_back(Card.generate(1, "光明", 5, "在3个回合之内，每一回合恢复1生命"))
	cards_pool.push_back(Card.generate(2, "毒瘴", 1, "到下一回合为止，所有玩家造成的伤害-1"))
	cards_pool.push_back(Card.generate(3, "心灵净化", 2, "增加3点能量"))
	cards_pool.push_back(Card.generate(4, "暴走", 3, "在3个回合之内，己方所有攻击类卡片能量消耗+1，造成的伤害+1"))
	cards_pool.push_back(Card.generate(5, "嗜血", 4, "造成3点伤害，恢复2点血量"))
# warning-ignore:return_value_discarded
	tween.connect("tween_all_completed", self, "next")
	run()

func run():
	if cards_pool.empty():
		return
	var card = load("res://assets/cards/card.tscn").instance()
	card.set_info(cards_pool.pop_front())
	card.connect("card_spell", self, "card_spelled")
	card.position = born
	anchor.add_child(card)
	sort_out(0.3)
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
	tween.start()

func card_spelled(card):
	emit_signal("custom_card_spelled", card)
	card.queue_free()
	sort_out(0.15)
