extends Sprite

onready var tween = $"Tween"
onready var origin_position = self.position
onready var target_position = Vector2(self.position.x, self.position.y - 20)
var player_role = 0

func spell(_i, role):
	player_role = role
	tween.interpolate_property(
		self, "position",
		origin_position, target_position, 0.3
	)
	tween.interpolate_property(
		self, "modulate",
		self.modulate, Color("00ffffff"), 0.3
	)
	tween.connect("tween_all_completed", self, "spelled")
	tween.start()
	
func spelled():
	tween.disconnect("tween_all_completed", self, "spelled")
	tween.interpolate_property(
		self, "position",
		target_position, origin_position, 0.3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.3
	)
	tween.interpolate_property(
		self, "modulate",
		self.modulate, Color("ffffffff"), 0.3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.3
	)
	tween.start()
	self.get_parent().on_spell_tiny_special(player_role)
