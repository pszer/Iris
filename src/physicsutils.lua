--[[
-- utility functions used in the physics for the game
--]]
--

--[[ given a table of axis-aligned rectangles
--   it returns the minimum bounding box containing all
--   the rectangles
--   each entry in the table should be of form {x,y,w,h}
--   returns x,y,w,h
--]]
--

function ComputeBoundingBox(boxes)
	local xmin,ymin,xmax,ymax
	local first = true

	local mathmin = math.min
	local mathmax = math.max
	local unpack = unpack

	for _,box in ipairs(boxes) do
		if first then
			xmin,ymin, xmax,ymax = unpack(box)
			xmax = xmin + xmax
			ymax = ymin + ymax
			first = false
		else
			local x,y,w,h = unpack(box)

			xmin = mathmin(xmin, x)
			ymin = mathmin(ymin, y)
			xmax = mathmax(xmax, x+w)
			ymax = mathmax(ymax, y+h)
		end
	end

	if first then
		return nil,nil,nil,nil
	else
		return xmin,ymin, xmax-xmin, ymax-ymin
	end
end

-- returns true if two rectangles collide
-- does not count touching as intersecting
function RectangleCollision(ax,ay,aw,ah, bx,by,bw,bh)
	return bx+bw > ax and
	       by+bh > ay and
		   bx < ax+aw and
		   by < ay+ah
end

function PointRectangleCollision(a,b, x,y,w,h)
	return x < a and
	       y < b and
		   x+w > a and
		   y+h > b
end

local INF = 1/0
local INFN = -1/0
local NAN = 0/0

-- NaN is the only type that doesn't equal itself
function ISNAN(x)
	return x~=x
end

-- test for ray and rectangle collision
-- rx,ry and dx,dy are the ray origin and direction vectors
-- returns true/false, contactx, contacty, normalx, normaly, time
function RayRectangleCollision(rx,ry, dx,dy, x,y,w,h)
	local ISNAN = ISNAN -- cache ISNAN

	local contactx, contacty
	local normalx, normaly = 0,0

	local invdirx = 1.0 / dx
	local invdiry = 1.0 / dy

	-- calculate intersection t with rectangles bounding axes
	local tnearx = (x-rx) * invdirx
	local tneary = (y-ry) * invdiry
	local tfarx  = (x+w-rx) * invdirx
	local tfary  = (y+h-ry) * invdiry

	if ISNAN(tfary) or ISNAN(tfarx) then return false, nil, nil, normalx, normaly, 0 end
	if ISNAN(tneary) or ISNAN(tnearx) then return false, nil, nil, normalx, normaly, 0 end

	-- sort distances so that near < far
	if tnearx > tfarx then tnearx, tfarx = tfarx, tnearx end
	if tneary > tfary then tneary, tfary = tfary, tneary end

	-- reject if no intersection
	if tnearx > tfary or tneary > tfarx then return false, nil, nil, normalx, normaly, 0 end

	-- smallest parameter of t will be the first contact
	local thitnear = math.max(tnearx, tneary)
	local thitfar = math.min(tfarx, tfary)

	-- if ray points away from object then reject collision
	if thitfar <= 0 then return false end

	contactx = rx + dx * thitnear
	contacty = ry + dy * thitnear

	-- calculate normal vector at contact point
	if tnearx > tneary then
		if invdirx < 0 then
			normalx, normaly = 1, 0
		else
			normalx, normaly = -1, 0
		end
	else
		if invdiry < 0 then
			normalx, normaly = 0, 1
		else
			normalx, normaly = 0, -1
		end
	end

	return true, contactx, contacty, normalx, normaly, thitnear
end

-- this version of the RayRectangleCollision function can handle
-- rays that origin within the rectangle
-- returns true/false, contactx, contacty, normalx, normaly, time, ray_originates_from_rectangle
function RayRectangleCollision2(rx,ry, dx,dy, x,y,w,h)
	local is_ray_origin_within_rectangle = PointRectangleCollision(rx,ry,x,y,w,h)

	local ISNAN = ISNAN -- cache ISNAN

	local contactx, contacty
	local normalx, normaly = 0,0

	local invdirx = 1.0 / dx
	local invdiry = 1.0 / dy

	-- calculate intersection t with rectangles bounding axes
	local tnearx = (x-rx) * invdirx
	local tneary = (y-ry) * invdiry
	local tfarx  = (x+w-rx) * invdirx
	local tfary  = (y+h-ry) * invdiry

	if ISNAN(tfary) or ISNAN(tfarx) then return false, nil, nil, normalx, normaly, 0, is_ray_origin_within_rectangle end
	if ISNAN(tneary) or ISNAN(tnearx) then return false, nil, nil, normalx, normaly, 0, is_ray_origin_within_rectangle end

	-- sort distances so that near < far
	if tnearx > tfarx then tnearx, tfarx = tfarx, tnearx end
	if tneary > tfary then tneary, tfary = tfary, tneary end

	-- reject if no intersection
	if not is_ray_origin_within_rectangle then
		if tnearx > tfary or tneary > tfarx then return false, nil, nil, normalx, normaly, 0, is_ray_origin_within_rectangle end
	end

	-- smallest parameter of t will be the first contact
	local thitnear = math.max(tnearx, tneary)
	local thitfar = math.min(tfarx, tfary)

	-- for rays originating in the rectangle the order
	-- is swapped
	if is_ray_origin_within_rectangle then
		thitnear, thitfar = thitfar, thitnear
	end

	-- if ray points away from object then reject collision
	if not is_ray_origin_within_rectangle and thitfar <= 0 then return false end

	contactx = rx + dx * thitnear
	contacty = ry + dy * thitnear

	-- calculate normal vector at contact point
	if not is_ray_origin_within_rectangle then
		if tnearx > tneary then
			if invdirx < 0 then
				normalx, normaly = 1, 0
			else
				normalx, normaly = -1, 0
			end
		else
			if invdiry < 0 then
				normalx, normaly = 0, 1
			else
				normalx, normaly = 0, -1
			end
		end
	else
		if tfarx < tfary then
			if invdirx > 0 then
				normalx, normaly = 1, 0
			else
				normalx, normaly = -1, 0
			end
		else
			if invdiry > 0 then
				normalx, normaly = 0, 1
			else
				normalx, normaly = 0, -1
			end
		end

	end

	return true, contactx, contacty, normalx, normaly, thitnear, is_ray_origin_within_rectangle
end

function RayRectangleCollision3(rx,ry, dx,dy, x,y,w,h)
	local is_ray_origin_within_rectangle = PointRectangleCollision(rx,ry,x,y,w,h)

	local ISNAN = ISNAN -- cache ISNAN

	local contactx, contacty
	local normalx, normaly = 0,0

	local invdirx = 1.0 / dx
	local invdiry = 1.0 / dy

	-- calculate intersection t with rectangles bounding axes
	local tnearx = (x-rx) * invdirx
	local tneary = (y-ry) * invdiry
	local tfarx  = (x+w-rx) * invdirx
	local tfary  = (y+h-ry) * invdiry

	if ISNAN(tfary) or ISNAN(tfarx) then return false, nil, nil, normalx, normaly, 0, is_ray_origin_within_rectangle end
	if ISNAN(tneary) or ISNAN(tnearx) then return false, nil, nil, normalx, normaly, 0, is_ray_origin_within_rectangle end

	-- sort distances so that near < far
	if tnearx > tfarx then tnearx, tfarx = tfarx, tnearx end
	if tneary > tfary then tneary, tfary = tfary, tneary end

	-- reject if no intersection
	if not is_ray_origin_within_rectangle then
		if tnearx > tfary or tneary > tfarx then return false, nil, nil, normalx, normaly, 0, is_ray_origin_within_rectangle end
	end

	-- smallest parameter of t will be the first contact
	local thitnear = math.max(tnearx, tneary)
	local thitfar = math.min(tfarx, tfary)

	-- if ray points away from object then reject collision
	if not is_ray_origin_within_rectangle and thitfar <= 0 then return false end

	contactx = rx + dx * thitnear
	contacty = ry + dy * thitnear

	-- calculate normal vector at contact point
	if tnearx > tneary then
		if invdirx < 0 then
			normalx, normaly = 1, 0
		else
			normalx, normaly = -1, 0
		end
	else
		if invdiry < 0 then
			normalx, normaly = 0, 1
		else
			normalx, normaly = 0, -1
		end
	end

	return true, contactx, contacty, normalx, normaly, thitnear, is_ray_origin_within_rectangle
end

-- returns false if no collision
-- returns true, newxvel, newyvel, newdx, newdy if collision 
function DynamicRectStaticRectCollisionFull(dx,dy,dw,dh, xvel, yvel, sx,sy,sw,sh)
	local collision, contactx, contacty, normalx, normaly, time =
		DynamicRectStaticRectCollision(dx,dy,dw,dh, xvel, yvel, sx,sy,sw,sh)
	if collision then
		return true, ResolveDynamicRectStaticRectCollision(xvel,yvel,contactx,contacty,normalx,normaly,time)
	else
		return false
	end
end

-- returns false if no collision
-- returns true, contactx, contacty, normalx, normaly, time if collision happens
function DynamicRectStaticRectCollision(dx,dy,dw,dh, xvel, yvel, sx,sy,sw,sh)
	if xvel == 0 and yvel == 0 then
		return false
	end

	local dwhalf, dhhalf = dw/2, dh/2
	local rayx,rayy = dx+dwhalf, dy+dhhalf
	local collision, contactx, contacty, normalx, normaly, time, rayinrect =
		RayRectangleCollision2(rayx,rayy,xvel,yvel, sx-dwhalf, sy-dhhalf, sw+dw, sh+dh)
	if collision and time >= 0 and time < 1.0 then
		return collision, contactx, contacty, normalx, normaly, time
	else
		return false
	end
end

-- returns false if no collision
-- returns true, contactx, contacty, normalx, normaly, time if collision happens
-- "version" 1 of this function does not account for a rectangle that is in a rectangle
-- version 2 does and should only be used for checking for collision but not in resolution
function DynamicRectStaticRectCollision2(dx,dy,dw,dh, xvel, yvel, sx,sy,sw,sh)
	if xvel == 0 and yvel == 0 then
		return false
	end

	local dwhalf, dhhalf = dw/2, dh/2
	local rayx,rayy = dx+dwhalf, dy+dhhalf
	local collision, contactx, contacty, normalx, normaly, time, rayinrect =
		RayRectangleCollision(rayx,rayy,xvel,yvel, sx-dwhalf, sy-dhhalf, sw+dw, sh+dh)
	if collision and time < 1.0 then
		return collision, contactx, contacty, normalx, normaly, time
	else
		return false
	end
end

-- returns newxvel, newyvel, onfloor, onleftwall, onrightwall, onceil
function ResolveDynamicRectStaticRectCollision(xvel, yvel, contactx, contacty, normalx, normaly, time)
		newxvel = xvel + normalx * math.abs(xvel) * (1 - time)
		newyvel = yvel + normaly * math.abs(yvel) * (1 - time)
		return newxvel, newyvel, normaly==-1, normalx==1, normalx==-1, normaly==1
end

-- returns false if no collision
-- returns true, newxvel1, newyxvel1, xoffset1, yoffset1, newxvel2, newyxvel2 if collision
function DynamicRectDynamicRectCollisionFull(dx,dy,dw,dh, dxv, dyv, sx,sy,sw,sh, sxv, syv, mass1,mass2, bounce1,bounce2, friction1,friction2)
	local collision, contactx, contacty, normalx, normaly, time, rayinrect, collisiontype =
		DynamicRectDynamicRectCollision(dx,dy,dw,dh,dxv,dyv, sx,sy,sw,sh,sxv,syv)
	if collision then
		local newxvel1, newyvel1, xoffset1, yoffset1, newxvel2, newyvel2, onfloor, onleftwall, onrightwall, onceil
		  = ResolveDynamicRectDynamicRectCollision(dxv,dyv,sxv,syv,contactx,contacty,normalx,normaly,time,rayinrect,
		                                           mass1,mass2,bounce1,bounce2,friction1,friction2, collisiontype)
		if newxvel1 then
			return true, newxvel1, newyvel1, xoffset1, yoffset1, newxvel2, newyvel2, onfloor, onleftwall, onrightwall, onceil
		else
			return false
		end
	else
		return false
	end
end

-- returns false if no collision
-- returns true, contactx, contacty, normalx, normaly, time if collision happens
function DynamicRectDynamicRectCollision(dx,dy,dw,dh, dxvel, dyvel, sx,sy,sw,sh, sxvel, syvel)
	if dxvel == 0 and dyvel == 0 and sxvel == 0 and syvel == 0 then
		return false
	end

	local dwhalf, dhhalf = dw/2, dh/2
	local rayx,rayy = dx+dwhalf, dy+dhhalf
	love.graphics.circle("fill",rayx,rayy,4)
	love.graphics.rectangle("line", sx-dwhalf+sxvel, sy-dhhalf+syvel, sw+dw, sh+dh)
	love.graphics.line(rayx,rayy,rayx+dxvel*10,rayy+dyvel*10)
	local collision, contactx, contacty, normalx, normaly, time, rayinrect =
		--RayRectangleCollision(rayx,rayy,dxvel,dyvel, sx-dwhalf+sxvel, sy-dhhalf+syvel, sw+dw, sh+dh)
		--RayRectangleCollision3(rayx,rayy,dxvel,dyvel, sx-dwhalf+sxvel, sy-dhhalf+syvel, sw+dw, sh+dh)
		RayRectangleCollision3(rayx,rayy,dxvel,dyvel, sx-dwhalf+sxvel, sy-dhhalf+syvel, sw+dw, sh+dh)
	--local collision2, contactx2, contacty2, normalx2, normaly2, time2, rayinrect2 =
	--	RayRectangleCollision2(rayx,rayy,dxvel,dyvel, sx-dwhalf+sxvel, sy-dhhalf+syvel, sw+dw, sh+dh)

	print("time1 time2", time, time2)
	if collision and (rayinrect or (time >= 0.0 and time < 1.0)) then
		print("bing bang wahoo")
		if rayinrect then print("rayinrect!!!!!") end
		return collision, contactx+sxvel, contacty+syvel, normalx, normaly, time, rayinrect
	else
		return false
	end

	--[[ best so far
	if dxvel == 0 and dyvel == 0 and sxvel == 0 and syvel == 0 then
		return false
	end

	local dwhalf, dhhalf = dw/2, dh/2
	local rayx,rayy = dx+dwhalf, dy+dhhalf
	love.graphics.circle("fill",rayx,rayy,4)
	love.graphics.rectangle("line", sx-dwhalf+sxvel, sy-dhhalf+syvel, sw+dw, sh+dh)
	love.graphics.line(rayx,rayy,rayx+dxvel*10,rayy+dyvel*10)
	local collision, contactx, contacty, normalx, normaly, time, rayinrect =
		--RayRectangleCollision(rayx,rayy,dxvel,dyvel, sx-dwhalf+sxvel, sy-dhhalf+syvel, sw+dw, sh+dh)
		--RayRectangleCollision3(rayx,rayy,dxvel,dyvel, sx-dwhalf+sxvel, sy-dhhalf+syvel, sw+dw, sh+dh)
		RayRectangleCollision3(rayx,rayy,dxvel,dyvel, sx-dwhalf+sxvel, sy-dhhalf+syvel, sw+dw, sh+dh)
	local collision2, contactx2, contacty2, normalx2, normaly2, time2, rayinrect2 =
		RayRectangleCollision2(rayx,rayy,dxvel,dyvel, sx-dwhalf+sxvel, sy-dhhalf+syvel, sw+dw, sh+dh)
	
	print("time1 time2", time, time2)
	if not rayinrect then
		if collision and time >= 0.0 and time < 1.0 then
			return collision, contactx, contacty, normalx, normaly, time, rayinrect
		else
			return false
		end
	end

	if collision and (rayinrect or (time >= 0.0 and time < 1.0)) and (not collision2 or (math.abs(time)<math.abs(time2)))then
		if collision and (rayinrect or (time >= 0.0 and time < 1.0)) then
			if rayinrect then print("rayinrect!!!!!") end
			return collision, contactx, contacty, normalx, normaly, time, rayinrect
		else
			return false
		end
	elseif collision2 and (rayinrect2 or (time2 >= 0.0 and time2 < 1.0)) and (not collision or (math.abs(time2)<math.abs(time)))then
		if collision2 and (rayinrect2 or (time2 >= 0.0 and time2 < 1.0)) then
			print("BRRRUUUH")
			if rayinrect2 then print("rayinrect!!!!! but 2") end
			print("the normals", normaly, normaly2)
			return collision2, contactx2, contacty2, normalx2, normaly2, time2, rayinrect2
		else
			return false
		end
	end --]]

	if dxvel == 0 and dyvel == 0 and sxvel == 0 and syvel == 0 then
		return false
	end

	local dwhalf, dhhalf = dw/2, dh/2
	local rayx,rayy = dx+dwhalf+dxvel, dy+dhhalf+dyvel
	love.graphics.circle("fill",rayx,rayy,4)
	love.graphics.rectangle("line", sx-dwhalf+sxvel, sy-dhhalf+syvel, sw+dw, sh+dh)
	love.graphics.line(rayx,rayy,rayx+dxvel*10,rayy+dyvel*10)
	local collision, contactx, contacty, normalx, normaly, time, rayinrect =
		RayRectangleCollision3(rayx,rayy,-sxvel,-syvel, sx-dwhalf, sy-dhhalf, sw+dw, sh+dh)
	local collision2, contactx2, contacty2, normalx2, normaly2, time2, rayinrect2 =
		RayRectangleCollision2(rayx,rayy,-sxvel,-syvel, sx-dwhalf, sy-dhhalf, sw+dw, sh+dh)

	--if collision and (rayinrect or (time >= 0.0 and time < 1.0)) then
	--	if rayinrect then print("rayinrect!!!!!") end
	--	return collision, contactx+sxvel, contacty+syvel, normalx, normaly, time, rayinrect
	--else
	--	return false
	--end
	--[[
	print("time1 time2", time, time2, normalx, normaly, normalx2, normaly2)
	if collision and (rayinrect or (time >= 0.0 and time < 1.0)) and (not collision2 or (math.abs(time)<=math.abs(time2)))then
		if collision and (rayinrect or (time >= 0.0 and time < 1.0)) then
			if rayinrect then print("rayinrect!!!!!") end
			return collision, contactx, contacty, normalx, normaly, time, rayinrect, "pushout"
		else
			return false
		end
	elseif collision2 and (rayinrect2 or (time2 >= 0.0 and time2 < 1.0)) and (not collision or (math.abs(time2)<math.abs(time)))then
		if collision2 and (rayinrect2 or (time2 >= 0.0 and time2 < 1.0)) then
			print("BRRRUUUH")
			if rayinrect2 then print("rayinrect!!!!! but 2") end
			print("the normals", normaly, normaly2)
			return collision2, contactx2, contacty2, normalx2, normaly2, time2, rayinrect2, "pushin"
		else
			return false
		end
	end --]]
end

function DynamicRectDynamicRectCollision2(dx,dy,dw,dh, dxvel, dyvel, sx,sy,sw,sh, sxvel, syvel)
	if dxvel == 0 and dyvel == 0 and sxvel == 0 and syvel == 0 then
		return false
	end

	local dwhalf, dhhalf = dw/2, dh/2
	local rayx,rayy = dx+dwhalf, dy+dhhalf
	local collision, contactx, contacty, normalx, normaly, time, rayinrect =
		RayRectangleCollision2(rayx,rayy,dxvel,dyvel, sx-dwhalf+sxvel, sy-dhhalf+syvel, sw+dw, sh+dh)
	if collision and (rayinrect or (time >= 0.0 and time < 1.0)) then
		if rayinrect then print("rayinrect!!!!!!!!!!!!!!!!") end
		return collision, contactx, contacty, normalx, normaly, time, rayinrect
	else
		return false
	end
end

-- returns newxvel1, newyvel1, xpush, ypush, newxvel2, newyvel2, onfloor, onleftwall, onrightwall, onceil
--[[
function ResolveDynamicRectDynamicRectCollision(xvel1, yvel1, xvel2, yvel2, contactx, contacty, normalx, normaly, time, rayinrect,
 mass1, mass2, bounce1, bounce2, friction1, friction2, collisiontype)
		if rayinrect then print("yo rayinrect") end

		-- relative velocities
		local rxv, ryv = xvel1-xvel2, yvel1-yvel2
		-- penetration speed
		local ps = rxv * normalx + ryv * normaly
		--if ps > 0 then
		--	return false
		--end

		-- penetration components
		local px,py = normalx*ps, normaly*ps

		-- tangent components
		local tx,ty = rxv-px, ryv-py

		local friction = 0 + math.min(friction1,friction2)

		-- we multiply by px,py later
		local xmoment1 = mass1 
		local ymoment1 = mass1
		local xmoment2 = mass2
		local ymoment2 = mass2
		local totalmass = mass1+mass2

		local impulsex1 = xmoment1/totalmass
		local impulsey1 = ymoment1/totalmass
		local impulsex2 = xmoment2/totalmass
		local impulsey2 = ymoment2/totalmass
		local ISNAN = ISNAN

		if ISNAN(impulsex1) then impulsex1 = 1 end
		if ISNAN(impulsex2) then impulsex2 = 1 end
		if ISNAN(impulsey1) then impulsey1 = 1 end
		if ISNAN(impulsey2) then impulsey2 = 1 end

		--print(mass1, mass2, impulsex1, impulsex2, impulsey1, impulsey2, bounce1)

		local newxvel1, newyvel1 = xvel1, yvel1
		local newxvel2, newyvel2 = xvel2, yvel2
		local xoffset, yoffset
		local xpush, ypush = 0,0
		if not rayinrect then
			print("BOY")
			xoffset = normalx * math.abs(xvel2) * (1 - time)
			yoffset = normaly * math.abs(yvel2) * (1 - time)
			print("offset", xoffset,yoffset, yvel1, yvel2, "yvel2*time", yvel2 * time, "yvel2*(1-time)", yvel2 * (1-time))
			print("yvel1*time", yvel1 * time, "yvel1*(1-time)", yvel1 * (1-time))
		else
			print("rayinrect!", normalx, normaly, time)
			love.graphics.circle("fill",contactx,contacty,3)
			xoffset = normalx * math.abs(xvel1)-- * math.abs(time)
			--yoffset = normaly * math.abs(yvel1) * math.abs(time) + yvel2 - yvel1
			--yoffset = normaly * math.abs(yvel1)-- * math.abs(time) +
			--yoffset = normaly * math.abs(yvel1) * math.abs(1) + yvel2
			--yoffset = normaly * (math.abs(yvel1) + yvel1*math.abs(time)) + yvel2
			--yoffset = normaly * (yvel1 + math.abs(yvel1*time)) best so far
			if collisiontype == "pushout" then
				print("pushout")
				--xoffset = normalx * math.abs(xvel2 * time)
				--yoffset = normaly * math.abs(yvel2 * time)
				--xoffset = normalx * math.abs(xvel2 * time)
				--yoffset = normaly * (math.abs(yvel2 * time) + math.abs(yvel2))
				--xoffset = normalx * math.abs(xvel2) - xvel1
				--yoffset = normaly * math.abs(yvel2) - yvel1
				xoffset = normalx * math.abs(xvel2) * -time
				yoffset = normaly * math.abs(yvel2) * -time
				--xpush = normalx * math.abs(xvel2)*time
				--ypush = normaly * math.abs(yvel2)*time
				--xoffset = normalx * math.abs(xvel2)*(1-time) - xpush
				--yoffset = normaly * math.abs(yvel2)*(1-time) - ypush
			elseif collisiontype == "pushin" then
				print("pushin")
				xoffset = normaly * math.abs(xvel2 * (1 - time))
				yoffset = normaly * math.abs(yvel2 * (1 - time))
			end

			print("offset", xoffset,yoffset, xvel1, yvel1, xvel2, yvel2, "xvel2*time", xvel2 * time, "xvel2*(1-time)", xvel2 * (1-time))
			print("xpush", xpush, "ypush", ypush)
			print("xvel1*time", yvel1 * time, "xvel1*(1-time)", xvel1 * (1-time))
			--xoffset = 0
			--yoffset = 0
		end

		if mass2 == 1/0 then
			newxvel1 = xvel1 + xoffset-- + math.abs(xvel2) * normalx
			newyvel1 = yvel1 + yoffset-- + math.abs(yvel2) * normaly
			--newxvel1 = xvel1 + xoffset + math.abs(xvel2) * normalx
			--newyvel1 = yvel1 + yoffset + math.abs(yvel2) * normaly
			--xoffset = 0
			--yoffset = 0
			newxvel2 = xvel2
			newyvel2 = yvel2
		else
			newxvel1 = xvel1 - px*bounce1*(1 - impulsex1) + tx*friction*(1-impulsex1)
			newyvel1 = yvel1 - py*bounce1*(1 - impulsey1) + ty*friction*(1-impulsey1)
			newxvel2 = xvel2 + px*bounce2*(1 - impulsex2) - tx*friction*(1-impulsex2)
			newyvel2 = yvel2 + py*bounce2*(1 - impulsey2) - tx*friction*(1-impulsey2)
		end

		return newxvel1, newyvel1, xpush, ypush, newxvel2, newyvel2,
		       normaly==-1, normalx==1, normalx==-1, normaly==1
end--]]

function ResolveDynamicRectDynamicRectCollision(xvel1, yvel1, xvel2, yvel2, contactx, contacty, normalx, normaly, time, rayinrect,
 mass1, mass2, bounce1, bounce2, friction1, friction2, collisiontype)
		if rayinrect then print("yo rayinrect") end

		-- relative velocities
		local rxv, ryv = xvel1-xvel2, yvel1-yvel2
		-- penetration speed
		local ps = rxv * normalx + ryv * normaly
		--if ps > 0 then
		--	return false
		--end

		-- penetration components
		local px,py = normalx*ps, normaly*ps

		-- tangent components
		local tx,ty = rxv-px, ryv-py

		local friction = 0 + math.min(friction1,friction2)

		-- we multiply by px,py later
		local xmoment1 = mass1 
		local ymoment1 = mass1
		local xmoment2 = mass2
		local ymoment2 = mass2
		local totalmass = mass1+mass2

		local impulsex1 = xmoment1/totalmass
		local impulsey1 = ymoment1/totalmass
		local impulsex2 = xmoment2/totalmass
		local impulsey2 = ymoment2/totalmass
		local ISNAN = ISNAN

		if ISNAN(impulsex1) then impulsex1 = 1 end
		if ISNAN(impulsex2) then impulsex2 = 1 end
		if ISNAN(impulsey1) then impulsey1 = 1 end
		if ISNAN(impulsey2) then impulsey2 = 1 end

		--print(mass1, mass2, impulsex1, impulsex2, impulsey1, impulsey2, bounce1)

		local newxvel1, newyvel1 = xvel1, yvel1
		local newxvel2, newyvel2 = xvel2, yvel2
		local xoffset, yoffset = 0,0
		local xpush, ypush = 0,0
		if not rayinrect then
			print("BOY", normalx, normaly)
			xoffset = normalx * math.abs(xvel1) * (1 - time)
			yoffset = normaly * math.abs(yvel1) * (1 - time)
			print("offset", xoffset,yoffset, yvel1, yvel2, "yvel2*time", yvel2 * time, "yvel2*(1-time)", yvel2 * (1-time))
			print("yvel1*time", yvel1 * time, "yvel1*(1-time)", yvel1 * (1-time))
		else
			print("in the rect", normalx, normaly)
			xoffset = normalx * math.abs(xvel1) * (1 - time)
			yoffset = normaly * math.abs(yvel1) * (1 - time)
			--xoffset = 0
			--yoffset = 0 
			print("offset", xoffset,yoffset, yvel1, yvel2, "yvel2*time", yvel2 * time, "yvel2*(1-time)", yvel2 * (1-time))
			print("yvel1*time", yvel1 * time, "yvel1*(1-time)", yvel1 * (1-time))
			
		end

		if mass2 == 1/0 then
			print("good")
			newxvel1 = xvel1 + xoffset
			newyvel1 = yvel1 + yoffset
			newxvel2 = xvel2
			newyvel2 = yvel2
		else
			newxvel1 = xvel1 - px*bounce1*(1 - impulsex1) + tx*friction*(1-impulsex1)
			newyvel1 = yvel1 - py*bounce1*(1 - impulsey1) + ty*friction*(1-impulsey1)
			newxvel2 = xvel2 + px*bounce2*(1 - impulsex2) - tx*friction*(1-impulsex2)
			newyvel2 = yvel2 + py*bounce2*(1 - impulsey2) - tx*friction*(1-impulsey2)
		end

		return newxvel1, newyvel1, xpush, ypush, newxvel2, newyvel2,
		       normaly==-1, normalx==1, normalx==-1, normaly==1
end
