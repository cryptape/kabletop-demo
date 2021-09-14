extends Node2D

var width = 400
var step = 75

var buffs_template = {
	0: "狮吼",
	1: "分身",
	2: "金钟罩：总共吸收10点伤害，消失后将用于恢复生命值，剩余%s回合",
	3: "激素",
	4: "圣光：回合结束时恢复2点血量，剩余%s回合",
	5: "沉寂",
	6: "时间沙漏",
	7: "链接",
	8: "敏捷"
}

func set_enable(enable):
	for node in self.get_children():
		node.enable = enable

func add_buff(id, life):
	assert(buffs_template[id] != null)
	var buff = load("res://assets/ui/buff.tscn").instance()
	buff.frame = id
	self.add_child(buff)
	buff.set_tips(buffs_template[id] % life)
	sort_out()
	
func remove_buff(i):
	self.get_child(i).queue_free()
	sort_out()
	
func update_buff(i, life):
	var buff = self.get_child(i)
	buff.set_tips(buffs_template[buff.frame] % life)

func sort_out():
	var valid_children = []
	for node in self.get_children():
		if !node.is_queued_for_deletion():
			valid_children.push_back(node)
	var step_num = valid_children.size() - 1
	for i in valid_children.size():
		var x = (width - step_num * step) / 2 + i * step
		var buff = valid_children[i]
		buff.position.x = x
