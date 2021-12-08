
require "class"
local NFTs = require "cards/instances"

-- 玩家对象
local Player = class()

function Player:ctor(role, nfts, id, tabletop)
	self.id = id
	self.role = role
	self.tabletop = tabletop
	self.max_hp = Cfg.MAX_HP
	self.max_energy = Cfg.MAX_ENERGY
	self.hp = self.max_hp
	self.energy = 0
	self.untapped_count = 6
	self.master_card = assert(NFTs[role], "no role nft " .. role).new()
	self.custom_cards = {}
	self.active_cards = {}
	self.buffs = {}

	for _, hash in ipairs(nfts) do
		local nft = assert(NFTs[hash], "no nft " .. hash .. " from player " .. id)
		table.insert(self.custom_cards, nft.new())
	end
end

function Player:spell(which)
	local card = assert(self.active_cards[which], "spelling card " .. which .. " doesn't exist")
	local opposite = self.tabletop:other_player()
	card:apply(self, opposite)
	table.remove(self.active_cards, which)
	Emit("spell_end", self.id, which, card.hash)
end

function Player:spell_master()
	local opposite = self.tabletop:other_player()
	self.master_card:apply(self, opposite)
	Emit("spell_end", self.id, 0, self.master_card.hash)
end

function Player:draw(count)
	for _ = 1, count or 1 do
		if #self.custom_cards > 0 then
			local which = math.random(1, #self.custom_cards)
			local draw_card = self.custom_cards[which]
			table.remove(self.custom_cards, which)
			table.insert(self.active_cards, draw_card)
			Emit("draw", self.id, draw_card.hash)
		else
			break
		end
	end
end

function Player:undraw(count)
	for _ = 1, count or 1 do
		if #self.active_cards > 0 then
			local which = math.random(1, #self.active_cards)
			local draw_card = self.active_cards[which]
			table.remove(self.active_cards, which)
			Emit("undraw", self.id, which, draw_card.hash)
		else
			break
		end
	end
end

function Player:heal(value, caster)
	if value > 0 then
		value = self:apply_buffs(caster, value, "heal")
		self.hp = self.hp + value
		Emit("heal", self.id, self.hp)
	end
end

function Player:damage(value, caster, effect)
	if value > 0 then
		value = self:apply_buffs(caster, value, "damage")
		self.hp = self.hp - value
		Emit("damage", self.id, self.hp, effect or "firebomb")
	end
end

function Player:empower(value, caster)
	if value > 0 then
		value = self:apply_buffs(caster, value, "empower")
		self.energy = math.min(self.energy + value, self.max_energy)
		Emit("empower", self.id, self.energy)
	end
end

function Player:depower(value, caster)
	if value > 0 then
		value = self:apply_buffs(caster, value, "depower")
		self.energy = math.max(self.energy - value, 0)
		Emit("depower", self.id, self.energy)
	end
end

function Player:elapse_buffs()
	for i, buff in ipairs(self.buffs) do
		local alive = buff:elapse(i)
		if not alive then
			table.remove(self.buffs, i)
		end
	end
end

function Player:apply_buffs(caster, value, effect)
	for _, buff in ipairs(caster.buffs) do
		local apply = buff["effects." .. effect]
		if type(apply) == "function" then
			value = apply(buff, caster, self, value)
		end
	end
	for _, buff in ipairs(caster.kabletop:other_player().buffs) do
		local apply = buff["effects." .. effect]
		if type(apply) == "function" then
			value = apply(buff, caster, self, value)
		end
	end
	return value
end

function Player:draw_untapped(acting_player)
	self:draw(self.untapped_count)
	self.untapped_count = 0
	if acting_player ~= self.id then
		self.untapped_count = self.untapped_count + 1
	end
end

return Player
