
local base = require "cards/base"
local effects = require "cards/effects"
local buffs = require "cards/buffs"

local function pack(...)
	return table.pack(...)
end

local function subeffect(name, target, factor)
	return {
		name = name,
		target = target,
		factor = factor
	}
end

local function generate(cost, caster_effects, opposite_effects, caster_buffs, opposite_buffs)
	return { 
		cost = cost,
		caster_effects = caster_effects,
		opposite_effects = opposite_effects,
		caster_buffs = caster_buffs,
		opposite_buffs = opposite_buffs
	}
end

local templates = {
	-- Chosen 破壁
	[1] = generate(
		2,
		nil,
		pack(effects.strip(1, subeffect("heal", "opposite", 2))),
		nil
	),
	-- Cultist 嗜血
	[2] = generate(
		4,
		pack(effects.heal(3)),
		pack(effects.damage(3, "bomb")),
		nil,
		nil
	),
	-- Ironclad 火焰匕首
	[3] = generate(
		1,
		pack(effects.damage(1, "thunder")),
		pack(effects.damage(3, "thunder")),
		nil,
		nil
	),
	-- Silent 超充
	[4] = generate(
		0,
		pack(effects.damage(3, "firebomb"), effects.empower(3)),
		nil,
		nil,
		nil
	),
	-- 充能
	["10ad3f5012ce514f409e4da4c011c24a31443488"] = generate(
		0,
		pack(effects.empower(2)),
		nil,
		nil,
		nil
	),
	-- 光明
	["d046a18f7e01cb42e911fae2f11ba60c9c6834f8"] = generate(
		5,
		nil,
		nil,
		pack(buffs.holylight(2, 3)),
		nil
	),
	-- 毒瘴
	["f37dfa5b009ea001acd3617886d9efecf31bb153"] = generate(
		2,
		pack(effects.damage(3, "firebomb"), effects.draw(1)),
		nil,
		nil
	),
	-- 心灵净化
	["97bff01bcad316a4b534ef221bd66da97018df90"] = generate(
		5,
		pack(effects.heal(2), effects.draw(1)),
		nil,
		nil
	),
	-- 雷鸣
	["36248218d2808d668ae3c0d35990c12712f6b9d2"] = generate(
		2,
		nil,
		pack(effects.damage(15, "firebomb")),
		nil,
		nil
	),
	-- 缴械
	["f49ac4925959733cc4c2b3a2663bde8c27b8dde2"] = generate(
		4,
		nil,
		nil,
		pack(buffs.counterattack(3, 4)),
		nil
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
		self.caster_buffs = template.caster_buffs or {}
		self.opposite_buffs = template.opposite_buffs or {}
	end
end

return instances
