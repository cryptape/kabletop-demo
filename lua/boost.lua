
Tabletop = require "tabletop"

Player = {
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
	ROLE_NFTS = {
		[Role.Chosen] = "10ad3f5012ce514f409e4da4c011c24a31443488",
		[Role.Cultist] = "f37dfa5b009ea001acd3617886d9efecf31bb153",
		[Role.Ironclad] = "d046a18f7e01cb42e911fae2f11ba60c9c6834f8",
		[Role.Silent] = "36248218d2808d668ae3c0d35990c12712f6b9d2"
	}
}

function Emit(...)
	__events__ = __events__ or {}
	table.insert(__events__, table.pack(...))
end
