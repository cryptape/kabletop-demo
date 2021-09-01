extends Node2D

var confirm_funcref = null
var cancel_funcref = null
var success_or_fail = null

func set_wait(callback, text):
	if text == null:
		text = "交易提交中..."
	$panel/title.text = text
	$panel/confirm.hide()
	$panel/cancel.hide()
	$panel/hash.hide()
	$panel/waiting.show()
	confirm_funcref = callback
	success_or_fail = null
	show()
	
func set_result(ok, hash_or_error):
	if ok:
		set_commited(hash_or_error, null)
	else:
		set_failed(hash_or_error, null)

func set_commited(tx_hash, text):
	if text == null:
		text = "交易提交完成:"
	$panel/title.text = text
	$panel/hash.text = tx_hash
	$panel/hash.show()
	$panel/confirm.show()
	$panel/waiting.hide()
	$panel/cancel.hide()
	success_or_fail = true
	
func set_failed(error, text):
	if text == null:
		text = "交易提交失败:"
	$panel/title.text = text
	$panel/hash.text = error
	$panel/hash.show()
	$panel/confirm.show()
	$panel/waiting.hide()
	$panel/cancel.hide()
	success_or_fail = false

func set_manual_cancel(info, title, callback):
	$panel/title.text = title
	$panel/hash.text = info
	$panel/hash.show()
	$panel/cancel.show()
	$panel/waiting.hide()
	$panel/confirm.hide()
	cancel_funcref = callback

func _on_confirm_pressed():
	hide()
	if confirm_funcref != null:
		confirm_funcref.call_func([success_or_fail])

func _on_cancel_pressed():
	hide()
	if cancel_funcref != null:
		cancel_funcref.call_func()