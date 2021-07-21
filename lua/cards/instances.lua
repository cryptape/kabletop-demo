
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
	-- Chosen 破壁
	[1] = generate(
		0, nil, nil
	),
	-- Cultist 嗜血
	[2] = generate(
		4, pack(effects.heal(3)), pack(effects.damage(3, "bomb"))
	),
	-- Ironclad 火焰匕首
	[3] = generate(
		1, pack(effects.damage(1, "bluefire")), pack(effects.damage(3, "bluefire"))
	),
	-- Silent 超充
	[4] = generate(
		0, pack(effects.damage(3, "firebomb"), effects.empower(3)), nil
	),
	-- 充能
	["b9aaddf96f7f5c742950611835c040af6b7024ad"] = generate(
		0, pack(effects.empower(2)), nil
	),
	-- 光明
	["10ad3f5012ce514f409e4da4c011c24a31443488"] = generate(
		3, pack(effects.heal(4)), nil
	),
	-- 毒瘴
	["f37dfa5b009ea001acd3617886d9efecf31bb153"] = generate(
		2, pack(effects.damage(3, "firebomb"), effects.draw(1)), nil
	),
	-- 心灵净化
	["97bff01bcad316a4b534ef221bd66da97018df90"] = generate(
		5, pack(effects.heal(2), effects.draw(1)), nil
	),
	-- 雷鸣
	["7375f9e28095638cb5761795f3d67fae1837129b"] = generate(
		2, nil, pack(effects.damage(3, "firebomb"))
	),
	-- 缴械
	["f49ac4925959733cc4c2b3a2663bde8c27b8dde2"] = generate(
		4, nil, nil
	)
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
