
require "class"
local NFTs = require "cards/instances"

-- 玩家对象
local Player = class()

function Player:ctor(role, nfts, id, tabletop)
	self.id = id
	self.tabletop = tabletop
	self.max_hp = Cfg.MAX_HP
	self.max_energy = Cfg.MAX_ENERGY
	self.hp = 0
	self.energy = 0
	self.master_card = assert(Cfg.ROLE_NFTS[role], "unknown role " .. role)
	self.custom_cards = {}
	self.active_cards = {}
	self.buffs = {}

	self.master_card = assert(NFTs[self.master_card], "no role nft " .. self.master_card).new()
	for _, hash in ipairs(nfts) do
		local nft = assert(NFTs[hash], "no nft " .. hash)
		table.insert(self.custom_cards, nft.new())
	end
end

function Player:spell(which)
	local card = assert(self.active_cards[which], "spelling card " .. which .. " doesn't exist")
	local opposite = self.tabletop[self.tabletop:other_player()]
	card:apply(self, opposite)
	table.remove(self.active_cards, which)
end

function Player:spell_master()
	local opposite = self.tabletop[self.tabletop:other_player()]
	self.master_card:apply(self, opposite)
end

function Player:draw()
	local which = math.random(1, #self.custom_cards)
	local draw_card = self.custom_cards[which]
	table.remove(self.custom_cards, which)
	table.insert(self.active_cards, draw_card)
	Emit("draw_card", self.id, draw_card.hash)
end

function Player.round_end(round)
	
end

function Player:round_start(round)
	
end

return Player
