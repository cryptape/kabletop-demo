extends Node2D

signal player_name
signal player_energy
signal player_hp

signal opposite_name
signal opposite_energy
signal opposite_hp

signal game_round

# players' signals
func set_player_name(name):
	emit_signal("player_name", name)

func add_player_energy(num):
	emit_signal("player_energy", num)
	
func add_player_hp(hp):
	emit_signal("player_hp", "hp", hp)
	
func set_player_max_hp(max_hp):
	emit_signal("player_hp", "max_hp", max_hp)

# opposites' signals
func set_opposite_name(name):
	emit_signal("opposite_name", name)
	
func add_opposite_energy(num):
	emit_signal("opposite_energy", num)
	
func add_opposite_hp(hp):
	emit_signal("opposite_hp", "hp", hp)
	
func set_opposite_max_hp(hp):
	emit_signal("opposite_hp", "max_hp", hp)
	
# game round rise
func add_round(num):
	emit_signal("game_round", num)
