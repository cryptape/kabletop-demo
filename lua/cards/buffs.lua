
local buffs = {}

-- 防守反击：吸收伤害，在BUFF消失后对对方造成吸收的总伤害
buffs.counterattack = function (value, live_round)
	return {
		name = "counterattack",
		surplus = value,
		accumulate = 0,
		life = live_round,
		["elapse"] = function (self, player)
			self.life = self.life - 1
			if self.life <= 0 then
				local opposite = player.kabletop:other_player()
				opposite.hp = math.max(opposite.hp - self.accumulate, 0)
				Emit("damage", opposite.id, opposite.hp, "firebomb")
			end
			return self.life <= 0
		end,
		["effects.damage"] = function (self, _, damage)
			local old = self.surplus
			self.surplus = math.max(0, self.surplus - damage)
			local change = self.surplus - old
			self.accumulate = self.accumulate + change
			return damage - change
		end
	}
end

-- 圣光：每一回合恢复指定血量
buffs.holylight = function (value, live_round)
	return {
		name = "holylight",
		life = live_round,
		["elapse"] = function (self, player)
			self.life = self.life - 1
			player.hp = math.min(player.hp + value, player.max_hp)
			Emit("heal", player.id, player.hp, "heal")
			return self.life <= 0
		end
	}
end

--[[
	TODO
]]

return buffs
