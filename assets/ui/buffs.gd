extends Node2D

var width = 400
var step = 75

func get_buff_tip(id, value, life):
	match id:
		0: return "奉献: 每回合损失%s点生命，增加%s点能量，还剩%s回合" % [value, value, life]
		1: return "抽牌: 每回合抽%s张牌，还剩%s回合" % [value, life]
		2: return "护盾: 每回合减少%s点伤害，还剩%s回合" % [value, life]
		3: return "回撤: 将伤害改为治愈，还剩%s回合" % life
		4: return "圣光: 每回合回复%s点生命，还剩%s回合" % [value, life]
		5: return "增幅: 伤害增加%s点，还剩%s回合" % [value, life]
		6: return "威能: 每回合增加%s点能量，还剩%s回合" % [value, life]
		7: return "灼烧: 每回合损失%s点生命，还剩%s回合" % [value, life]
		8: return "反弹: 攻击方将受到%s点伤害，还剩%s回合" % [value, life]
		9: return "弃牌: 每回合弃%s张牌，还剩%s回合" % [value, life]

func set_enable(enable):
	for node in self.get_children():
		node.enable = enable

func add_buff(id, value, life):
	var tip = get_buff_tip(id, value, life)
	if tip != null:
		var buff = load("res://assets/ui/buff.tscn").instance()
		buff.frame = id
		self.add_child(buff)
		buff.set_tips(tip)
		sort_out()
	
func remove_buff(i):
	var childs = []
	for node in self.get_children():
		if !node.is_queued_for_deletion():
			childs.push_back(node)
	childs[i].queue_free()
	sort_out()
	
func update_buff(i, value, life):
	var childs = []
	for node in self.get_children():
		if !node.is_queued_for_deletion():
			childs.push_back(node)
	var buff = childs[i]
	var tip = get_buff_tip(buff.frame, value, life)
	if tip != null:
		buff.set_tips(tip)

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
