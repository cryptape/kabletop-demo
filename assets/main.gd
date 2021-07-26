extends Node2D

signal player_name
signal player_energy
signal player_hp

signal opposite_name
signal opposite_energy
signal opposite_hp

signal game_round

# a variable to identify the card that on dragging
var dragging_card = null

# identify players' role type by id
var player_roles = {
	1: 0, 2: 0
}

# identify my player id
var player_id = 0

# roles map to models
var role_models = {
	1: "res://assets/charactors/chosen/chosen.tscn",
	2: "res://assets/charactors/cultist/cultist.tscn",
	3: "res://assets/charactors/ironclad/ironclad.tscn",
	4: "res://assets/charactors/silent/silent.tscn"
}

# player's signals
func set_player_name(id, name):
	if id == player_id:
		emit_signal("player_name", name)
	else:
		emit_signal("opposite_name", name)

func set_player_energy(id, num):
	if id == player_id:
		emit_signal("player_energy", num)
	else:
		emit_signal("opposite_energy", num)
	
func set_player_hp(id, hp):
	if id == player_id:
		emit_signal("player_hp", "hp", hp)
	else:
		emit_signal("opposite_hp", "hp", hp)
	
func set_player_max_hp(id, max_hp):
	if id == player_id:
		emit_signal("player_hp", "max_hp", max_hp)
	else:
		emit_signal("opposite_hp", "max_hp", max_hp)
	
# player's effects
func damage_player(id, name):
	if id == player_id:
		var anchor = get_node("background/player/anchor")
		assert(anchor.get_child_count() > 0)
		anchor.get_child(0).get_damaged()
		var effect = get_node("background/player/effects")
		effect.play_effect(name)
	else:
		var anchor = get_node("background/opposite/anchor")
		assert(anchor.get_child_count() > 0)
		anchor.get_child(0).get_damaged()
		var effect = get_node("background/opposite/effects")
		effect.play_effect(name)
	
# player card operation
func add_player_card(id, hash_code):
	if id == player_id:
		var custom = get_node("cards/custom")
		custom.add_card(hash_code)
	else:
		var tiny_cards = get_node("panel/opposite_hp/tiny_cards")
		tiny_cards.add_card()
		
func spell_tiny_special():
	var role = get_opposite_role()
	var tiny_cards = get_node("panel/opposite_hp/tiny_cards")
	tiny_cards.spell_special(role)
	
func spell_tiny(i, hash_code):
	var tiny_cards = get_node("panel/opposite_hp/tiny_cards")
	tiny_cards.spell_custom(i, hash_code)

# player role and id operations
func set_player_role(id, role):
	player_roles[id] = role
	if id == player_id:
		var special = get_node("cards/special")
		special.set_role_card(role)
		var model_anchor = get_node("background/player/anchor")
		if model_anchor.get_child_count() > 0:
			model_anchor.get_child(0).free()
		assert(role_models[role] != null)
		var model = load(role_models[role]).instance()
		model.show_player()
		model.scale = Vector2(1.5, 1.5)
		model_anchor.add_child(model)
	else:
		var model_anchor = get_node("background/opposite/anchor")
		if model_anchor.get_child_count() > 0:
			model_anchor.get_child(0).free()
		assert(role_models[role] != null)
		var model = load(role_models[role]).instance()
		model.show_opposite()
		model.scale = Vector2(1.5, 1.5)
		model_anchor.add_child(model)

func set_my_id(id):
	assert(id == 1 or id == 2, "bad player id %d" % id)
	player_id = id
	
func get_my_id():
	return player_id

func get_opposite_id():
	return player_id % 2 + 1

func get_my_role():
	assert(player_id > 0, "please set player_id before")
	return player_roles[player_id]
	
func get_opposite_role():
	assert(player_id > 0, "please set player_id before")
	return player_roles[get_opposite_id()]
	
# game round rise
func add_round(num):
	emit_signal("game_round", num)
	
# enablility operation
func enable_all():
	dragging_card = null
	get_node("switch").set_enable(true)
	get_node("panel/player_hp/buffs").set_enable(true)
	get_node("panel/opposite_hp/buffs").set_enable(true)
	
func disable_all(node):
	dragging_card = node
	get_node("switch").set_enable(false)
	get_node("panel/player_hp/buffs").set_enable(false)
	get_node("panel/opposite_hp/buffs").set_enable(false)
	
