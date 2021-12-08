extends Control

onready var controller = $"/root/controller"
onready var tween = controller.get_node("Tween")

var selected = 0
var owned = 0
var info = null

func set_info(data):
	info = data
	$frame/icon.frame = data.icon
	$frame/cost.text = String(data.cost)
	$frame/name.text = data.name
	$frame/description.text = data.description
	
func set_count(count, total):
	assert(count <= total);
	$frame/indicator/current.text = String(count)
	$frame/indicator/total.text = "/" + String(total)
	if total > 0:
		owned = total
		if count > 0:
			selected = count
			$frame/indicator_icon.frame = 1
	else:
		$frame/indicator_icon.frame = 2
		# $frame/locked.show()

func _on_mouse_check_gui_input(event):
	if event is InputEventMouseButton \
			and event.is_pressed() \
			and info != null \
			and owned > 0:
		var old = selected
		if event.button_index == BUTTON_LEFT:
			selected = min(selected + 1, owned)
		else:
			selected = max(selected - 1, 0)
		if selected > 0:
			$frame/indicator_icon.frame = 1
		else:
			$frame/indicator_icon.frame = 0
		$frame/indicator/current.text = String(selected)
		controller.click_card(info._hash, selected - old)

func _on_mouse_check_mouse_entered():
	tween.interpolate_property(
		$light_frame, "modulate",
		Color("00ffffff"), Color("ffffffff"), 0.1
	)
	tween.start()

func _on_mouse_check_mouse_exited():
	tween.interpolate_property(
		$light_frame, "modulate",
		Color("ffffffff"), Color("00ffffff"), 0.1
	)
	tween.start()
