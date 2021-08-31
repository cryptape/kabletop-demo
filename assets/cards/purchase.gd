extends Node2D

onready var tween = $"../Tween"

var box_count = 0
var enable = true

func _ready():
	var status = Sdk.get_box_status()
	if status != null:
		on_box_status_updated(status["count"], status["ready"])
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
	$package_create.hide()
	$box/lock.hide()
	if box_count > 0:
		enable = false
		if ready:
			$package_reveal.show()
			$box.frame = 1
		else:
			$box.playing = true
	elif ready:
		enable = true
		$box.frame = 0
		$box.playing = false
	else:
		enable = false
		$box/lock.show()
		$package_create.show()
		$box.frame = 0
		$box.playing = false

func on_side_button_click(ok, hash_or_error):
	if ok:
		print("hash = ", hash_or_error)
	else:
		print("nft error: ", hash_or_error)

func click_button(button):
	var error
	Wait.set_wait(null, null)
	if button == $package_buy:
		assert(box_count > 0)
		error = Sdk.purchase_nfts(box_count, funcref(Wait, "set_result"))
	elif button == $package_reveal:
		assert(box_count > 0)
		error = Sdk.reveal_nfts(funcref(Wait, "set_result"))
	else:
		assert(box_count == 0)
		error = Sdk.create_nft_wallet(funcref(Wait, "set_result"))
	if error != null:
		Wait.set_failed(error, null)
