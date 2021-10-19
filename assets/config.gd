extends Node

class Card:
	var icon = 0
	var name = ""
	var cost = 0
	var description = ""
	var _hash = ""
	static func generate(_icon, _name, _cost, _desc):
		var card = Card.new()
		card.icon = _icon
		card.name = _name
		card.cost = _cost
		card.description = _desc
		return card

var native_mode = false

var player_hero = 0
var player_name = ""
var player_staking_ckb = 0
var player_bet_ckb = 0

var opposite_hero = 0
var opposite_name = ""
var opposite_staking_ckb = 0
var opposite_bet_ckb = 0

var game_ready = false
var opposite_ready_func = null

var HeroNames = {
	0: "Unknown",
	1: "Cultist",
	2: "Ironclad",
	3: "Chosen",
	4: "Silent"
}

var NativeNFTs = {
	1: Card.generate(0, "破壁", 2, "随机去掉对方一个BUFF，如果成功则恢复2点血量"),
	2: Card.generate(1, "嗜血", 4, "造成3点伤害，恢复3点血量"),
	3: Card.generate(2, "火焰匕首", 1, "造成3点伤害，对自己造成1点伤害"),
	4: Card.generate(3, "超充", 0, "对自己造成3点伤害，增加3点能量")
}

var NFTs = {
	"10ad3f5012ce514f409e4da4c011c24a31443488":
		Card.generate(0, "充能", 0, "增加2点能量"),
	"d046a18f7e01cb42e911fae2f11ba60c9c6834f8":
		Card.generate(1, "光明", 5, "圣光3: 持续3回合，每回合结束时恢复2点血量"),
	"f37dfa5b009ea001acd3617886d9efecf31bb153":
		Card.generate(2, "毒瘴", 2, "对自己造成3点伤害，抽一张牌"),
	"97bff01bcad316a4b534ef221bd66da97018df90":
		Card.generate(3, "心灵净化", 5, "恢复2点血量，抽一张牌"),
	"36248218d2808d668ae3c0d35990c12712f6b9d2":
		Card.generate(6, "雷鸣", 2, "造成10点伤害"),
	"f49ac4925959733cc4c2b3a2663bde8c27b8dde2":
		Card.generate(4, "内力觉醒", 4, "金钟罩3: 持续3回合，最多吸收10点伤害，消失后恢复吸收伤害的生命值"),
}

func _ready():
	for _hash in NFTs:
		NFTs[_hash]._hash = _hash

func reset_game_ready():
	Config.game_ready = false
	Config.opposite_ready_func = null
	Sdk.reply_p2p_message("game_ready", funcref(self, "_on_p2p_game_ready"))

func get_card(card_hash):
	var nft = NFTs[card_hash]
	assert(nft != null, "unknown nft hash " + card_hash)
	return nft
	
func get_native_card(role):
	var nft = NativeNFTs[role]
	assert(nft != null, "unknown role " + String(role))
	return nft
	
func get_hero_name():
	return HeroNames[player_hero]
	
func _on_p2p_game_ready(_parameters):
	if opposite_ready_func != null:
		opposite_ready_func.call_func()
	return {
		"ready": game_ready
	}
