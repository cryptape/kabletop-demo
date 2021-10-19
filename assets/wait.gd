extends Node2D

var confirm_funcref = null
var cancel_funcref = null
var success_or_fail = null

func set_wait(callback, text):
	show()
	if text == null:
		text = "交易提交中..."
	$panel/title.text = text
	$panel/confirm.hide()
	$panel/cancel.hide()
	$panel/hash.hide()
	$panel/waiting.show()
	confirm_funcref = callback
	success_or_fail = null

func set_result(ok, hash_or_error):
	if ok:
		set_commited(hash_or_error, null)
	else:
		set_failed(hash_or_error, null)

func set_commited(tx_hash, text):
	show()
	if text == null:
		text = "交易提交完成:"
	$panel/title.text = text
	$panel/hash.text = tx_hash
	$panel/hash.show()
	$panel/confirm.show()
	$panel/waiting.hide()
	$panel/cancel.hide()
	success_or_fail = true
	print(tx_hash)

func set_failed(error, text):
	show()
	if text == null:
		text = "交易提交失败:"
	$panel/title.text = text
	$panel/hash.text = error
	$panel/hash.show()
	$panel/confirm.show()
	$panel/waiting.hide()
	$panel/cancel.hide()
	success_or_fail = false

func set_manual_cancel(info, title, callback = null):
	show()
	$panel/title.text = title
	$panel/hash.text = info
	$panel/hash.show()
	$panel/waiting.hide()
	$panel/confirm.hide()
	if callback != null:
		$panel/cancel.show()
		cancel_funcref = callback
	else:
		$panel/cancel.hide()

func set_manual_confirm(info, title, callback = null):
	show()
	$panel/title.text = title
	$panel/hash.text = info
	$panel/hash.show()
	$panel/waiting.hide()
	$panel/cancel.hide()
	if callback != null:
		$panel/confirm.show()
		confirm_funcref = callback
	else:
		$panel/confirm.hide()

func _on_confirm_pressed():
	hide()
	if confirm_funcref != null:
		confirm_funcref.call_func(success_or_fail)

func _on_cancel_pressed():
	hide()
	if cancel_funcref != null:
		cancel_funcref.call_func()
