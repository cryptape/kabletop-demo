extends Node2D

var current_client = null

func _ready():
	Wait.set_wait(null, "加载客户端列表中...")
	get_node("/root").call_deferred("move_child", self, 0)
	Sdk.fetch_clients_from_relay(funcref(self, "on_fetch_clients"))
	Sdk.connect("connect_status", self, "_on_connect_status")

func _on_connect_status(mode, status):
	if mode == "CLIENT" and status == false:
		Wait.set_manual_cancel(
			"与中转服务器断开连接，点击[取消]按钮回到主界面",
			"网络连接错误:",
			funcref(self, "on_return")
		)
	elif mode == "PARNTER" and status == false:
		Wait.set_manual_cancel(
			"对手客户端已断开连接", "连接失败:", funcref(self, "on_return")
		)

func light_color(a):
	$select_info.set("custom_colors/font_color", Color(1, 1, 1, a))

func on_fetch_clients(ok, error_or_clients):
	if ok:
		render_clients(error_or_clients)
	else:
		Wait.set_manual_cancel(
			error_or_clients, "获取客户端列表失败：", funcref(self, "on_return")
		)

func on_return():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://relay.tscn")

func on_channel_opened(ok):
	if ok:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://main.tscn")

func render_clients(clients):
	Wait.hide()
	var anchor = $scroll/anchor
	for client in clients:
		var node = load("res://assets/relay/client.tscn").instance()
		anchor.add_child(node)
		node.set_info(client)

func enter_client(client):
	var nickname = client.client_info.nickname
	var staking_ckb = client.client_info.staking_ckb
	var bet_ckb = client.client_info.bet_ckb
	$select_info.text = "%s  (%d/%d)" % [nickname, staking_ckb, bet_ckb]
	if current_client == client:
		light_color(1)
	else:
		light_color(0.2)

func leave_client(_client):
	if current_client == null:
		light_color(0)
	else:
		enter_client(current_client)

func choose_client(client):
	if current_client != null:
		current_client.lock_toggle()
		if current_client == client:
			light_color(0.2)
			current_client = null
		else:
			client.lock_toggle()
			light_color(1)
			current_client = client
	else:
		client.lock_toggle()
		light_color(1)
		current_client = client
	$confirm.get_node("click/rect").disabled = current_client == null
	
func click_button(button):
	var confirm = $confirm
	var cancel = $cancel
	match button:
		confirm:
			assert(current_client != null, "bad current_client var")
			Wait.set_wait(null, "开始尝试连接...")
			var error = Sdk.connect_client_via_relay(
				current_client.client_info.id,
				Config.player_name,
				Config.player_staking_ckb,
				Config.player_bet_ckb
			)
			if error != null:
				Wait.set_manual_cancel(
					error, "连接失败：", funcref(Wait, "hide")
				)
			else:
				Wait.set_wait(funcref(self, "on_channel_opened"), null)
				error = Sdk.create_channel(
					Config.player_staking_ckb,
					Config.player_bet_ckb,
					funcref(Wait, "set_result")
				)
				if error != null:
					Wait.set_failed(error, null)
		cancel:
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://relay.tscn")
