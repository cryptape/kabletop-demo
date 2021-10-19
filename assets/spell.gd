extends Area2D

onready var special = $"../cards/special"
onready var custom = $"../cards/custom"
onready var controller = $"/root/controller"
onready var settlement = controller.get_node("settlement")

var ID_ONE = 1
var ID_TWO = 2
var EVENT_QUEUE = []

var MY_ID = 0
var OPPOSITE_ID = 0

func _ready():
	special.connect("special_card_spelled", self, "on_special_card_spelled")
	custom.connect("custom_card_spelled", self, "on_custom_card_spelled")
	Sdk.connect("connect_status", self, "_on_sdk_connect_status")
	Sdk.connect("lua_events", self, "_on_sdk_lua_events")
	Sdk.connect("p2p_message_reply", self, "_on_sdk_p2p_message_reply")
	
	controller.player_id = Sdk.get_player_id()
	if controller.player_id == ID_ONE:
		controller.opposite_id = ID_TWO
	else:
		controller.opposite_id = ID_ONE
	controller.set_player_name(controller.player_id, Config.player_name)
	controller.set_player_role(controller.player_id, Config.player_hero)
	controller.set_deck_capcacity(ID_ONE, Sdk.get_nfts_count(ID_ONE))
	controller.set_deck_capcacity(ID_TWO, Sdk.get_nfts_count(ID_TWO))
	Config.game_ready = true
	Sdk.reply_p2p_message("start_game", funcref(self, "_on_p2p_start_game"))
	Sdk.send_p2p_message("game_ready", {})
	
func _process(_delta):
	if !EVENT_QUEUE.empty():
		for event in EVENT_QUEUE:
			match event.call_func:
				"run": Sdk.run(event.code)
				"close_game": Sdk.close_game(event.winner, event.callback)
				"set_round": Sdk.set_round(event.count, event.owner)
				"sync": Sdk.sync(event.code, event.close_round, event.callback)
				"p2p": Sdk.send_p2p_message(event.message, event.value)
		EVENT_QUEUE = []
	
func on_special_card_spelled(_card):
	assert(controller.acting_player_id == controller.player_id)
	run("game:spell_card(0)")

func on_custom_card_spelled(card):
	assert(controller.acting_player_id == controller.player_id)
	var offset = 0
	for child in card.get_parent().get_children():
		offset += 1
		if child == card:
			break
	run("game:spell_card(%d)" % offset)

func run(code):
	EVENT_QUEUE.push_back({
		call_func = "run",
		code = "Emit('sync', 0, '%s')\n" % code + code
	})
	
func switch_round():
	var code = "game:switch_round()"
	EVENT_QUEUE.push_back({
		call_func = "run",
		code = "Emit('sync', 1, '%s')\n" % code + code
	})
	
func game_over(ok, winner_or_error):
	if ok:
		settlement.winner = winner_or_error
		controller.set_battle_result(
			controller.acting_player_id, funcref(settlement, "show_settlement")
		)
	else:
		Wait.set_manual_cancel(
			winner_or_error,
			"游戏关闭失败:",
			funcref(self, "on_cancel_game")
		)

func on_sync(ok, error):
	if !ok:
		Wait.set_manual_cancel(
			error,
			"操作同步失败:",
			funcref(self, "on_cancel_game")
		)
	
func new_round(round_owner, round_count, last_owner):
	controller.set_acting_player(round_owner)
	controller.set_round(round_count)
	controller.apply_change(last_owner)
	controller.round_switching = false
	
func _on_sdk_lua_events(events):
	for params in events:
		var event = params[0]
		var player_id = params[1]
		match event:
			"init":
				var init_hp = params[2]
				controller.set_player_hp(ID_ONE, init_hp, false)
				controller.set_player_hp(ID_TWO, init_hp, false)
				EVENT_QUEUE.push_back({
					call_func = "set_round",
					count = 1,
					owner = player_id
				})
			"sync":
				var close_round = (player_id == 1)
				var lua_code = params[2]
				EVENT_QUEUE.push_back({
					call_func = "sync",
					code = lua_code,
					close_round = close_round,
					callback = funcref(self, "on_sync")
				})
			"draw":
				var card_hash = params[2]
				controller.add_player_card(player_id, card_hash)
			"damage":
				var hp = params[2]
				var effect = params[3]
				controller.set_player_hp(player_id, hp)
				controller.damage_player(player_id, effect)
			"heal":
				var hp = params[2]
				controller.set_player_hp(player_id, hp)
				controller.heal_player(player_id)
			"empower", "cost":
				var energy = params[2]
				controller.set_player_energy(player_id, energy)
			"strip":
				var buffs = params[2]
				print("strip buffs = ", buffs)
			"buff":
				var id = params[2]
				var offset = params[3]
				var life = params[4]
				if offset <= 0:
					controller.add_player_buff(player_id, id, life)
				else:
					controller.update_player_buff(player_id, offset - 1, life)
			"spell_end":
				var card_offset = params[2] - 1
				var hash_code = params[3]
				controller.apply_change(player_id, card_offset, hash_code)
			"new_round":
				var current_round = params[2]
				var last_player = params[3]
				if current_round > 1:
					controller.switch_round(
						last_player, funcref(self, "new_round"),
						[player_id, current_round, last_player]
					)
				else:
					new_round(player_id, current_round, last_player)
				EVENT_QUEUE.push_back({
					call_func = "set_round",
					count = current_round,
					owner = player_id
				})
			"game_over":
				EVENT_QUEUE.push_back({
					call_func = "close_game",
					winner = player_id,
					callback = funcref(self, "game_over")
				})
			_:
				assert(false, "unknown event " + event)

func _on_sdk_connect_status(mode, status):
	if !status and !controller.battle_finished:
		if mode == "PARTNER":
			Wait.set_manual_cancel(
				"匹配节点已掉线，点击[取消]按钮回到主界面",
				"网络连接错误:",
				funcref(self, "on_cancel_partner")
			)
		else:
			var content = ""
			if Config.native_mode:
				content = "匹配节点已掉线，点击[取消]按钮回到主界面"
			else:
				content = "与中转服务器断开连接，点击[取消]按钮回到主界面"
			Wait.set_manual_cancel(
				content, "网络连接错误:", funcref(self, "on_cancel_game")
			)

func on_cancel_game():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://title.tscn")
	
func on_cancel_partner():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://relay.tscn")

func _on_sdk_p2p_message_reply(message, parameters):
	match message:
		"game_ready":
			if controller.player_id == ID_ONE:
				if parameters["ready"]:
					on_opposite_ready()
				else:
					Config.opposite_ready_func = \
						funcref(self, "on_opposite_ready")
		"start_game":
			controller.get_node("wait").hide()
			Config.opposite_hero = parameters["role"]
			Config.opposite_name = parameters["name"]
			assert(Config.opposite_hero > 0)
			controller.set_player_role(
				controller.opposite_id, Config.opposite_hero
			)
			controller.set_player_name(
				controller.opposite_id, Config.opposite_name
			)
			run("Init()")
			run("game = Tabletop.new(%d, %d)" % [
				Config.player_hero, Config.opposite_hero
			])

func _on_p2p_start_game(parameters):
	print("calling _on_p2p_start_game")
	controller.get_node("wait").hide()
	Config.opposite_hero = parameters["role"]
	Config.opposite_name = parameters["name"]
	controller.set_player_role(
		controller.opposite_id, Config.opposite_hero
	)
	controller.set_player_name(
		controller.opposite_id, Config.opposite_name
	)
	return {
		"role": Config.player_hero,
		"name": Config.player_name
	}

func on_opposite_ready():
	EVENT_QUEUE.push_back({
		call_func = "p2p",
		message = "start_game",
		value = {
			"role": Config.player_hero,
			"name": Config.player_name
		}
	})
