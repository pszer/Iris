-- TODO: console, but nothing else. keep this file small
require "irisgame"

function love.load()
	GAMESTATE = IRISGAME
end

function love.update(dt)
	GAMESTATE:update(dt)
end

local profiler = require("profiler")
function love.draw()
	GAMESTATE:draw()

	love.graphics.translate(100,100)

	CONTROL_LOCK.INGAME.Open()
	if QueryScancode("left", CONTROL_LOCK.INGAME) then
		testbody3.props.body_xvel = -3
	end
	if QueryScancode("right", CONTROL_LOCK.INGAME) then
		testbody3.props.body_xvel = 3
	end
	if QueryScancode("up", CONTROL_LOCK.INGAME) then
		testbody3.props.body_yvel = -4
		testbody.props.body_yvel = -4
	end

	--profiler.start()
	local bodies = testworld:CollectBodies()
	testworld:CollideBodies(bodies, true)
	--profiler.stop()

	--[[sorted = SortedAABB:new()
	sorted:SortBodies(testworld:CollectBodies(), true)
	collisions = sorted:GetPossibleCollisions()
	for i,v in pairs(collisions) do
		print(i.props.body_name)
		x1,y1,w1,h1 = i:ComputeBoundingBoxLastFrame(true)
		local xvel = i.props.body_xvel
		local yvel = i.props.body_yvel
		print(x1,y1,w1,h1,xvel,yvel)

		local orderedcols = {}
		for _,b in ipairs(v) do
			print("  ", b.props.body_name)
			x2,y2,w2,h2 = b:ComputeBoundingBoxLastFrame(true)
			print("  ",x2,y2,w2,h2)
			local arecolliding, contactx, contacty, normalx, normaly, time =
				DynamicRectStaticRectCollision(x1,y1,w1,h1 , xvel,yvel, x2,y2,w2,h2)

			if RectangleCollision(x1,y1,w1,h1, x2,y2,w2,h2) then
				print("  SHOULD BE COLLIDING")
			end
			print("  ",arecolliding, contactx, contacty, normalx, normaly, time)
			if arecolliding then
				table.insert(orderedcols, {b,contactx,contacty,normalx,normaly,time})
			end
		end

		local old_xvel = i.props.body_xvel
		local old_yvel = i.props.body_yvel

		table.sort(orderedcols, function(a,b) return a[6]<b[6] end)
		for _,c in ipairs(orderedcols) do
			local newxvel, newyvel = ResolveDynamicRectStaticRectCollision(w1, h1, xvel, yvel,
			  c[2], c[3], c[4], c[5], c[6])
			i.props.body_xvel = newxvel
			i.props.body_yvel = newyvel
			--i.props.body_xvel = 0
			--i.props.body_yvel = 0
		end

		i.props.body_x = i.props.body_x - old_xvel
		i.props.body_y = i.props.body_y - old_yvel
	end

	for i,b in ipairs(bodies) do
		b.props.body_x = b.props.body_x + b.props.body_xvel
		b.props.body_y = b.props.body_y + b.props.body_yvel
	end
	testworld:ApplyGravity()--]]
	
	--print(testbody2.props.body_y)
	
	for _,b in ipairs(bodies) do
		local fixtures = b:ActiveFixtures()
		local hitboxes = b:ActiveHitboxes(true)

		if b.props.body_type ~= "static" then
			love.graphics.setColor(0.25,0.25,0.4)
		else
			love.graphics.setColor(0.4,0.4,0.25)
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
end

function love.quit()
	--profiler.report("profiler.log")
end
