
local effects = {}

effects.damage = function (value, effect_name)
	return function (player)
		player.hp = math.max(player.hp - value, 0)
		Emit("damage", player.id, player.hp, effect_name)
	end
end

effects.heal = function (value)
	return function (player)
		player.hp = math.min(player.hp + value, player.max_hp)
		Emit("heal", player.id, player.hp, "heal")
	end
end

effects.empower = function (value)
	return function (player)
		player.energy = math.min(player.energy + value, player.max_energy)
		Emit("empower", player.id, player.energy)
	end
end

effects.draw = function (value)
	return function (player)
		for _ = 1, value do
			player:draw()
		end
	end
end

return effects
