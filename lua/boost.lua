
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

function Emit(...)
	local event = table.pack(...)
	local output = "["
	for i, v in ipairs(event) do
		if i == 1 then
			output = output .. v
		else
			output = output .. ", " .. v
		end
	end
	print(output .. "]")
	__events__ = __events__ or {}
	table.insert(__events__, event)
end
