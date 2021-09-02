extends Sprite

onready var origin_size_x = self.region_rect.size.x
onready var tween = $Tween

var max_hp = 30
var hp = 0

func _ready():
	update_hp()

func update_hp(anim = false):
	$hp.text = String(hp)
	var x = origin_size_x * hp / max_hp
	var from = self.region_rect
	var to = Rect2(from.position, Vector2(x, from.size.y))
	tween.stop(self, "region_rect")
	if anim:
		tween.interpolate_property(self, "region_rect", from, to, 0.45)
		tween.start()
	else:
		self.region_rect = to

func _on_controller_player_hp(type, value):
	if type == "max_hp":
		max_hp = value
	if type == "hp":
		hp = value
		hp = min(hp, max_hp)
		hp = max(hp, 0)
	update_hp(true)
