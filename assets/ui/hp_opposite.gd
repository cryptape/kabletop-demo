extends Sprite

onready var origin_size_x     = self.region_rect.size.x
onready var origin_position_x = self.region_rect.position.x
onready var origin_offset_x   = self.offset.x
onready var tween             = $Tween

var max_hp = 30
var hp = 0
var hp_display = 0

func _ready():
	update_hp()
	
func update_hp(anim = false):
	$hp.text = String(hp)
	var x = origin_size_x * (max_hp - hp_display) / max_hp
	var from = self.region_rect
	var to = Rect2(
		Vector2(origin_position_x + x, from.position.y),
		Vector2(origin_size_x - x, from.size.y)
	)
	var offset_to = Vector2(origin_offset_x + x, self.offset.y)
	tween.stop(self, "region_rect")
	tween.stop(self, "offset")
	if anim:
		tween.interpolate_property(self, "region_rect", from, to, 0.45)
		tween.interpolate_property(self, "offset", self.offset, offset_to, 0.45)
		tween.start()
	else:
		self.region_rect = to
		self.offset = offset_to

func _on_controller_opposite_hp(type, value):
	if type == "max_hp":
		max_hp = value
	if type == "hp":
		hp = value
		hp_display = min(value, max_hp)
		hp_display = max(hp_display, 0)
	update_hp(true)
