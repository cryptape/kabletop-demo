
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
		[1] = Player.new(role_1, table.clone(_user1_nfts), PlayerId.One, self),
		[2] = Player.new(role_2, table.clone(_user2_nfts), PlayerId.Two, self)
	}
	self.acting_player = Init()
	for _, player in ipairs(self.players) do
		player:draw_untapped(self.acting_player)
	end
	Emit("new_round", self.acting_player, self.round, 0)
end

function Tabletop:spell_card(which)
	local player = self.players[self.acting_player]
	if which == nil or which == 0 then
		player:spell_master()
	else
		player:spell(which)
	end
	if self:check_winner(false) then
		Emit("game_over", _winner)
	end
end

function Tabletop:draw_card(count)
	local player = self.players[self.acting_player]
	player:draw(count)
end

function Tabletop:switch_round()
	self.acting_player = self.acting_player % 2 + 1
	self.round = self.round + 1
	for _, player in ipairs(self.players) do
		player:elapse_buffs()
	end
	if self:check_winner(true) then
		Emit("game_over", _winner)
	else
		for _, player in ipairs(self.players) do
			player:draw_untapped(self.acting_player)
		end
		self.players[self.acting_player]:switch_to()
		Emit("new_round", self.acting_player, self.round, self.acting_player % 2 + 1)
	end
end

function Tabletop:check_winner(check_empty_cards)
	_winner = 0
	for i, player in ipairs(self.players) do
		if player.hp <= 0 then
			_winner = i % 2 + 1
			return true
		end
		if check_empty_cards then
			if #player.custom_cards <= 0 then
				_winner = i % 2 + 1
				return true
			end
		end
	end
	return false
end

function Tabletop:other_player()
	local other_id = self.acting_player % 2 + 1
	return assert(self.players[other_id], "invalid player")
end

function Tabletop:context_snapshot()
	local p1 = self.players[1]
	local p2 = self.players[2]
	local cards1 = {}
	for _, card in pairs(p1.active_cards) do
		table.insert(cards1, card.hash)
	end
	local cards2 = {}
	for _, card in pairs(p2.active_cards) do
		table.insert(cards2, card.hash)
	end
	local buffs1 = {}
	for _, buff in pairs(p1.buffs) do
		table.insert(buffs1, buff.id)
		table.insert(buffs1, buff.life)
	end
	local buffs2 = {}
	for _, buff in pairs(p2.buffs) do
		table.insert(buffs2, buff.id)
		table.insert(buffs2, buff.life)
	end
	self:check_winner(true)
	Emit(
		"context", self.acting_player, self.round,
		{ p1.role, p1.hp, p1.energy, #p1.custom_cards, #_user1_nfts }, cards1, buffs1,
		{ p2.role, p2.hp, p2.energy, #p2.custom_cards, #_user2_nfts }, cards2, buffs2,
		_winner
	)
end

return Tabletop
