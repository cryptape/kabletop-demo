extends Node2D

var width = 400
var step = 75

var buffs_template = {
	0: "狮吼",
	1: "分身",
	2: "金钟罩",
	3: "激素",
	4: "圣光：每回合恢复2点血量，还剩%s回合",
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
	if i < self.get_child_count():
		var buff = self.get_child(i)
		if buff != null:
			buff.free()
			sort_out()
	else:
		print("remove_buff ", i, " fail")
	
func update_buff(i, life):
	if i < self.get_child_count():
		var buff = self.get_child(i)
		if buff != null:
			buff.set_tips(buffs_template[buff.frame] % life)
	else:
		print("update_buff ", i, " fail")

func sort_out():
	var step_num = self.get_child_count() - 1
	for i in self.get_child_count():
		var x = (width - step_num * step) / 2 + i * step
		var buff = self.get_child(i)
		buff.position.x = x
