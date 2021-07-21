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
func set_player_name(name):
	emit_signal("player_name", name)

func add_player_energy(num):
	emit_signal("player_energy", num)
	
func add_player_hp(hp):
	emit_signal("player_hp", "hp", hp)
	
func set_player_max_hp(max_hp):
	emit_signal("player_hp", "max_hp", max_hp)
	
# player's effects
func damage_player(name):
	var player = get_node("background/player")
	player.get_node("anchor/model").get_damaged()
	var effect = player.get_node("effects")
	effect.play_effect(name)
	

# opposite's signals
func set_opposite_name(name):
	emit_signal("opposite_name", name)
	
func add_opposite_energy(num):
	emit_signal("opposite_energy", num)
	
func add_opposite_hp(hp):
	emit_signal("opposite_hp", "hp", hp)
	
func set_opposite_max_hp(hp):
	emit_signal("opposite_hp", "max_hp", hp)
	
# opposite's effects
func damage_opposite(name):
	var opposite = get_node("background/opposite")
	opposite.get_node("anchor/model").get_damaged()
	var effect = opposite.get_node("effects")
	effect.play_effect(name)
	
# game round rise
func add_round(num):
	emit_signal("game_round", num)
