-- TODO: console, but nothing else. keep this file small
require "gamestate"

local profiler = require("profiler")

function love.load()
	SET_GAMESTATE(IRISGAME)

end

function love.update(dt)
	GAMESTATE:update(dt)
end

elevatorgoup = true
function love.draw()
	GAMESTATE:draw()
end

function love.quit()
	--profiler.report("profiler.log")
end
