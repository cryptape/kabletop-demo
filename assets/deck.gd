extends Node2D

var upperbound = 40
var selected = 0
var selected_nfts = {}
var check_time = 0

func _ready():
	var owned_nfts = Sdk.get_owned_nfts()
	if owned_nfts != null:
		render_cards(owned_nfts)
	else:
		Sdk.connect("nfts_loaded", self, "render_cards")

func render_cards(nfts_count):
	print("total nfts: ", nfts_count)
	var anchor = $scroll/anchor
	for card in anchor.get_children():
		card.free()
	for _hash in Config.NFTs:
		var count = nfts_count.get(_hash)
		if count == null:
			count = 0
		var card = load("res://assets/cards/ui.tscn").instance()
		card.set_info(Config.NFTs[_hash])
		card.set_count(count)
		anchor.add_child(card)

func click_button(button):
	if button == $confirm:
		if selected > upperbound:
			print("cards in deck beyond limit")
			# 弹出提示
		else:
			var hashes = []
			for _hash in selected_nfts:
				for _i in selected_nfts[_hash]:
					hashes.push_back(_hash)
			if hashes.empty():
				print("no cards in deck")
			else:
				Sdk.set_nfts(hashes)
	else:
		print("return to parent page")

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
