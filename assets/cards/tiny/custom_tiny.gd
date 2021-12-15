extends Node2D

onready var tween = $Tween
onready var anchor = $anchor
onready var controller = get_node("/root/controller")

var width = 350
var step = 60
var pending_count = 0
var pending_del = []
var dead_tiny = null
var running = false

func _ready():
	tween.connect("tween_all_completed", self, "sort_complete")

func add_card():
	pending_count += 1
	if running == false:
		run()
	
func del_card(offset):
	pending_del.push_back(offset)
	if running == false:
		run()
	
func run():
	if pending_count > 0:
		var tiny = load("res://assets/cards/tiny/tiny.tscn").instance()
		anchor.add_child(tiny)
		sort_out()
		pending_count -= 1
		running = true
		controller.short_deck(controller.opposite_id, 1)
	elif !pending_del.empty():
		var children = []
		for node in anchor.get_children():
			if !node.is_queued_for_deletion():
				children.push_back(node)
		dead_tiny = children[pending_del.pop_front()]
		assert(dead_tiny, "bad tiny drop indexer")
		tween.interpolate_property(
			dead_tiny, "position",
			dead_tiny.position, dead_tiny.position + Vector2(0, 50), 0.3,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		sort_out()
		running = true

func spell(i, id):
	var tiny = anchor.get_child(i)
	tiny.spell(id)
	
func on_spelled(tiny):
	var id = tiny.card_id
	tiny.queue_free()
	sort_out()
	self.get_parent().on_spell_tiny_custom(id)
	
func sort_out():
	var valid_children = []
	for node in anchor.get_children():
		if !node.is_queued_for_deletion() and node != dead_tiny:
			valid_children.push_back(node)
	var step_num = valid_children.size() - 1
	for i in valid_children.size():
		var x = (width - step_num * step) / 2 + i * step
		var tiny = valid_children[i]
		tween.interpolate_property(
			tiny, "position",
			tiny.position, Vector2(x, 125), 0.3,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
	tween.start()

func sort_complete():
	if dead_tiny != null:
		dead_tiny.queue_free()
		dead_tiny = null
	running = false
	run()
	if !running:
		self.get_parent().complete_add_card()
