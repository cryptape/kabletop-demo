
require "class"

local card = class()

function card:ctor()
	self.hash = ""
	self.cost = 0
	self.caster_effects = {}
	self.opposite_effects = {}
end

function card:apply(caster, opposite)
	assert(caster.energy >= self.cost, "insufficient energy cost " .. self.cost .. " from " .. self.hash)
	caster.energy = caster.energy - self.cost
	for _, effect in ipairs(self.caster_effects) do
		assert(type(effect) == "function", "caster_effect in " .. self.hash .. " has non-function type")
		effect(caster)
	end
	for _, effect in ipairs(self.opposite_effects) do
		assert(type(effect) == "function", "opposite_effect in " .. self.hash .. " has non-function type")
		effect(opposite)
	end
end

return card
