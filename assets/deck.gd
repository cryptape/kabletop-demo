extends Node2D

var upperbound = 40
var selected = 0
var selected_nfts = {}
var check_time = 0

func _ready():
	var owned_nfts = Sdk.get_owned_nfts()
	if owned_nfts != null:
		selected_nfts = Sdk.get_nfts()
		render_cards(owned_nfts)
	Sdk.connect("owned_nfts_updated", self, "on_owned_nfts_updated")

func on_owned_nfts_updated(nfts):
	selected_nfts = {}
	selected = 0
	$status/selected.text = String(0)
	render_cards(nfts)

func on_delete_nfts(error):
	if error != null:
		print(error)
		# 弹出提示

func render_cards(nfts_count):
	#print("total nfts: ", nfts_count)
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
			# 弹出提示
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
				print("no cards in deck")
				# 弹出提示
	elif button == $delete:
		Sdk.delete_nfts(selected_nfts, funcref(self, "on_delete_nfts"))
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
