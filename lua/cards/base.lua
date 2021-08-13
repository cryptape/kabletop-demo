
require "class"

local card = class()

function card:ctor()
	self.hash = ""
	self.cost = 0
	self.caster_effects = {}
	self.opposite_effects = {}
	self.caster_buffs = {}
	self.opposite_buffs = {}
end

function card:apply(caster, opposite)
	assert(caster.energy >= self.cost, "insufficient energy cost " .. self.cost .. " from " .. self.hash)
	caster.energy = caster.energy - self.cost
	Emit("cost", caster.id, caster.energy)
	for _, effect in ipairs(self.caster_effects) do
		assert(type(effect) == "function", "caster_effect in " .. self.hash .. " has non-function type")
		effect(caster)
	end
	for _, effect in ipairs(self.opposite_effects) do
		assert(type(effect) == "function", "opposite_effect in " .. self.hash .. " has non-function type")
		effect(opposite)
	end
	for _, buff in ipairs(self.caster_buffs) do
		assert(type(buff) == "table", "caster_buff in " .. self.hash .. " has non-table type")
		table.insert(caster.buffs, buff)
		Emit("buff", caster.id, buff.id, 0, buff.life)
	end
	for _, buff in ipairs(self.opposite_buffs) do
		assert(type(buff) == "table", "opposite_buff in " .. self.hash .. " has non-table type")
		table.insert(opposite.buffs, buff)
		Emit("buff", opposite.id, buff.id, 0, buff.life)
	end
end

return card
