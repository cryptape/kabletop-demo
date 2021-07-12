extends Sprite

onready var origin_size_x     = self.region_rect.size.x
onready var origin_position_x = self.region_rect.position.x
onready var origin_offset_x   = self.offset.x
onready var tween             = $"../../Tween"

var max_hp = 30
var hp = 0

func _ready():
	update_hp()
	
func update_hp():
	$hp.text = String(hp)
	var x = origin_size_x * (max_hp - hp) / max_hp
	var from = self.region_rect
	var to = Rect2(
		Vector2(origin_position_x + x, from.position.y),
		Vector2(origin_size_x - x, from.size.y)
	)
	if from != to:
		tween.stop(self, "region_rect")
		tween.stop(self, "offset")
		tween.interpolate_property(self, "region_rect", from, to, 0.45)
		tween.interpolate_property(self, "offset", 
			self.offset, Vector2(origin_offset_x + x, self.offset.y), 0.45
		)
		tween.start()

func _on_controller_opposite_hp(type, value):
	if type == "max_hp":
		max_hp = value
	if type == "hp":
		hp += value
		hp = min(hp, max_hp)
		hp = max(hp, 0)
	update_hp()
