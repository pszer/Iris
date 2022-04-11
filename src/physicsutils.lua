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
	thitnear = math.max(tnearx, tneary)
	thitfar = math.min(tfarx, tfary)

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

-- returns false if no collision
-- returns true, newxvel, newyvel, newdx, newdy if collision 
function DynamicRectStaticRectCollisionFull(dx,dy,dw,dh, xvel, yvel, sx,sy,sw,sh)
	local collision, contactx, contacty, normalx, normaly, time =
		DynamicRectStaticRectCollision(dx,dy,dw,dh, xvel, yvel, sx,sy,sw,sh)
	if collision then
		return true, ResolveDynamicRectStaticRectCollision(dw,dh,xvel,yvel,contactx,contacty,normalx,normaly,time)
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
	local collision, contactx, contacty, normalx, normaly, time =
		RayRectangleCollision(rayx,rayy,xvel,yvel, sx-dwhalf, sy-dhhalf, sw+dw, sh+dh)
	if collision and time >= 0.0 and time < 1.0 then
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
	local collision, contactx, contacty, normalx, normaly, time =
		RayRectangleCollision(rayx,rayy,xvel,yvel, sx-dwhalf, sy-dhhalf, sw+dw, sh+dh)
	if collision and time < 1.0 then
		return collision, contactx, contacty, normalx, normaly, time
	else
		return false
	end
end

-- returns newxvel, newyvel
function ResolveDynamicRectStaticRectCollision(w,h, xvel, yvel, contactx, contacty, normalx, normaly, time)
		newxvel = xvel + normalx * math.abs(xvel) * (1 - time)
		newyvel = yvel + normaly * math.abs(yvel) * (1 - time)
		return newxvel, newyvel, contactx-w/2, contacty-h/2
end
