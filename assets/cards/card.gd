extends Area2D

onready var card            = $collision
onready var light_frame     = $light_frame
onready var tween           = $Tween
onready var origin_scale    = card.scale
onready var target_scale    = origin_scale * 1.125
onready var origin_position = card.position
onready var target_position = Vector2(origin_position.x, origin_position.y - 65)
onready var anchor          = get_node("/root/controller")
onready var examine_anchor  = anchor.get_node("cards")

var dragging = false
var spelling = false
var checking = false
var mouse_moved = false
var mouse_offset = Vector2.ZERO
var origin_global_position = Vector2.ZERO
var attribute = null

signal card_spell

func disabled():
	var dragging_card = anchor.dragging_card
	return dragging_card != null and dragging_card != self
	
func set_dragging(flag):
	dragging = flag
	if dragging:
		anchor.dragging_card = self
	else:
		anchor.dragging_card = null

func _on_card_mouse_entered():
	if disabled() or dragging or card.z_index == 1:
		return
	tween.interpolate_property(
		card, "scale",
		origin_scale, target_scale, 0.1, Tween.TRANS_LINEAR
	)
	tween.interpolate_property(
		card, "position",
		origin_position, target_position, 0.1, Tween.TRANS_LINEAR
	)
	tween.start()
	card.z_index = 1

func _on_card_mouse_exited():
	if disabled() or dragging or card.z_index == 0:
		return
	tween.interpolate_property(
		card, "scale",
		target_scale, origin_scale, 0.1, Tween.TRANS_LINEAR
	)
	tween.interpolate_property(
		card, "position", 
		target_position, origin_position, 0.1, Tween.TRANS_LINEAR
	)
	tween.start()
	card.z_index = 0
	
func _process(_delta):
	if dragging and !checking:
		self.global_position = get_global_mouse_position() + mouse_offset

func _on_card_input_event(_viewport, event, _shape_idx):
	if disabled():
		return
	if event is InputEventMouseMotion:
		mouse_moved = true
	if event is InputEventMouseButton \
			and event.button_index == BUTTON_LEFT \
			and !checking:
		if event.is_pressed():
			if origin_global_position == Vector2.ZERO:
				origin_global_position = self.global_position
			mouse_offset = self.global_position - get_global_mouse_position()
			set_dragging(true)
			mouse_moved = false
		else:
			if !dragging or !mouse_moved:
				set_dragging(false)
				return
			if spelling:
				tween.interpolate_property(
					self, "scale", Vector2.ONE, Vector2(1.2, 1.2), 0.15
				)
				tween.interpolate_property(
					self, "modulate",
					Color("ffffffff"), Color("00ffffff"), 0.15
				)
				tween.start()
# warning-ignore:return_value_discarded
				tween.connect("tween_all_completed", self, "spelled")
				set_dragging(false)
				spelling = false
			else:
				tween.interpolate_property(
					self, "global_position",
					self.global_position, origin_global_position,
					0.3, Tween.TRANS_SINE
				)
				set_dragging(false)
				_on_card_mouse_exited()
	if event is InputEventMouseButton \
			and event.button_index == BUTTON_RIGHT \
			and event.is_pressed():
		if origin_global_position == Vector2.ZERO:
			origin_global_position = self.global_position
		if !checking:
			tween.interpolate_property(
				self, "global_position", 
				self.global_position, examine_anchor.global_position, 0.2
			)
			tween.interpolate_property(
				self, "scale",
				self.scale, Vector2(2, 2), 0.2
			)
			checking = true
			set_dragging(true)
			tween.start()
		else:
			tween.interpolate_property(
				self, "global_position", 
				self.global_position, origin_global_position, 0.2
			)
			tween.interpolate_property(
				self, "scale",
				self.scale, Vector2(1, 1), 0.2
			)
			checking = false
			set_dragging(false)
			_on_card_mouse_exited()

func _on_card_area_shape_entered(_area_id, _area, _area_shape, _local_shape):
	if !dragging:
		return
	tween.interpolate_property(
		light_frame, "modulate", 
		Color("00ffffff"), Color("ffffffff"), 0.1
	)
	tween.start()
	spelling = true
	
func _on_card_area_shape_exited(_area_id, _area, _area_shape, _local_shape):
	if !spelling:
		return
	tween.interpolate_property(
		light_frame, "modulate", 
		Color("ffffffff"), Color("00ffffff"), 0.1
	)
	tween.start()
	spelling = false

func spelled():
	tween.disconnect("tween_all_completed", self, "spelled")
	emit_signal("card_spell", self)
	
func reset():
	card.scale = origin_scale
	card.position = origin_position
	card.z_index = 0
	self.global_position = origin_global_position
	self.scale = Vector2.ONE
	self.modulate = Color("ffffffff")
	light_frame.modulate = Color("00ffffff")

func set_info(info):
	attribute = info
	$"collision/frame/icon".frame = info.icon
	$"collision/frame/name".text = info.name
	$"collision/frame/cost".text = String(info.cost)
	$"collision/frame/description".text = info.description
