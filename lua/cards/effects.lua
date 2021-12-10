
local effects = {}

-- 对指定玩家造成伤害
effects.damage = function (value, effect_name)
	return function (player, caster)
		player:damage(value, caster, effect_name)
	end
end

-- 恢复指定玩家的生命
effects.heal = function (value)
	return function (player, caster)
		player:heal(value, caster)
	end
end

-- 恢复指定玩家的能量
effects.empower = function (value)
	return function (player, caster)
		player:empower(value, caster)
	end
end

-- 减少或清零指定玩家的能量
effects.depower = function (value)
	return function (player, caster)
		if value <= 0 then
			player.energy = 0
			Emit("depower", player.id, 0)
		else
			player:depower(value, caster)
		end
	end
end

-- 指定玩家抽牌
effects.draw = function (value)
	return function (player, _)
		for _ = 1, value do
			player:draw()
		end
	end
end

-- 指定玩家弃牌
effects.undraw = function (value)
	return function (player, _)
		if value == 0 then
			player.undraw(99)
		else
			for _ = 1, value do
				player:undraw()
			end
		end
	end
end

-- 脱去指定玩家的BUFF并应用附加效果
effects.strip = function (value, subeffect)
	return function (player, caster)
		local bs = {}
		if value <= 0 then
			for _ = 1, #player.buffs do
				table.insert(bs, 1)
			end
			player.buffs = {}
		else
			value = math.min(value, #player.buffs)
			for _ = 1, value do
				local i = math.random(#player.buffs)
				table.insert(bs, i)
				table.remove(player.buffs, i)
			end
		end
		Emit("strip", player.id, bs)
		if type(subeffect) == "table" then
			local effect = assert(effects[subeffect.name], "bad subeffect name " .. subeffect.name)
			local apply = effect((#bs) * subeffect.factor)
			if subeffect.target == "owner" then
				apply(player, caster)
			elseif subeffect.target == "opposite" then
				apply(player.tabletop:other_player(), caster)
			else
				error("unknown strip subeffect target " .. subeffect.target)
			end
		end
	end
end

return effects
