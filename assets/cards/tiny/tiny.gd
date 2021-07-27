extends Sprite

onready var tween = $Tween
onready var parent = $"../../"

var card_id = 0

func spell(id):
	card_id = id
	var target_position = Vector2(self.position.x, self.position.y - 20)
	tween.interpolate_property(
		self, "position",
		self.position, target_position, 0.3
	)
	tween.interpolate_property(
		self, "modulate",
		self.modulate, Color("00ffffff"), 0.3
	)
	tween.connect("tween_all_completed", self, "spelled")
	tween.start()
	
func spelled():
	tween.disconnect("tween_all_completed", self, "spelled")
	parent.on_spelled(self)
