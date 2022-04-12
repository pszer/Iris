-- TODO: console, but nothing else. keep this file small
require "irisgame"

function love.load()
	GAMESTATE = IRISGAME
end

function love.update(dt)
	GAMESTATE:update(dt)
end

local profiler = require("profiler")

elevatorgoup = true
function love.draw()
	GAMESTATE:draw()

	--love.graphics.translate(100,100)

	CONTROL_LOCK.INGAME.Open()
	if QueryScancode("left", CONTROL_LOCK.INGAME) then
		testbody3.props.body_xvel = -3
	end
	if QueryScancode("right", CONTROL_LOCK.INGAME) then
		testbody3.props.body_xvel = 3
	end
	if QueryScancode("up", CONTROL_LOCK.INGAME) then
		if testbody3.props.body_onfloor then
			testbody3.props.body_yvel = -8
		end
	end
	if QueryScancode("down", CONTROL_LOCK.INGAME) then
		testbody3.props.body_yvel = 3
	end


	if elevatorgoup then
		testbody2.props.body_yvel = -1
	else
		testbody2.props.body_yvel = 1
	end

	if testbody2.props.body_y < 200 then
		testbody2.props.body_y = 200
		elevatorgoup = false
		--testbody2.props.body_yvel = -0
	elseif testbody2.props.body_y > 500 then
		testbody2.props.body_y = 500
		elevatorgoup = true
		--testbody2.props.body_yvel = -0
	end

	print("++++")
	print(testbody2.props.body_x, testbody2.props.body_y, testbody2.props.body_xvel, testbody2.props.body_yvel)
	print(testbody3.props.body_x, testbody3.props.body_y, testbody3.props.body_xvel, testbody3.props.body_yvel)
	print("++++")

	local bodies = testworld:CollectBodies()
	testworld:CollideBodies(bodies, true)

	print("----")
	print(testbody2.props.body_x, testbody2.props.body_y, testbody2.props.body_xvel, testbody2.props.body_yvel)
	print(testbody3.props.body_x, testbody3.props.body_y, testbody3.props.body_xvel, testbody3.props.body_yvel)
	print("----")

	testworld:UpdateBodies(bodies)

	for _,b in ipairs(bodies) do
		local fixtures = b:ActiveFixtures()
		local hitboxes = b:ActiveHitboxes(true)

		if b.props.body_type ~= "static" then
			love.graphics.setColor(0.25,0.25,0.4,0.3)
		else
			love.graphics.setColor(0.4,0.4,0.1,0.3)
		end
		for i,h in ipairs(hitboxes) do
			local x,y,w,h = h:Position()

			love.graphics.rectangle("fill",x,y,w,h)
		end

		love.graphics.setColor(1,0.5,1,0.5)
		for i,f in ipairs(fixtures) do
			local x,y,w,h = f:ComputeBoundingBox()

			love.graphics.rectangle("line",x,y,w,h)
		end

		love.graphics.setColor(1,0,0,0.9)
		local x,y,w,h = b:ComputeBoundingBox(true)

		love.graphics.rectangle("line",x,y,w,h)
	end

	if testworld.__sortedaabb then
		for i,v in ipairs(testworld.__sortedaabb.data) do
			local x = v[1]
			if v[2] then
				love.graphics.setColor(0.1,0.9,0.1,0.6)
			else
				love.graphics.setColor(0.9,0.1,0.1,0.6)
			end
			love.graphics.line(x,-1000,x,1000)
		end
	end
	--[[	
	rx,ry,rw,rh = 150,150,400,400
	ax,ay,dx,dy = 250,250,0,0

	--dx,dy = love.mouse.getPosition()
	--dx,dy = dx-ax,dy-ay

	local collision, contactx, contacty, normalx, normaly, time, rayinrect =
		RayRectangleCollision3(ax,ay,dx,dy,rx,ry,rw,rh)
	if collision then
		love.graphics.circle("fill", contactx, contacty,10)
		love.graphics.line(contactx,contacty, contactx+normalx*30,contacty+normaly*30)
		love.graphics.setColor(1,1,0)
	else
		love.graphics.setColor(1,1,1)
	end

	love.graphics.rectangle("line", rx,ry,rw,rh)
	love.graphics.line(ax,ay,ax+dx,ay+dy)--]]
end

function love.quit()
	--profiler.report("profiler.log")
end
