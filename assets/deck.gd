extends Node2D

var upperbound = 40
var selected = 0
var selected_nfts = {}
var check_time = 0
var first_render = true

func _ready():
	Wait.set_wait(null, "加载卡牌中...")
	Sdk.get_owned_nfts(false)
	Sdk.connect("owned_nfts_updated", self, "on_owned_nfts_updated")
	get_node("/root").call_deferred("move_child", self, 0)

func on_owned_nfts_updated(nfts):
	# print(nfts)
	selected_nfts = {}
	selected = 0
	$status/selected.text = String(0)
	render_cards(nfts)

func render_cards(nfts_count):
	Wait.hide()
	if nfts_count.empty() and first_render:
		$issuance.show()
		first_render = false
	var anchor = $scroll/anchor
	for card in anchor.get_children():
		card.free()
	for _hash in Config.NFTs:
		var total = nfts_count.get(_hash)
		if total == null: total = 0
		var count = selected_nfts.get(_hash)
		if count == null: count = 0
		var card = load("res://assets/cards/ui.tscn").instance()
		card.set_info(Config.NFTs[_hash])
		card.set_count(count, total)
		anchor.add_child(card)

func click_button(button):
	if button == $confirm:
		if selected > upperbound:
			print("cards in deck beyond limit")
		else:
			var ok = false
			for _hash in selected_nfts:
				if selected_nfts[_hash] > 0:
					ok = true
					break
			if ok:
				Sdk.set_nfts(selected_nfts)
# warning-ignore:return_value_discarded
				get_tree().change_scene("res://title.tscn")
			else:
				Wait.set_manual_confirm("请至少选择一张卡牌", "操作失败:")
	elif button == $delete:
		if selected > 0:
			Wait.set_wait(null, null)
			var error = Sdk.delete_nfts(selected_nfts, funcref(Wait, "set_result"))
			if error != null:
				Wait.set_failed(error, null)
		else:
			Wait.set_manual_confirm("请至少选择一张卡牌", "操作失败:")
	else:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://title.tscn")

func click_card(_hash, change):
	selected = max(selected + change, 0)
	$status/selected.text = String(selected)
	if selected > upperbound:
		$status/selected.modulate = Color("ffff0000")
	else:
		$status/selected.modulate = Color("ffffffff")
	if !selected_nfts.has(_hash):
		selected_nfts[_hash] = 0
	selected_nfts[_hash] = max(selected_nfts[_hash] + change, 0)

func on_nft_issued(ok):
	if !ok:
		$issuance.show()

func _on_issue_pressed():
	$issuance.hide()
	var issue_nfts = {}
	for nft in Config.NFTs:
		issue_nfts[nft] = 10
	Wait.set_wait(funcref(self, "on_nft_issued"), null)
	Sdk.issue_nfts(issue_nfts, funcref(Wait, "set_result"))
