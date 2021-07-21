
require "class"
local Player = require "player"

-- 游戏桌面
local Tabletop = class()

function Tabletop:ctor(role_1, role_2, first_player)
	self.round = 0
	self.players = {
		[1] = Player.new(role_1, _user1_nfts, 1, self),
		[2] = Player.new(role_2, _user2_nfts, 2, self)
	}
	self.acting_player = first_player
	print("tabletop:ctor")
end

function Tabletop:spell_card(caster, which)
	assert(caster == self.acting_player, "wrong round actor")
	local player = self.players[self.acting_player]
	if which == nil then
		player:spell_master()
	else
		player:spell(which)
	end
end

function Tabletop:draw_card(caster)
	assert(caster == self.acting_player, "wrong round actor")
	local player = self.players[self.acting_player]
	player:draw()
	print("tabletop:draw_card " .. caster)
end

function Tabletop:advance_round(caster)
	assert(caster == self.acting_player, "wrong round actor")
	self.players[self.acting_player]:round_end(self.round)
	self.acting_player = self:other_player()
	self.round = self.round + 1
	self.players[self.acting_player]:round_start(self.round)
	print("tabletop:advance_round " .. caster)
end

function Tabletop:check_winner()
	for i, player in ipairs(self.players) do
		if player.hp <= 0 then
			_winner = i % 2 + 1
			break
		end
	end
	return _winner
end

function Tabletop:other_player()
	return self.acting_player % 2 + 1
end

return Tabletop
