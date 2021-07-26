extends Node2D

onready var cards = $"/root/controller/cards"
onready var tiny_special = $"special"
onready var tiny_custom = $"custom"
onready var tween = $"Tween"

var spelling_info = null
var spell_cards = []
var running = false

func _ready():
	add_card()
	add_card()
	add_card()

func add_card():
	tiny_custom.add_card()

func spell_special(role):
	spell_cards.push_back({
		"index": 0,
		"id": role,
		"anchor": tiny_special
	})
	if running == false:
		run()
		
func spell_custom(i, id):
	spell_cards.push_back({
		"index": i,
		"id": id,
		"anchor": tiny_custom
	})
	if running == false:
		run()
	
func run():
	if spell_cards.empty():
		return
	var card = spell_cards.pop_front()
	card.anchor.spell(card.index, card.id)
	running = true

func show_tiny(path, card_info):
	var tiny = load(path).instance()
	tiny.input_pickable = false
	tiny.monitoring = false
	tiny.modulate = Color("00ffffff")
	tiny.scale = Vector2(3, 3)
	tiny.set_info(card_info)
	self.add_child(tiny)
	var target_position = tiny.position
	target_position.y += 100
	tween.interpolate_property(
		tiny, "position", tiny.position, target_position, 0.45
	)
	tween.interpolate_property(
		tiny, "modulate", tiny.modulate, Color("ffffffff"), 0.45
	)
	tween.connect("tween_all_completed", self, "prepare_demonstrate")
	tween.start()
	return tiny

func on_spell_tiny_special(role):
	var native_card = cards.get_native_card(role)
	var special = show_tiny("res://assets/cards/special.tscn", native_card)
	spelling_info = {
		"card": special,
		"emitor": $"/root/controller/cards/special",
		"enable": false
	}
	
func on_spell_tiny_custom(id):
	var card = cards.get_card(id)
	var custom = show_tiny("res://assets/cards/card.tscn", card)
	spelling_info = {
		"card": custom,
		"emitor": $"/root/controller/cards/custom",
		"enable": false
	}
	
func prepare_demonstrate():
	tween.disconnect("tween_all_completed", self, "prepare_demonstrate")
	spelling_info.enable = true

func demonstrate():
	var card = spelling_info.card
	tween.disconnect("tween_all_completed", self, "demonstrate")
	tween.interpolate_property(
		card, "modulate", card.modulate, Color("00ffffff"), 0.35
	)
	tween.interpolate_property(
		card, "scale", card.scale, Vector2(2.5, 2.5), 0.35
	)
	var target_position = card.position
	target_position.x -= 300
	tween.interpolate_property(
		card, "position", card.position, target_position, 0.35
	)
	tween.connect("tween_all_completed", self, "card_spelled")
	tween.start()
	
func card_spelled():
	tween.disconnect("tween_all_completed", self, "card_spelled")
	var card = spelling_info.card
	var emitor = spelling_info.emitor
	emitor.emit_event(card)
	running = false
	spelling_info = null
	run()

func _on_click_input_event(_viewport, event, _shape_idx):
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
		if spelling_info != null and spelling_info.enable:
			demonstrate()
			spelling_info.enable = false
