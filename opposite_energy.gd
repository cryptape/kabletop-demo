extends GridContainer

var energy = 0

func _ready():
	update_energy()
	
func update_energy():
	var points = self.get_children()
	var n = points.size()
	for i in n:
		var point = points[i]
		if (n - i) > energy:
			point.set_self_modulate(Color(1, 1, 1, 0))
		else:
			point.set_self_modulate(Color(1, 1, 1, 1))

func _on_kabletop_opposite_energy(num):
	energy += num
	energy = min(energy, self.get_child_count())
	energy = max(energy, 0)
	update_energy()
