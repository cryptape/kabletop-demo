
local effects = {}

-- 对指定玩家造成伤害
effects.damage = function (value, effect_name)
	return function (player)
		local applied_value = value
		for _, buff in ipairs(player.buffs) do
			local apply = buff["effects.damage"]
			if type(apply) == "function" then
				applied_value = apply(buff, player, value)
			end
		end
		player.hp = math.max(player.hp - applied_value, 0)
		Emit("damage", player.id, player.hp, effect_name)
	end
end

-- 恢复指定玩家的生命
effects.heal = function (value)
	return function (player)
		local applied_value = value
		for _, buff in ipairs(player.buffs) do
			local apply = buff["effects.heal"]
			if type(apply) == "function" then
				applied_value = apply(buff, player, value)
			end
		end
		player.hp = math.min(player.hp + applied_value, player.max_hp)
		Emit("heal", player.id, player.hp)
	end
end

-- 恢复指定玩家的能量
effects.empower = function (value)
	return function (player)
		local applied_value = value
		for _, buff in ipairs(player.buffs) do
			local apply = buff["effects.empower"]
			if type(apply) == "function" then
				applied_value = apply(buff, player, value)
			end
		end
		player.energy = math.min(player.energy + applied_value, player.max_energy)
		Emit("empower", player.id, player.energy)
	end
end

-- 指定玩家抽牌
effects.draw = function (value)
	return function (player)
		local applied_value = value
		for _, buff in ipairs(player.buffs) do
			local apply = buff["effects.draw"]
			if type(apply) == "function" then
				applied_value = apply(buff, player, value)
			end
		end
		for _ = 1, applied_value do
			player:draw()
		end
	end
end

-- 脱去指定玩家的BUFF并应用附加效果
effects.strip = function (value, subeffect)
	return function (player)
		local bs = {}
		if value <= 0 then
			for i in ipairs(player.buffs) do
				table.insert(bs, i)
			end
			player.buffs = {}
		else
			value = math.max(value, #player.buffs)
			for _ = 1, value do
				local i = math.random(#player.buffs)
				table.insert(bs, i)
				table.remove(player.buffs, i)
			end
		end
		Emit("strip", player.id, bs)
		local effect = assert(effects[subeffect.name] ~= nil, "bad subeffect name " .. subeffect.name)
		local apply = effect((#bs) * subeffect.factor)
		if subeffect.target == "owner" then
			apply(player)
		elseif subeffect.target == "opposite" then
			apply(player.kabletop:other_player())
		else
			error("unknown strip subeffect target " .. subeffect.target)
		end
	end
end

return effects
