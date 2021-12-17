
require "class"
local NFTs = require "cards/instances"

function table.clone(value)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for k, v in pairs(object) do
            new_table[_copy(k)] = _copy(v)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(value)
end

function table.join(base, object)
    for _, value in ipairs(object) do
        table.insert(base, value)
    end
end

local function walk_buffs(buffs, alived_buffs)
	for i, buff in ipairs(buffs) do
		local alive = buff:elapse(#alived_buffs + i)
		if alive then
            local alived = table.remove(buffs, i)
            table.insert(alived_buffs, alived)
        else
			table.remove(buffs, i)
            walk_buffs(buffs, alived_buffs)
		end
	end
end

-- 玩家对象
local Player = class()

function Player:ctor(role, nfts, id, tabletop)
	assert(NFTs[role], "no role nft " .. role)
	self.id = id
	self.role = role
	self.tabletop = tabletop
	self.max_hp = Cfg.MAX_HP
	self.max_energy = Cfg.MAX_ENERGY
	self.hp = self.max_hp
	self.energy = 0
	self.untapped_count = 5
	self.master_enable = true
	self.custom_cards = {}
	self.active_cards = {}
	self.buffs = {}

	for _, hash in ipairs(nfts) do
		local nft = assert(NFTs[hash], "no nft " .. hash .. " from player " .. id)
		table.insert(self.custom_cards, table.clone(nft.new()))
	end
end

function Player:spell(which)
	local card = assert(self.active_cards[which], "spelling card " .. which .. " doesn't exist")
	local opposite = self.tabletop:other_player()
	table.remove(self.active_cards, which)
	card:apply(self, opposite)
	Emit("spell_end", self.id, which, card.hash)
end

function Player:spell_master()
	assert(self.master_enable, "one round for one chance of spelling master card")
	self.master_enable = false
	local opposite = self.tabletop:other_player()
	local master_card = table.clone(NFTs[self.role].new())
	master_card:apply(self, opposite)
	Emit("spell_end", self.id, 0, master_card.hash)
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
    local alived_buffs = {}
    walk_buffs(self.buffs, alived_buffs)
    self.buffs = alived_buffs
end

function Player:apply_buffs(caster, value, effect)
	if caster == nil then
		caster = self
	end
	for _, buff in ipairs(caster.buffs) do
		local apply = buff["effects." .. effect]
		if type(apply) == "function" then
			value = apply(buff, caster, self, value)
		end
	end
	for _, buff in ipairs(caster.tabletop:other_player().buffs) do
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

function Player:switch_to()
	self:empower(1)
	self.master_enable = true
end

return Player
