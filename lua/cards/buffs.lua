
local buffs = {}

-- 金钟罩：吸收伤害，在BUFF消失后对对方造成吸收的总伤害
buffs.healdefend = function (value, live_round)
	return {
		id = 2,
		surplus = value,
		accumulate = 0,
		life = live_round,
		["elapse"] = function (self, player, offset)
			self.life = self.life - 1
			if self.life <= 0 then
				player.hp = math.min(player.hp + self.accumulate, player.max_hp)
				Emit("heal", player.id, player.hp)
			end
			Emit("buff", player.id, self.id, offset, self.life)
			return self.life > 0
		end,
		["effects.damage"] = function (self, _, damage)
			local old = self.surplus
			self.surplus = math.max(0, self.surplus - damage)
			local change = old - self.surplus
			self.accumulate = self.accumulate + change
			return damage - change
		end
	}
end

-- 圣光：每一回合恢复指定血量
buffs.holylight = function (value, live_round)
	return {
		id = 4,
		life = live_round,
		["elapse"] = function (self, player, offset)
			self.life = self.life - 1
			player.hp = math.min(player.hp + value, player.max_hp)
			Emit("heal", player.id, player.hp)
			Emit("buff", player.id, self.id, offset, self.life)
			return self.life > 0
		end
	}
end

return buffs
