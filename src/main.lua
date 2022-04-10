-- TODO: console, but nothing else. keep this file small
require "irisgame"

function love.load()
	GAMESTATE = IRISGAME
end

function love.update(dt)
	GAMESTATE:update(dt)
end

local rectx2,recty2,rectw2,recth2 = 500,000,50,50
function love.draw()
	GAMESTATE:draw()

	local bodies = testworld:CollectBodies()

	sorted = SortedAABB:new()
	sorted:SortBodies(testworld:CollectBodies(), true)
	collisions = sorted:GetPossibleCollisions()

	for i,v in pairs(collisions) do
		print(i.props.body_name)
		for _,b in ipairs(v) do
			print("  ", b.props.body_name)
		end
	end
	
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
	
	--[[love.graphics.setColor(1,1,1)

	local rects = {}
	for i = 1,8 do
		rects[i] = {}
		rects[i][1] = 50 + 75*i
		rects[i][2] = 400
		rects[i][3] = 75
		rects[i][4] = 75
	end
	table.insert(rects,{50,50,300,50})
	table.insert(rects,{175,25,50,100})
	local rectx,recty,rectw,recth = 250,250,100,150
	local rayx,rayy,dx,dy = rectx2+rectw2/2,recty2+recth2/2,0,0

	local mx,my = love.mouse.getPosition()

	dx, dy = mx - rayx, my - rayy
	dx = dx * 0.01
	dy = dy * 0.01

	local _w = rectw2
	local _h = rectw2
	local _w2 = rectw2/2
	local _h2 = rectw2/2

	local collisions = {}

	love.graphics.rectangle("line", rectx2,recty2,rectw2,recth2)
	for i=1, #rects do
	--local collision, contactx, contacty, normalx, normaly, time = RayRectangleCollision(rayx,rayy,dx,dy,rectx,recty,rectw,recth)
	--local collision, contactx, contacty, normalx, normaly, time = RayRectangleCollision(rayx,rayy,dx,dy,rectx-_w2,recty-_h2,rectw+_w,recth+_h)
	    rectx,recty,rectw,recth = rects[i][1],rects[i][2],rects[i][3],rects[i][4]
		--local collision, newxvel, newyvel = DynamicRectStaticRectCollisionFull(rectx2,recty2,rectw2,recth2,dx,dy,rectx,recty,rectw,recth)
		local collision, contactx, contacty, normalx, normaly, time =
			DynamicRectStaticRectCollision(rectx2,recty2,rectw2,recth2,dx,dy,rectx,recty,rectw,recth)
		if collision then
			love.graphics.setColor(1,1,0)
			love.graphics.rectangle("line", rectx,recty,rectw,recth)
			table.insert(collisions,{i,contactx,contacty,normalx,normaly,time})
			--dx,dy=newxvel, newyvel
		else
			love.graphics.setColor(1,1,1)
			love.graphics.rectangle("line", rectx,recty,rectw,recth)
		end
	end

	table.sort(collisions, function(a,b) return a[6]<b[6] end)
	for i,v in ipairs(collisions) do
		local newxvel, newyvel = ResolveDynamicRectStaticRectCollision(rectw2, recth2, dx, dy,
		  collisions[i][2], collisions[i][3], collisions[i][4], collisions[i][5], collisions[i][6])
		dx = newxvel
		dy = newyvel
	end

	rectx2 = rectx2 + dx
	recty2 = recty2 + dy

	love.graphics.line(rayx,rayy,rayx+dx,rayy+dy)--]]
end
