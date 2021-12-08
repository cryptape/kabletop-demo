
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
	-- 魔法预言
	[1] = generate(
		3, nil, nil, pack(buffs.cardmaster(1, 1)), nil
	),
	-- 百裂斩
	[2] = generate(
		3, nil, pack(effects.damage(2, "bladewind"), effects.depower(1)), nil, nil
	),
	-- 天使恩泽
	[3] = generate(
		0, pack(effects.empower(3)), pack(effects.heal(2)), nil, nil
	),
	-- 恶魔契约
	[4] = generate(
		0, pack(effects.damage(2, "bladewind"), effects.empower(2)), nil, nil, nil
	),
	-- 充能
	["10ad3f5012ce514f409e4da4c011c24a31443488"] = generate(
		0, pack(effects.empower(2)), nil, nil, nil
	),
	-- 火炼真金
	["d046a18f7e01cb42e911fae2f11ba60c9c6834f8"] = generate(
		2, nil, nil, pack(buffs.burning(2, 2), buffs.holypower(2, 2)), nil
	),
	-- 能量流失
	["f37dfa5b009ea001acd3617886d9efecf31bb153"] = generate(
		2, pack(effects.depower(0)), pack(effects.depower(0)), nil, nil
	),
	-- 心灵净化
	["97bff01bcad316a4b534ef221bd66da97018df90"] = generate(
		4, pack(effects.heal(3), effects.draw(1)), nil, nil
	),
	-- 气血暴怒
	["36248218d2808d668ae3c0d35990c12712f6b9d2"] = generate(
		0, pack(effects.damage(4, "firebomb"), effects.empower(4)), nil, nil, nil
	),
	-- 嗜血
	["f49ac4925959733cc4c2b3a2663bde8c27b8dde2"] = generate(
		6, pack(effects.heal(4)), pack(effects.damage(4, "firebomb")), nil, nil
	),
	-- 雷鸣
	["cbbbfff040366f8d4d8f4eef22f9711a561c1fb5"] = generate(
		2, nil, pack(effects.damage(3, "thunder")), nil, nil
	),
	-- 上缴兵器
	["9285def08d45c203d83e13c5363627b8e95b3675"] = generate(
		2, nil, nil, pack(buffs.niceevil(1, 1)), nil
	),
	-- 大开杀戒
	["d392835f312304530091d6ee6d833b35f7a0aa0b"] = generate(
		6, nil, pack(effects.damage(10, "waterfire")), nil, nil
	),
	-- 火刃
	["635552d615f0c2fa17cdc68307dc154c957e3d60"] = generate(
		4, pack(effects.damage(2)), nil, pack(buffs.fireup(3, 1)), nil
	),
	-- 内力穿透
	["ef28b677015404f9ee466b950d880f6d78709ef1"] = generate(
		4, nil, pack(effects.depower(5)), nil, nil
	),
	-- 冥想
	["cd58caae1dd06b8074cc55283dabfb7c8df784a7"] = generate(
		5, nil, nil, pack(buffs.holylight(3, 4)), nil
	),
	-- 无限能量
	["f9c2d5a3d7eba0bcd7973ae48c5db7937c363547"] = generate(
		4, nil, nil, pack(buffs.holypower(3, 2)), nil
	),
	-- 磁暴效应
	["68db1cc5dd2707bc19588c228cd8771efebe44c8"] = generate(
		0, pack(effects.empower(4)), pack(effects.empower(2)), nil, nil
	),
	-- 邪恶面具
	["c0286f74c4d3c2200c9a035e06c856a5a5033996"] = generate(
		0, pack(effects.empower(5)), pack(effects.draw(1)), nil, nil
	),
	-- 智力游戏
	["032d5e638aefed495dc3ae293cd5001c516743b3"] = generate(
		6, pack(effects.heal(2), effects.draw(2)), nil, nil, nil
	),
	-- 武力萃取
	["ea2ee2ac39fa0794f8ab4987827d93517430a745"] = generate(
		1, nil, pack(effects.empower(3)), pack(buffs.fireup(2, 1)), nil
	),
	-- 史莱姆袭击
	["d81488bff2b05b434abf93c4e604235ada1850a9"] = generate(
		2, pack(effects.undraw(1)), pack(effects.damage(6, "firebomb")), nil, nil
	),
	-- 刀枪不入
	["4a19d1b5ddf31214c01cd93e3314c8bbdf02d717"] = generate(
		4, nil, nil, pack(buffs.shield(2, 3)), nil
	),
	-- 龙熄
	["fde2a70cffa777c0fc53c29aae1452c17147feb2"] = generate(
		6, nil, pack(effects.damage(8, "firedragon")), nil, nil
	),
	-- 涉水进攻
	["112c40c02594af5565e4a1c453b3f2f1d1b34a15"] = generate(
		3, nil, pack(effects.damage(6)), pack(buffs.burning(3, 1)), nil
	),
	-- 迷惑之眼
	["728a75f3491586bda7731612699e0a816d9b9c7f"] = generate(
		3, nil, pack(effects.undraw(1)), nil, nil
	),
	-- 泄气
	["b6d0f5c53b968052fb29d7c98a82e1b89af86b93"] = generate(
		3, nil, pack(effects.depower(4)), nil, nil
	),
	-- 生命培育
	["49f11bf3811b5316a4f64bc60f1f9e2db7658be5"] = generate(
		6, pack(effects.heal(10)), nil, nil, nil
	),
	-- 毁天灭地
	["81074da205515c650e4408a38bdfbabf455d9eb0"] = generate(
		6,
		pack(effects.depower(0), effects.strip(0), effects.damage(3, "bomb")),
		pack(effects.depower(0), effects.strip(0), effects.damage(3, "bomb")),
		nil, nil
	),
	-- 火焰灼烧
	["1dac1c52818c97477b46f8e38514f8a4bd2e935e"] = generate(
		0, pack(effects.empower(6), effects.damage(5, "firedragon")), nil, nil
	),
	-- 精神失控
	["00d16eec4f9aa41e28a7a9c8af1006e9f0697725"] = generate(
		3, pack(effects.damage(5, "firebomb"), effects.draw(2)), nil, nil, nil
	),
	-- 圣剑士的意志
	["5ceb75a6a1990b6fde9f6c3d9d7b9731c630630a"] = generate(
		4, pack(effects.heal(6)), nil, nil, nil
	),
	-- 关键零件
	["ec7f0ebf2ddcc1a04aa0ca8ee85be4020fd62c64"] = generate(
		3, pack(effects.draw(1)), nil, nil, nil
	),
	-- 邪魔的恩赐
	["66b7fc8a970de2b83eb01720d51dc04b08ffdaba"] = generate(
		0, pack(effects.empower(10), effects.damage(5, "deathfire")), nil, pack(buffs.burning(10, 1)), nil
	),
	-- 千手
	["8ba97786d1e7db828553c318fc71ff5bd40af323"] = generate(
		4, pack(effects.draw(3), effects.undraw(1)), nil, nil, nil
	),
	-- 失控闪电
	["f2fe97371461754207c64f9c64eb2b2589774bfc"] = generate(
		3, nil, nil, pack(buffs.holypower(2, 3), buffs.burning(1, 3)), nil
	),
	-- 被迫防御
	["ac74824a6c938ad7b83a1380d75862a420cdfe1a"] = generate(
		5, nil, nil, pack(buffs.holylight(2, 3), buffs.shield(2, 3)), nil
	),
	-- 替身攻击
	["759df03dda3c6303aa06252854cd5398166140bb"] = generate(
		6, nil, pack(effects.damage(4, "firebomb"), effects.undraw(1)), nil, nil
	),
	-- 武器上供
	["9be947ba34ce065abc78ad594e0683c537665cfd"] = generate(
		2, pack(effects.strip(1, subeffect("draw", "owner", 1))), nil, nil
	),
	-- 盲目愉悦
	["0462272b1dc6137c3b4f22c5d08b47da6cb9d3c1"] = generate(
		3, pack(effects.strip(0, subeffect("heal", "owner", 3))), nil, nil, nil
	),
	-- 灵能攫取
	["ad78dd763e70b8b89a41f4a0ff34896d5447513e"] = generate(
		6, nil, pack(effects.strip(0, subeffect("damage", "owner", 1))), nil, nil
	),
	-- 弱点分析
	["373efffe4f0fb741c00bf95864a83d85c26b4662"] = generate(
		5, nil, pack(effects.depower(2), effects.undraw(1)), nil, nil
	),
	-- 预借
	["657f232232088ef1b1dbc3ecbd07ba9d18844d7a"] = generate(
		5, pack(effects.damage(6, "bluefire")), nil, pack(buffs.fireup(3, 1)), nil
	),
	-- 反射护罩
	["f7b00790c41297fc095228d3b23e6510fba69258"] = generate(
		4, nil, nil, pack(buffs.burning(1, 4), buffs.reflect(2, 4)), nil
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
		self.caster_buffs = table.clone(template.caster_buffs or {})
		self.opposite_buffs = table.clone(template.opposite_buffs or {})
	end
end

function table.clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

return instances
