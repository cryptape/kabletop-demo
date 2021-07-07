extends GridContainer

export var energy = 0

func _ready():
	update_energy()

func update_energy():
	var points = self.get_children()
	for i in points.size():
		var point = points[i]
		if i < energy:
			point.set_self_modulate(Color(1, 1, 1, 1))
		else:
			point.set_self_modulate(Color(1, 1, 1, 0))

func _on_kabletop_player_energy(num):
	energy += num
	energy = min(energy, self.get_child_count())
	energy = max(energy, 0)
	update_energy()
