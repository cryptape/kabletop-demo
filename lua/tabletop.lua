
require "class"
local Player = require "player"

-- 游戏桌面
local Tabletop = class()

function Tabletop:ctor(role_1, role_2, first_player)
	assert(_winner, "global var _winner is NIL")
	assert(_user1_nfts, "global var _user1_nfts is NIL")
	assert(_user2_nfts, "global var _user2_nfts is NIL")
	self.round = 0
	self.players = {
		[1] = Player.new(role_1, _user1_nfts, PlayerId.One, self),
		[2] = Player.new(role_2, _user2_nfts, PlayerId.Two, self)
	}
	self.acting_player = first_player
end

function Tabletop:spell_card(which)
	local player = self.players[self.acting_player]
	if which == nil or which == 0 then
		player:spell_master()
	else
		player:spell(which)
	end
end

function Tabletop:draw_card()
	local player = self.players[self.acting_player]
	player:draw()
end

function Tabletop:switch_round()
	self.acting_player = self:other_player()
	self.round = self.round + 1
	for player in ipairs(self.players) do
		player.elapse_buffs()
	end
	print("tabletop:switch_round " .. self.acting_player)
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
	return assert(self.players[self.acting_player % 2 + 1], "invalid player")
end

return Tabletop
