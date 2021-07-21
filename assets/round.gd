extends Label

var round_count = 0

func _on_kabletop_game_round(count):
	round_count += count
	self.text = String(round_count)
