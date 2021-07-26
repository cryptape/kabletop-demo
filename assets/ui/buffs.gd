extends Node2D

var width = 400
var step = 75

var buffs_template = {
	0: "狮吼",
	1: "分身",
	2: "金钟罩",
	3: "激素",
	4: "圣光",
	5: "沉寂",
	6: "时间沙漏",
	7: "链接",
	8: "敏捷"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	add_buff(0, "")
	add_buff(1, "")
	add_buff(2, "")
	add_buff(3, "")
	add_buff(4, "")
	
func set_enable(enable):
	for node in self.get_children():
		node.enable = enable

func add_buff(id, params):
	var buff = load("res://assets/ui/buff.tscn").instance()
	buff.frame = id
	self.add_child(buff)
	sort_out()
	
func remove_buff(i):
	var buff = self.get_child(i)
	if buff != null:
		buff.free()
		sort_out()
	
func sort_out():
	var step_num = self.get_child_count() - 1
	for i in self.get_child_count():
		var x = (width - step_num * step) / 2 + i * step
		var buff = self.get_child(i)
		buff.position.x = x
