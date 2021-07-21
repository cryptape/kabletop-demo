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

# player's signals
func set_player_name(id, name):
	assert(id == 1 or id == 2, "bad player id %d" % id)
	match id:
		1: 
			emit_signal("player_name", name)
		2: 
			emit_signal("opposite_name", name)

func set_player_energy(id, num):
	assert(id == 1 or id == 2, "bad player id %d" % id)
	match id:
		1: 
			emit_signal("player_energy", num)
		2: 
			emit_signal("opposite_energy", num)
	
func set_player_hp(id, hp):
	assert(id == 1 or id == 2, "bad player id %d" % id)
	match id:
		1: 
			emit_signal("player_hp", "hp", hp)
		2: 
			emit_signal("opposite_hp", "hp", hp)
	
func set_player_max_hp(id, max_hp):
	assert(id == 1 or id == 2, "bad player id %d" % id)
	match id:
		1: 
			emit_signal("player_hp", "max_hp", max_hp)
		2: 
			emit_signal("opposite_hp", "max_hp", max_hp)
	
# player's effects
func damage_player(id, name):
	assert(id == 1 or id == 2, "bad player id %d" % id)
	match id:
		1: 
			var player = get_node("background/player")
			player.get_node("anchor/model").get_damaged()
			var effect = player.get_node("effects")
			effect.play_effect(name)
		2: 
			var opposite = get_node("background/opposite")
			opposite.get_node("anchor/model").get_damaged()
			var effect = opposite.get_node("effects")
			effect.play_effect(name)
	
# player other operations
func add_player_card(id, hash_code):
	assert(id == 1 or id == 2, "bad player id %d" % id)
	match id:
		1:
			var custom = get_node("cards/custom")
			custom.add_card(hash_code)
		2:
			pass
	
func set_player_role(id, role):
	assert(id == 1 or id == 2, "bad player id %d" % id)
	match id:
		1:
			var special = get_node("cards/special")
			special.set_role_card(role)
		2:
			pass
	
# game round rise
func add_round(num):
	emit_signal("game_round", num)
