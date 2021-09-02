
require "class"
local Player = require "player"

-- 游戏桌面
local Tabletop = class()

function Tabletop:ctor(role_1, role_2)
	assert(_winner, "global var _winner is NIL")
	assert(_user1_nfts, "global var _user1_nfts is NIL")
	assert(_user2_nfts, "global var _user2_nfts is NIL")
	self.round = 1
	self.players = {
		[1] = Player.new(role_1, _user1_nfts, PlayerId.One, self),
		[2] = Player.new(role_2, _user2_nfts, PlayerId.Two, self)
	}
	-- self.acting_player = math.random(PlayerId.One, PlayerId.Two)
	self.acting_player = PlayerId.One
	for _, player in ipairs(self.players) do
		player:draw_untapped(self.acting_player)
	end
	Emit("new_round", self.acting_player, self.round, self.acting_player)
end

function Tabletop:spell_card(which)
	local player = self.players[self.acting_player]
	if which == nil or which == 0 then
		player:spell_master()
	else
		player:spell(which)
	end
	if self:check_winner() then
		Emit("game_over", _winner)
	end
end

function Tabletop:draw_card(count)
	local player = self.players[self.acting_player]
	player:draw(count)
end

function Tabletop:switch_round()
	self.round = self.round + 1
	for _, player in ipairs(self.players) do
		player:elapse_buffs()
	end
	if self:check_winner() then
		Emit("game_over", _winner)
	else
		local last_player = self.acting_player
		self.acting_player = self.acting_player % 2 + 1
		for _, player in ipairs(self.players) do
			player:draw_untapped(self.acting_player)
		end
		Emit("new_round", self.acting_player, self.round, last_player)
	end
end

function Tabletop:check_winner()
	for i, player in ipairs(self.players) do
		if player.hp <= 0 then
			_winner = i % 2 + 1
			return true
		end
	end
	return false
end

function Tabletop:other_player()
	local other_id = self.acting_player % 2 + 1
	return assert(self.players[other_id], "invalid player")
end

return Tabletop
