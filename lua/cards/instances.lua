
local base = require "cards/base"
local effects = require "cards/effects"

local function pack(...)
	return table.pack(...)
end

local function generate(cost, caster_effects, opposite_effects)
	return { 
		cost = cost,
		caster_effects = caster_effects,
		opposite_effects = opposite_effects
	}
end

local templates = {
	-- 增强
	["b9aaddf96f7f5c742950611835c040af6b7024ad"] = generate(
		0, pack(effects.empower(1)), nil
	),
	-- 速攻
	["97bff01bcad316a4b534ef221bd66da97018df90"] = generate(
		2, nil, pack(effects.damage(2, "deathfire"))
	),
	-- Silent 超充
	["36248218d2808d668ae3c0d35990c12712f6b9d2"] = generate(
		0, pack(effects.damage(3, "bluefire"), effects.empower(3)), nil
	),
	-- Cultist 燕返
	["f37dfa5b009ea001acd3617886d9efecf31bb153"] = generate(
		2, nil, pack(effects.damage(4, "bomb"), effects.draw(1))
	),
}

local instances = {}

for hash, template in pairs(templates) do
	instances[hash] = class(base)
	instances[hash].ctor = function (self)
		self.hash = hash
		self.cost = template.cost or 0
		self.caster_effects = template.caster_effects or {}
		self.opposite_effects = template.opposite_effects or {}
	end
end

return instances
