extends Node2D

onready var tween = $"../Tween"

var box_count = 0
var enable = true

func _ready():
	Sdk.connect("box_status_updated", self, "on_box_status_updated")

func _on_click_mouse_entered():
	if enable:
		$box.frame = 1

func _on_click_mouse_exited():
	if enable:
		$box.frame = 0

func _on_click_input_event(_viewport, event, _shape_idx):
	if event.is_pressed() and enable:
		if event.button_index == BUTTON_LEFT:
			box_count += 1
		else:
			box_count = max(box_count - 1, 0)
		$count.text = "x" + String(box_count)
		if box_count > 0:
			if !$package_buy.visible:
				$package_buy.show()
				tween.interpolate_property(
					$package_buy, "modulate",
					Color("00ffffff"), Color("ffffffff"), 0.1
				)
				tween.start()
		else:
			if $package_buy.visible:
				tween.interpolate_property(
					$package_buy, "modulate",
					Color("ffffffff"), Color("00ffffff"), 0.1
				)
				tween.start()
				yield(tween, "tween_all_completed")
				$package_buy.hide()

func on_box_status_updated(count, ready):
	box_count = count
	$count.text = "x" + String(box_count)
	$package_buy.hide()
	$package_reveal.hide()
	if box_count > 0:
		enable = false
		if ready:
			$package_reveal.show()
			$box.frame = 1
		else:
			$box.playing = true
	else:
		enable = true
		$box.frame = 0
		$box.playing = false

func on_purchase_or_reveal_nfts(error):
	if error != null:
		print(error)
		return

func click_button(button):
	assert(box_count > 0)
	if button == $package_buy:
		Sdk.purchase_nfts(box_count, funcref(self, "on_purchase_or_reveal_nfts"))
	else:
		Sdk.reveal_nfts(funcref(self, "on_purchase_or_reveal_nfts"))
