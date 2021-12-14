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

var native_mode = true
var challenge_mode = false
var challenge_info = null
var last_owned_nfts = {}

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
	1: Card.generate(1, "魔法预言", 2, "回合结束时，抽1张牌"),
	2: Card.generate(0, "百裂斩", 3, "造成2点伤害，对手损失2点能量"),
	3: Card.generate(3, "天使恩泽", 0, "增加3点能量，对手回复2点生命"),
	4: Card.generate(2, "恶魔契约", 0, "消耗2点生命，增加3点能量")
}

var NFTs = {
	"10ad3f5012ce514f409e4da4c011c24a31443488":
		Card.generate(0, "充能", 0, "增加2点能量"),
	"d046a18f7e01cb42e911fae2f11ba60c9c6834f8":
		Card.generate(1, "火炼真金", 3, "维持3回合，每回合增加3点能量"),
	"f37dfa5b009ea001acd3617886d9efecf31bb153":
		Card.generate(2, "能量流失", 2, "双方损失当前所有能量"),
	"97bff01bcad316a4b534ef221bd66da97018df90":
		Card.generate(3, "心灵净化", 4, "回复3点生命，抽1张牌"),
	"36248218d2808d668ae3c0d35990c12712f6b9d2":
		Card.generate(4, "气血暴怒", 0, "消耗2点生命，增加4点能量"),
	"f49ac4925959733cc4c2b3a2663bde8c27b8dde2":
		Card.generate(5, "嗜血", 6, "回复5点生命，造成5点伤害"),
	"cbbbfff040366f8d4d8f4eef22f9711a561c1fb5":
		Card.generate(6, "雷鸣", 2, "造成3点伤害"),
	"9285def08d45c203d83e13c5363627b8e95b3675":
		Card.generate(7, "兵器上缴", 0, "回合结束前，造成的所有伤害改为回复等额生命"),
	"d392835f312304530091d6ee6d833b35f7a0aa0b":
		Card.generate(8, "大开杀戒", 6, "造成10点伤害"),
	"635552d615f0c2fa17cdc68307dc154c957e3d60":
		Card.generate(9, "火刃", 3, "消耗3点生命。回合结束前，造成的伤害增加3点"),
	"ef28b677015404f9ee466b950d880f6d78709ef1":
		Card.generate(10, "内力穿透", 5, "造成3点伤害，对手随机损失2个BUFF，每个BUFF造成2点伤害"),
	"cd58caae1dd06b8074cc55283dabfb7c8df784a7":
		Card.generate(11, "冥想", 5, "回复3点生命。维持3回合，每回合回复2点生命"),
	"f9c2d5a3d7eba0bcd7973ae48c5db7937c363547":
		Card.generate(12, "能量溢出", 0, "增加4点能量。回合结束前，对手增加3点能量"),
	"68db1cc5dd2707bc19588c228cd8771efebe44c8":
		Card.generate(13, "意外打击", 2, "对手损失所有能量，然后抽1张牌"),
	"c0286f74c4d3c2200c9a035e06c856a5a5033996":
		Card.generate(14, "副作用面具", 0, "增加5点能量，对手抽1张牌"),
	"032d5e638aefed495dc3ae293cd5001c516743b3":
		Card.generate(15, "智力游戏", 6, "回复2点生命，抽2张牌"),
	"ea2ee2ac39fa0794f8ab4987827d93517430a745":
		Card.generate(16, "武力萃取", 1, "对手增加3点能量。回合结束前，造成的伤害增加2点"),
	"d81488bff2b05b434abf93c4e604235ada1850a9":
		Card.generate(17, "史莱姆袭击", 2, "随机弃1张牌，造成6点伤害"),
	"4a19d1b5ddf31214c01cd93e3314c8bbdf02d717":
		Card.generate(18, "刀枪不入", 4, "持续2回合，每回合增加1点能量，受到的伤害减少2点"),
	"fde2a70cffa777c0fc53c29aae1452c17147feb2":
		Card.generate(19, "龙熄", 3, "造成5点伤害"),
	"112c40c02594af5565e4a1c453b3f2f1d1b34a15":
		Card.generate(20, "凌波微步", 3, "抽2张牌。回合结束时，随机弃1张牌"),
	"728a75f3491586bda7731612699e0a816d9b9c7f":
		Card.generate(21, "迷惑之眼", 3, "对手随机弃1张牌"),
	"b6d0f5c53b968052fb29d7c98a82e1b89af86b93":
		Card.generate(22, "泄气", 3, "对手损失5点能量"),
	"49f11bf3811b5316a4f64bc60f1f9e2db7658be5":
		Card.generate(23, "生命培育", 6, "回复10点生命"),
	"81074da205515c650e4408a38bdfbabf455d9eb0":
		Card.generate(24, "毁天灭地", 4, "双方损失所有能量和身上所有BUFF"),
	"1dac1c52818c97477b46f8e38514f8a4bd2e935e":
		Card.generate(25, "火焰灼烧", 0, "消耗4点生命，增加4点能量, 抽1张牌"),
	"00d16eec4f9aa41e28a7a9c8af1006e9f0697725":
		Card.generate(26, "精神失控", 3, "消耗3点生命，抽2张牌"),
	"5ceb75a6a1990b6fde9f6c3d9d7b9731c630630a":
		Card.generate(27, "圣剑士的意志", 5, "维持3回合，每回合抽1张牌"),
	"ec7f0ebf2ddcc1a04aa0ca8ee85be4020fd62c64":
		Card.generate(28, "关键零件", 3, "抽1张牌"),
	"66b7fc8a970de2b83eb01720d51dc04b08ffdaba":
		Card.generate(29, "邪魔的恩赐", 0, "增加10点能量。回合结束时，随机弃2张牌"),
	"8ba97786d1e7db828553c318fc71ff5bd40af323":
		Card.generate(30, "天使的恩赐", 10, "回复10点生命，抽3张牌"),
	"f2fe97371461754207c64f9c64eb2b2589774bfc":
		Card.generate(31, "充能闪电", 1, "消耗2点生命。维持4回合，每回合增加2点能量"),
	"ac74824a6c938ad7b83a1380d75862a420cdfe1a":
		Card.generate(32, "被动防御", 4, "维持2回合，每回合回复2点生命，受到的伤害减少2点"),
	"759df03dda3c6303aa06252854cd5398166140bb":
		Card.generate(33, "替身攻击", 6, "造成4点伤害，对手随机弃1张牌"),
	"9be947ba34ce065abc78ad594e0683c537665cfd":
		Card.generate(34, "武器上供", 2, "随机清除身上1个BUFF，如果成功，则抽1张牌"),
	"0462272b1dc6137c3b4f22c5d08b47da6cb9d3c1":
		Card.generate(35, "盲目愉悦", 3, "每拥有1个BUFF就回复3点生命，清除身上所有BUFF"),
	"ad78dd763e70b8b89a41f4a0ff34896d5447513e":
		Card.generate(36, "灵能攫取", 2, "随机清除对手身上1个BUFF，如果成功，则造成3点伤害"),
	"373efffe4f0fb741c00bf95864a83d85c26b4662":
		Card.generate(37, "弱点分析", 5, "对手损失3点能量，然后随机弃1张牌"),
	"657f232232088ef1b1dbc3ecbd07ba9d18844d7a":
		Card.generate(38, "献祭", 3, "每拥有1个BUFF就造成3点伤害，清除身上所有BUFF"),
	"f7b00790c41297fc095228d3b23e6510fba69258":
		Card.generate(39, "反射护罩", 4, "维持2回合，当受到攻击时，造成3点伤害"),
}

func _ready():
	for _hash in NFTs:
		NFTs[_hash]._hash = _hash

func reset_vars():
	Config.game_ready = false
	Config.opposite_ready_func = null
	Config.challenge_mode = false
	Config.challenge_info = null
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
