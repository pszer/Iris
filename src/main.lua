require "irisgame"

function love.load()
	GAMESTATE = IRISGAME
end

function love.update(dt)
	GAMESTATE:update(dt)
end

function love.draw()
	GAMESTATE:draw()
end
