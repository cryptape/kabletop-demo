extends Node2D

onready var tween = $Tween
onready var anchor = $anchor
onready var controller = get_node("/root/controller")

var width = 350
var step = 60
var pending_count = 0
var pending_del = []
var running = false

func _ready():
	tween.connect("tween_all_completed", self, "sort_complete")

func add_card():
	pending_count += 1
	if running == false:
		run()
	
func del_card(offset, _hash_code):
	if offset < anchor.get_child_count():
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
	if !pending_del.empty():
		var tiny = anchor.get_child(pending_del.pop_front())
		tween.interpolate_property(
			tiny, "position",
			tiny.position, tiny.position + Vector2(0, 25), 0.3,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		tween.connect("tween_completed", self, "del_complete")
		tween.start()
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
		if !node.is_queued_for_deletion():
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
	tween.connect("tween_all_completed", self, "sort_complete")
	tween.start()

func sort_complete():
	tween.disconnect("tween_all_completed", self, "sort_complete")
	running = false
	if pending_count > 0:
		run()
	else:
		self.get_parent().complete_add_card()

func del_complete():
	tween.disconnect("tween_completed", self, "del_complete")
	sort_out()
