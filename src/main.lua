-- TODO: console, but nothing else. keep this file small
require "irisgame"

function love.load()
	GAMESTATE = IRISGAME
end

function love.update(dt)
	GAMESTATE:update(dt)
end

function love.draw()
	GAMESTATE:draw()

	love.graphics.origin()
	love.graphics.scale(4.0)
	love.graphics.translate(10,10)
	for i=1,64 do
		local index = gridtest:GridIndexInverse(gridtest.__depth, i)
		local x,y,w,h = gridtest:CellToArea(index)

		if gridtest:CellEmpty(index) then
			love.graphics.rectangle("line",x,y,w,h)
		else
			love.graphics.rectangle("fill",x,y,w,h)
		end


		for j = 0, 10000 do
			--gridtest:AddBodyToGrid("AA",16,16,8,8)
			gridtest:RemoveBodyFromGrid("AA")
		end
	end
end
