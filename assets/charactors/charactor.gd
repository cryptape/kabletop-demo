extends Node2D

func get_damaged():
	$damage.play("jitter")

func show_player():
	$"anchor/player".visible = true
	$"anchor/opposite".visible = false
	
func show_opposite():
	$"anchor/player".visible = false
	$"anchor/opposite".visible = true
