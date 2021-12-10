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

# identify player id
var player_id = 0
var opposite_id = 0
var acting_player_id = 0
var battle_finished = false
var round_switching = false

# roles map to models
var role_models = {
	1: "res://assets/charactors/cultist/cultist.tscn",
	2: "res://assets/charactors/ironclad/ironclad.tscn",
	3: "res://assets/charactors/chosen/chosen.tscn",
	4: "res://assets/charactors/silent/silent.tscn"
}

# deferred functions queue
var defer_funcs = {
	0: [],
	1: [],
	2: []
}

# cards display
var remain_cards = {
	1: 0, 2: 0
}
var total_cards = {
	1: 0, 2: 0
}

func _ready():
	get_node("/root").call_deferred("move_child", self, 0)

func apply_defer_funcs(id, no_tiny_cards = false):
	while !defer_funcs[id].empty():
		var defer = defer_funcs[id].pop_front()
		if defer.ref == null:
			if battle_finished and no_tiny_cards:
				continue
			elif round_switching and no_tiny_cards:
				continue
			else:
				break
		defer.ref.call_funcv(defer.args)

func apply_change(id, card_index = null, hash_code = null):
	if id == player_id:
		apply_defer_funcs(id)
	else:
		if card_index != null:
			var node = get_node("panel/opposite_hp/tiny_cards")
			if card_index == -1:
				node.spell_special(get_opposite_role())
			else:
				node.spell_custom(card_index, hash_code)
			defer_funcs[id].push_back({
				"ref": null
			})
		else:
			apply_defer_funcs(id)

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
		
func set_player_energy(id, num, defer = true):
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
	
func set_player_hp(id, hp, defer = true):
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
	
func set_player_max_hp(id, max_hp, defer = true):
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

func damage_player(id, effect_name, defer = true):
	var path = ""
	if id == player_id:
		path = "player"
	else:
		path = "opposite"
	if defer:
		defer_funcs[acting_player_id].push_back({
			"ref": funcref(self, "_damage"),
			"args": [path, effect_name]
		})
	else:
		_damage(path, effect_name)
	
func _heal(who):
	var anchor = get_node("background/%s/anchor" % who)
	assert(anchor.get_child_count() > 0)
	anchor.get_child(0).get_healed()
	#var effect = get_node("background/%s/effects" % who)
	#effect.play_effect(effect_name)

func heal_player(id, defer = true):
	var path = ""
	if id == player_id:
		path = "player"
	else:
		path = "opposite"
	if defer:
		defer_funcs[acting_player_id].push_back({
			"ref": funcref(self, "_heal"),
			"args": [path]
		})
	else:
		_heal(path)
	
# player buffs
func _add_buff(who, buff_id, value, life):
	var buffs = get_node("panel/%s_hp/buffs" % who)
	buffs.add_buff(buff_id, value, life)

func add_player_buff(id, buff_id, value, life, defer = true):
	var path = ""
	if id == player_id:
		path = "player"
	else:
		path = "opposite"
	if defer:
		defer_funcs[acting_player_id].push_back({
			"ref": funcref(self, "_add_buff"),
			"args": [path, buff_id, value, life]
		})
	else:
		_add_buff(path, buff_id, value, life)

func _update_buff(who, which, value, life):
	var buffs = get_node("panel/%s_hp/buffs" % who)
	if life > 0:
		buffs.update_buff(which, value, life)
	else:
		buffs.remove_buff(which)

func update_player_buff(id, which, value, life, defer = true):
	var path = ""
	if id == player_id:
		path = "player"
	else:
		path = "opposite"
	if defer:
		defer_funcs[acting_player_id].push_back({
			"ref": funcref(self, "_update_buff"),
			"args": [path, which, value, life]
		})
	else:
		_update_buff(path, which, value, life)

# player card operation
func add_player_card(id, hash_code, defer = true):
	var node = null
	if id == player_id:
		node = get_node("cards/custom")
	else:
		node = get_node("panel/opposite_hp/tiny_cards")
	if defer:
		defer_funcs[acting_player_id].push_back({
			"ref": funcref(node, "add_card"),
			"args": [hash_code]
		})
	else:
		node.add_card(hash_code)
		
func del_player_card(id, offset, hash_code, defer = true):
	var node = null
	if id == player_id:
		node = get_node("cards/custom")
	else:
		node = get_node("panel/opposite_hp/tiny_cards")
	if defer:
		defer_funcs[acting_player_id].push_back({
			"ref": funcref(node, "del_card"),
			"args": [offset, hash_code]
		})
	else:
		node.del_card(offset, hash_code)

# player role and id operations
func set_player_role(id, role):
	player_roles[id] = role
	if id == player_id:
		var special = get_node("cards/special")
		special.set_role_card(role)
		var model_anchor = get_node("background/player/anchor")
		assert(role_models[role] != null)
		var model = load(role_models[role]).instance()
		model.show_player()
		model_anchor.add_child(model)
	else:
		var model_anchor = get_node("background/opposite/anchor")
		assert(role_models[role] != null)
		var model = load(role_models[role]).instance()
		model.show_opposite()
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
	
func switch_round(id, defer_funcref, params):
	var tiny_cards = get_node("panel/opposite_hp/tiny_cards")
	if id == player_id:
		apply_defer_funcs(opposite_id)
		defer_funcref.call_funcv(params)
	else:
		if tiny_cards.no_card_to_spell():
			defer_funcref.call_funcv(params)
		else:
			round_switching = true
			defer_funcs[acting_player_id].push_back({
				"ref": defer_funcref,
				"args": params
			})
	
# enablity operation
func switch_enable(cards = null, switch = true, buffs = true):
	get_node("cards").set_enable(cards)
	get_node("switch").set_enable(switch)
	get_node("panel/player_hp/buffs").set_enable(buffs)
	get_node("panel/opposite_hp/buffs").set_enable(buffs)

func set_battle_result(id, defer_funcref):
	battle_finished = true
	if id == player_id:
		defer_funcref.call_func(player_id)
	else:
		defer_funcs[acting_player_id].push_back({
			"ref": defer_funcref,
			"args": [player_id]
		})

func set_deck_capcacity(id, total_count, remain_count = null):
	if remain_count == null:
		remain_count = total_count
	total_cards[id] = total_count
	remain_cards[id] = remain_count
	if id == player_id:
		$panel/player_deck/info.text = "%s/%s" % [remain_count, total_count]
	else:
		$panel/opposite_deck.text = "%s/%s" % [remain_count, total_count]

func short_deck(id, count):
	remain_cards[id] -= count
	assert(remain_cards[id] >= 0)
	var remain = remain_cards[id]
	var total = total_cards[id]
	if id == player_id:
		$panel/player_deck/info.text = "%s/%s" % [remain, total]
	else:
		$panel/opposite_deck.text = "%s/%s" % [remain, total]
