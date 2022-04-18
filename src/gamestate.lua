require "irisgame"

GAMESTATE = IRISGAME

function SET_GAMESTATE(gs)
	GAMESTATE = gs
	gs:load()
end
