
local buffs = {}

-- 抽牌：每一回合抽指定张牌
buffs.cardmaster = function (value, live_round)
	return {
		id = 1,
		life = live_round,
		value = value,
		["elapse"] = function (self, offset)
			self.life = self.life - 1
			self.owner:draw(value)
			Emit("buff", self.owner.id, self.id, offset, value, self.life)
			return self.life > 0
		end
	}
end

-- 弃牌: 每一回合弃指定张牌
buffs.evilcard = function (value, live_round)
	return {
		id = 9,
		life = live_round,
		value = value,
		["elapse"] = function (self, offset)
			self.life = self.life - 1
			self.owner:undraw(value)
			Emit("buff", self.owner.id, self.id, offset, value, self.life)
			return self.life > 0
		end
	}
end

-- 圣光：每一回合恢复指定血量
buffs.holylight = function (value, live_round)
	return {
		id = 4,
		life = live_round,
		value = value,
		["elapse"] = function (self, offset)
			self.life = self.life - 1
			self.owner:heal(value, self.caster)
			Emit("buff", self.owner.id, self.id, offset, value, self.life)
			return self.life > 0
		end
	}
end

-- 威能：每一回合增加指定能量
buffs.holypower = function (value, live_round)
	return {
		id = 6,
		life = live_round,
		value = value,
		["elapse"] = function (self, offset)
			self.life = self.life - 1
			self.owner:empower(value, self.caster)
			Emit("buff", self.owner.id, self.id, offset, value, self.life)
			return self.life > 0
		end
	}
end

-- 回撤: 每一回合都将伤害改为治愈指定倍数
buffs.niceevil = function (value, live_round)
	return {
		id = 3,
		life = live_round,
		value = value,
		["elapse"] = function (self, offset)
			self.life = self.life - 1
			Emit("buff", self.owner.id, self.id, offset, value, self.life)
			return self.life > 0
		end,
		["effects.damage"] = function (self, caster, target, damage)
			if self.owner == caster and caster ~= target then
				self.owner:heal(damage * value, self.caster)
				damage = 0
			end
			return damage
		end
	}
end

-- 增幅：每一回合造成的伤害增加指定大小
buffs.fireup = function (value, live_round)
	return {
		id = 5,
		life = live_round,
		value = value,
		["elapse"] = function (self, offset)
			self.life = self.life - 1
			Emit("buff", self.owner.id, self.id, offset, value, self.life)
			return self.life > 0
		end,
		["effects.damage"] = function (self, caster, target, damage)
			if self.owner == caster and caster ~= target then
				damage = damage + value
			end
			return damage
		end
	}
end

-- 护盾：每一回合减少指定伤害
buffs.shield = function (value, live_round)
	return {
		id = 2,
		life = live_round,
		value = value,
		["elapse"] = function (self, offset)
			self.life = self.life - 1
			Emit("buff", self.owner.id, self.id, offset, value, self.life)
			return self.life > 0
		end,
		["effects.damage"] = function (self, caster, target, damage)
			if self.owner == target and caster ~= target then
				damage = damage - value
			end
			return damage
		end
	}
end

-- 灼烧：每一回合损失指定血量
buffs.burning = function (value, live_round)
	return {
		id = 7,
		life = live_round,
		value = value,
		["elapse"] = function (self, offset)
			self.life = self.life - 1
			self.owner:damage(value, self.caster)
			Emit("buff", self.owner.id, self.id, offset, value, self.life)
			return self.life > 0
		end
	}
end

-- 反弹：攻击时攻击方将受到指定伤害
buffs.reflect = function (value, live_round)
	return {
		id = 8,
		life = live_round,
		value = value,
		["elapse"] = function (self, offset)
			self.life = self.life - 1
			Emit("buff", self.owner.id, self.id, offset, value, self.life)
			return self.life > 0
		end,
		["effects.damage"] = function (self, caster, target, damage)
			if self.owner == target and caster ~= target then
				caster:damage(value, self.caster)
			end
			return damage
		end
	}
end

return buffs
