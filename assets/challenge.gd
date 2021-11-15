extends Node2D

var current_unit = null

func _ready():
	Wait.set_wait(null, "加载挑战列表中...")
	get_node("/root").call_deferred("move_child", self, 0)
	Sdk.get_uncomplete_kabletop_caches(funcref(self, "on_fetch_logs"))

func on_fetch_logs(ok, error_or_units):
	if ok:
		render_units(error_or_units)
	else:
		Wait.set_manual_cancel(
			error_or_units, "获取挑战列表失败：", funcref(self, "on_return")
		)

func on_return(ok = true):
	if ok:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://title.tscn")
	
func render_units(units):
	Wait.hide()
	var anchor = $scroll/anchor
	for unit in units:
		var node = load("res://assets/ui/challenge/unit.tscn").instance()
		anchor.add_child(node)
		node.set_info(unit)

func choose_unit(unit):
	if current_unit != null:
		current_unit.lock_toggle()
		if current_unit == unit:
			current_unit = null
		else:
			unit.lock_toggle()
			current_unit = unit
	else:
		unit.lock_toggle()
		current_unit = unit
	$confirm.get_node("click/rect").disabled = current_unit == null
	
func click_button(button):
	var confirm = $confirm
	var cancel = $cancel
	match button:
		confirm:
			assert(current_unit != null, "bad current_unit var")
			if current_unit.close_enable:
				Wait.set_wait(funcref(self, "on_return"), null)
				Sdk.close_channel(true, funcref(Wait, "set_result"))
			else:
				var error = Sdk.replay(current_unit.info.script_hash)
				if error != null:
					Wait.set_manual_cancel(
						error, "战斗数据重放失败：", funcref(Wait, "hide")
					)
				else:
					Config.challenge_mode = true
					Config.challenge_info = current_unit.info
# warning-ignore:return_value_discarded
					get_tree().change_scene("res://main.tscn")
		cancel:
			on_return()
