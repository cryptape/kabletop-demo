extends GridContainer

export var energy = 0
onready var tween = $"../Tween"

func _ready():
	update_energy()

func update_energy():
	var points = self.get_children()
	for i in points.size():
		var point = points[i].get_node("vfx")
		if i < energy:
			update_to(point, Color(1, 1, 1, 1))
		else:
			update_to(point, Color(1, 1, 1, 0))

func _on_kabletop_player_energy(num):
	energy += num
	energy = min(energy, self.get_child_count())
	energy = max(energy, 0)
	update_energy()

func update_to(point, color):
	tween.interpolate_property(
		point, "modulate", point.modulate, color, 0.2
	)
	tween.start()
