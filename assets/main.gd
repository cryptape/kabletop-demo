extends Node2D

signal player_name
# warning-ignore:unused_signal
signal player_energy
# warning-ignore:unused_signal
signal player_hp

signal opposite_name
# warning-ignore:unused_signal
signal opposite_energy
# warning-ignore:unused_signal
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
var acting_player_id = 0

# roles map to models
var role_models = {
	1: "res://assets/charactors/chosen/chosen.tscn",
	2: "res://assets/charactors/cultist/cultist.tscn",
	3: "res://assets/charactors/ironclad/ironclad.tscn",
	4: "res://assets/charactors/silent/silent.tscn"
}

# deferred functions queue
var defer_funcs = {
	1: [],
	2: []
}

func apply_defer_funcs(id):
	while !defer_funcs[id].empty():
		var defer = defer_funcs[id].pop_front()
		if defer.ref == null:
			break
		defer.ref.call_funcv(defer.args)

func apply_change(id, card_index, hash_code):
	if id == player_id:
		apply_defer_funcs(id)
	else:
		var node = get_node("panel/opposite_hp/tiny_cards")
		if card_index == -1:
			node.spell_special(get_opposite_role())
		else:
			node.spell_custom(card_index, hash_code)
		defer_funcs[acting_player_id].push_back({
			"ref": null
		})

func set_acting_player(id):
	acting_player_id = id
	if acting_player_id != player_id:
		switch_enable(self, false)
	else:
		switch_enable()

# player's signals
func set_player_name(id, name):
	if id == player_id:
		emit_signal("player_name", name)
	else:
		emit_signal("opposite_name", name)
		
func set_player_energy(id, num, defer = false):
	var event = ""
	if id == player_id:
		event = "player_energy"
	else:
		event = "opposite_energy"
	if defer:
		defer_funcs[acting_player_id].push_back({
			"ref": funcref(self, "emit_signal"),
			"args": [event, num]
		})
	else:
		emit_signal(event, num)
	
func set_player_hp(id, hp, defer = false):
	var event = ""
	if id == player_id:
		event = "player_hp"
	else:
		event = "opposite_hp"
	if defer:
		defer_funcs[acting_player_id].push_back({
			"ref": funcref(self, "emit_signal"),
			"args": [event, "hp", hp]
		})
	else:
		emit_signal(event, "hp", hp)
	
func set_player_max_hp(id, max_hp, defer = false):
	var event = ""
	if id == player_id:
		event = "player_hp"
	else:
		event = "opposite_hp"
	if defer:
		defer_funcs[acting_player_id].push_back({
			"ref": funcref(self, "emit_signal"),
			"args": [event, "max_hp", max_hp]
		})
	else:
		emit_signal(event, "max_hp", max_hp)
	
# player's effects
func _damage(who, effect_name):
	var anchor = get_node("background/%s/anchor" % who)
	assert(anchor.get_child_count() > 0)
	anchor.get_child(0).get_damaged()
	var effect = get_node("background/%s/effects" % who)
	effect.play_effect(effect_name)

func damage_player(id, effect_name, defer = false):
	var target = ""
	if id == player_id:
		target = "player"
	else:
		target = "opposite"
	if defer:
		defer_funcs[acting_player_id].push_back({
			"ref": funcref(self, "_damage"),
			"args": [target, effect_name]
		})
	else:
		_damage(target, effect_name)
	
func _heal(who):
	var anchor = get_node("background/%s/anchor" % who)
	assert(anchor.get_child_count() > 0)
	anchor.get_child(0).get_healed()
	#var effect = get_node("background/%s/effects" % who)
	#effect.play_effect(effect_name)

func heal_player(id, defer = false):
	var target = ""
	if id == player_id:
		target = "player"
	else:
		target = "opposite"
	if defer:
		defer_funcs[acting_player_id].push_back({
			"ref": funcref(self, "_heal"),
			"args": [target]
		})
	else:
		_heal(target)
	
# player buffs
func _add_buff(who, buff_id, life):
	var buffs = get_node("panel/%s_hp/buffs" % who)
	buffs.add_buff(buff_id, life)

func add_player_buff(id, buff_id, life, defer = false):
	var target = ""
	if id == player_id:
		target = "player"
	else:
		target = "opposite"
	if defer:
		defer_funcs[acting_player_id].push_back({
			"ref": funcref(self, "_add_buff"),
			"args": [target, buff_id, life]
		})
	else:
		_add_buff(target, buff_id, life)
		
func update_player_buff(id, which, life):
	if id == player_id:
		get_node("panel/player_hp/buffs").update_buff(which, life)
	else:
		get_node("panel/opposite_hp/buffs").update_buff(which, life)

# player card operation
func add_player_card(id, hash_code):
	if id == player_id:
		var node = get_node("cards/custom")
		node.add_card(hash_code)
	else:
		var node = get_node("panel/opposite_hp/tiny_cards")
		node.add_card()

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

func get_opposite_id():
	return player_id % 2 + 1

func get_operator_role():
	assert(player_id > 0, "please set player_id before")
	return player_roles[player_id]
	
func get_opposite_role():
	assert(player_id > 0, "please set player_id before")
	return player_roles[get_opposite_id()]
	
# game round rise
func set_round(count):
	emit_signal("game_round", count)
	
# enablility operation
func switch_enable(cards = null, switch = true, buffs = true):
	get_node("cards").set_enable(cards)
	get_node("switch").set_enable(switch)
	get_node("panel/player_hp/buffs").set_enable(buffs)
	get_node("panel/opposite_hp/buffs").set_enable(buffs)
	
