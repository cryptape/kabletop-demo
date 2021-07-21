extends Node

class Card:
	var icon = 0
	var name = ""
	var cost = 0
	var description = ""
	static func generate(icon, name, cost, desc):
		var card = Card.new()
		card.icon = icon
		card.name = name
		card.cost = cost
		card.description = desc
		return card

var NativeNFTs = {
	1: Card.generate(0, "破壁", 4, "3个回合之内，对方受到的所有伤害x2"),
	2: Card.generate(1, "嗜血", 4, "造成3点伤害，恢复3点血量"),
	3: Card.generate(2, "火焰匕首", 1, "造成3点伤害，对自己造成1点伤害"),
	4: Card.generate(3, "超充", 0, "对自己造成3点伤害，增加3点能量")
}

var NFTs = {
	"b9aaddf96f7f5c742950611835c040af6b7024ad":
		Card.generate(0, "充能", 0, "增加2点能量"),
	"10ad3f5012ce514f409e4da4c011c24a31443488":
		Card.generate(1, "光明", 3, "恢复4点血量"),
	"f37dfa5b009ea001acd3617886d9efecf31bb153":
		Card.generate(2, "毒瘴", 2, "对自己造成3点伤害，抽一张牌"),
	"97bff01bcad316a4b534ef221bd66da97018df90":
		Card.generate(3, "心灵净化", 5, "恢复2点血量，抽一张牌"),
	"7375f9e28095638cb5761795f3d67fae1837129b":
		Card.generate(6, "雷鸣", 2, "造成3点伤害"),
	"f49ac4925959733cc4c2b3a2663bde8c27b8dde2":
		Card.generate(7, "缴械", 4, "下个回合，对方无法对自己施放攻击卡牌"),
}

func get_card(_hash):
	var nft = NFTs[_hash]
	assert(nft != null, "unknown nft hash " + _hash)
	return nft
	
func get_native_card(role):
	var nft = NativeNFTs[role]
	assert(nft != null, "unknown role " + String(role))
	return nft
