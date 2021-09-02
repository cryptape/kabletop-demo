extends Node2D

onready var tween = $Tween
onready var anchor = $anchor
onready var controller = get_node("/root/controller")

var width = 350
var step = 60
var pending_count = 0
var running = false

func _ready():
	tween.connect("tween_all_completed", self, "sort_complete")

func add_card():
	pending_count += 1
	run()
	
func run():
	if running or pending_count == 0:
		return
	var tiny = load("res://assets/cards/tiny/tiny.tscn").instance()
	anchor.add_child(tiny)
	sort_out()
	pending_count -= 1
	running = true
	controller.short_deck(controller.opposite_id, 1)

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
	tween.start()

func sort_complete():
	running = false
	if pending_count > 0:
		run()
	else:
		self.get_parent().complete_add_card()
