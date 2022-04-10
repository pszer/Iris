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

	local bodies = testworld:CollectBodies()

	for _,b in ipairs(bodies) do
		local fixtures = b:ActiveFixtures()
		local hitboxes = b:ActiveHitboxes()

		love.graphics.setColor(1,1,1)
		for i,h in ipairs(hitboxes) do
			local x,y,w,h = h:Position()

			love.graphics.rectangle("line",x,y,w,h)
		end

		love.graphics.setColor(0,0,1,0.5)
		for i,f in ipairs(fixtures) do
			local x,y,w,h = f:ComputeBoundingBox()

			love.graphics.rectangle("line",x,y,w,h)
		end

		love.graphics.setColor(1,0,0,0.9)
		local x,y,w,h = b:ComputeBoundingBox(true)

		love.graphics.rectangle("line",x,y,w,h)
	end
	
	love.graphics.setColor(1,1,1)
end
