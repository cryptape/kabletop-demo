extends Sprite

onready var origin_scale    = self.scale
onready var target_scale    = Vector2(0.45, 0.45)
onready var origin_position = self.position
onready var target_position = Vector2(origin_position.x, origin_position.y - 65)
onready var parent          = self.get_parent()
onready var light_frame     = self.get_parent().get_node("light_frame")

var dragging = false
var spelling = false
var mouse_offset = Vector2.ZERO
var origin_global_position = Vector2.ZERO

signal card_spell

func _on_card_mouse_entered():
	if dragging or self.z_index == 1:
		return
	$Tween.interpolate_property(
		self, "scale", 
		origin_scale, target_scale, 0.1, Tween.TRANS_LINEAR
	)
	$Tween.interpolate_property(
		self, "position", 
		origin_position, target_position, 0.1, Tween.TRANS_LINEAR
	)
	$Tween.start()
	self.z_index = 1

func _on_card_mouse_exited():
	if dragging or self.z_index == 0:
		return
	$Tween.interpolate_property(
		self, "scale",
		target_scale, origin_scale, 0.1, Tween.TRANS_LINEAR
	)
	$Tween.interpolate_property(
		self, "position", 
		target_position, origin_position, 0.1, Tween.TRANS_LINEAR
	)
	$Tween.start()
	self.z_index = 0
	
func _process(_delta):
	if dragging:
		parent.global_position = get_global_mouse_position() + mouse_offset

func _on_card_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			if origin_global_position == Vector2.ZERO:
				origin_global_position = parent.global_position
			mouse_offset = parent.global_position - get_global_mouse_position()
			dragging = true
		else:
			if spelling:
				$Tween.interpolate_property(
					parent, "scale", Vector2.ONE, Vector2(1.2, 1.2), 0.15
				)
				$Tween.interpolate_property(
					parent, "modulate",
					Color("ffffffff"), Color("00ffffff"), 0.15
				)
				$Tween.start()
# warning-ignore:return_value_discarded
				$Tween.connect("tween_all_completed", self, "spelled")
			else:
				$Tween.interpolate_property(
					parent, "global_position",
					parent.global_position, origin_global_position,
					0.3, Tween.TRANS_SINE
				)
				dragging = false
				_on_card_mouse_exited()

func _on_card_area_shape_entered(_area_id, _area, _area_shape, _local_shape):
	if !dragging:
		return
	$Tween.interpolate_property(
		light_frame, "modulate", 
		Color("00ffffff"), Color("ffffffff"), 0.1
	)
	$Tween.start()
	spelling = true
	
func _on_card_area_shape_exited(_area_id, _area, _area_shape, _local_shape):
	if !spelling:
		return
	$Tween.interpolate_property(
		light_frame, "modulate", 
		Color("ffffffff"), Color("00ffffff"), 0.1
	)
	$Tween.start()
	spelling = false

func spelled():
	$Tween.disconnect("tween_all_completed", self, "spelled")
	emit_signal("card_spell", parent)
