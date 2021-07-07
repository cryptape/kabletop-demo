extends Sprite

onready var origin_size_x = self.region_rect.size.x
onready var hp_node = self.get_child(0)

var max_hp = 30
var hp = 0

func _ready():
	update_hp()

func update_hp():
	hp_node.text = String(hp)
	var new_x = origin_size_x * hp / max_hp
	self.region_rect.size.x = new_x

func _on_controller_player_hp(type, value):
	if type == "max_hp":
		max_hp = value
	if type == "hp":
		hp += value
		hp = min(hp, max_hp)
		hp = max(hp, 0)
	update_hp()
