extends AnimatedSprite

onready var tips = $tips
var enable = true

func set_tips(text):
	tips.get_node("text").text = text

func _on_hover_mouse_entered():
	if enable:
		tips.visible = true

func _on_hover_mouse_exited():
	if enable:
		tips.visible = false
