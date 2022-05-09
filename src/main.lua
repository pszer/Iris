-- TODO: console, but nothing else. keep this file small
require "gamestate"

local profiler = require("profiler")

function love.load()
	SET_GAMESTATE(IRISGAME)

end

__CACHE_COUNTER = 0
function love.update(dt)
	GAMESTATE:update(dt)

	-- we check
	if __CACHE_COUNTER >= 600 then
		IrisCleanImageCache()
		__CACHE_COUNTER = 0
	else
		__CACHE_COUNTER = __CACHE_COUNTER + 1
	end
end

function love.draw()
	GAMESTATE:draw()
end

function love.quit()
	--profiler.report("profiler.log")
end
