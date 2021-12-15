
Tabletop = require "tabletop"

PlayerId = {
	One = 1,
	Two = 2
}

Role = {
	Chosen = 1,
	Cultist = 2,
	Ironclad = 3,
	Silent = 4 
}

Cfg = {
	MAX_HP = 30,
	MAX_ENERGY = 10,
}

function Init()
	local first_player = math.random(PlayerId.One, PlayerId.Two)
	Emit("init", first_player, Cfg.MAX_HP)
	return first_player
end

function Emit(...)
	local event = table.pack(...)
	print(flat_table(event))
	__events__ = __events__ or {}
	table.insert(__events__, event)
end

function flat_table(t)
	assert(type(t) == "table")
	local output = "["
	for i, v in ipairs(t) do
		if type(v) == "table" then
			v = flat_table(v)
		end
		if i == 1 then
			output = output .. v
		else
			output = output .. ", " .. v
		end
	end
	return output .. "]"
end
