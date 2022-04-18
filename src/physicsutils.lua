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

-- test for ray vs line collision
-- rx,ry and dx,dy are the ray origin and direction vectors
-- ax,ay and bx,by are the line start/end points
-- returns true/false, contactx, contacty, normalx, normaly, time
-- normal vector is not normalised
function RayLineCollision(rx,ry,dx,dy, ax,ay,bx,by)
	local px = bx-ax
	local py = by-ay

	-- test if parallel
	local cp = dx*py - dy*px
	if cp == 0 then
		return false
	end

	local vx,vy = rx-ax, ry-ay
	local tx,ty = -dy,dx

	local t1 = (px*vy - py*vx) / (px*tx + py*ty)
	local t2 = (vx*tx + vy*ty) / (px*tx + py*ty)

	-- no intersection
	if t2 <= 0 or t2 >= 1 or t1 < 0 then
		return false
	end

	local contactx = rx + dx*t1
	local contacty = ry + dy*t1
	local normalx = -py
	local normaly = px

	if normalx*dx + normaly*dy > 0 then
		normalx, normaly = -normalx, -normaly
	end
	return true, contactx, contacty, normalx, normaly, t1
end

function RayLineCollision2(rx,ry,dx,dy, ax,ay,bx,by)
	local px = bx-ax
	local py = by-ay

	-- test if parallel
	local cp = dx*py - dy*px
	if cp == 0 then
		return false
	end

	local vx,vy = rx-ax, ry-ay
	local tx,ty = -dy,dx

	local t1 = (px*vy - py*vx) / (px*tx + py*ty)
	local t2 = (vx*tx + vy*ty) / (px*tx + py*ty)

	-- no intersection
	if t2 < 0 or t2 > 1 or t1 < 0 then
		return false
	end

	local contactx = rx + dx*t1
	local contacty = ry + dy*t1
	local normalx = -py
	local normaly = px

	if normalx*dx + normaly*dy > 0 then
		normalx, normaly = -normalx, -normaly
	end
	return true, contactx, contacty, normalx, normaly, t1
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

-- checks for collision ray vs axis aligned right angle triangle
--
--  clip = 0       clip > 0
--                __
-- |\             | \
-- | \            |  \
-- |  \           |   \
-- |   \          |    \
-- |____\         |_____| <- line segment has length clipy, other line has length clipx
--
-- returns false if no collision
-- returns true, contactx, contacty, normalx, normaly, time if collision
__ORIENT_LOOKUP__ = {
 topleft     = {0,0},
 topright    = {1,0},
 bottomleft  = {0,1},
 bottomright = {1,1}}
function RayTriangleCollision(rx,ry, dx,dy, x,y,w,h, orient, clipx, clipy, tnormalx, tnormaly)
	local ISNAN = ISNAN -- cache ISNAN
	-- the two line segments for the opposite and adjacent sides of the triangle
	-- and their normals
	local lx1,ly1, lx2,ly2
	local lnx, lny
	local jx1,jy1, jx2,jy2
	local jnx, jny

	-- the line segment for the hypoteneuse
	-- and its normal
	local hx1, hy1, hx2, hy2
	local hnx, hny

	-- the two line segments for the clip lines
	-- and their normals
	local cx_x1, cx_y1, cx_x2, cx_y2
	local cx_xn, cx_yn
	local cy_x1, cy_y1, cy_x2, cy_y2
	local cy_xn, cy_yn

	if orient == "topleft" then

		lx1,ly1, lx2,ly2 = x   ,  y+h , x+w , y+h -- bottom side
		lnx, lny         = 0,1
		jx1,jy1, jx2,jy2 = x+w ,  y   , x+w , y+h -- right side
		jnx, jny         = 1,0

		hx1, hy1, hx2, hy2 = x   ,   y+h-clipy  ,   x+w-clipx   ,   y
		hnx, hny           = tnormalx, tnormaly

		cx_x1, cx_y1, cx_x2, cx_y2 =  x+w   ,    y    ,    x+w-clipx   ,  y
		cx_xn, cx_yn = 0, -1
		cy_x1, cy_y1, cy_x2, cy_y2 = x      ,   y+h   ,        x       ,     y+h-clipy
		cy_xn, cy_yn = -1, 0

	elseif orient == "topright" then

		lx1,ly1, lx2,ly2 = x   ,  y+h , x+w , y+h -- bottom side
		lnx, lny         = 0,1
		jx1,jy1, jx2,jy2 = x   ,  y   , x   , y+h   -- left side
		jnx, jny         = -1,0

		hx1, hy1, hx2, hy2 = x+clipx  ,   y  ,   x+w   ,   y+h-clipy
		hnx, hny           = tnormalx, tnormaly

		cx_x1, cx_y1, cx_x2, cx_y2 =  x   ,    y    ,    x+clipx   ,  y
		cx_xn, cx_yn = 0, -1
		cy_x1, cy_y1, cy_x2, cy_y2 =  x+w     ,   y+h   ,        x+w       ,     y+h-clipy
		cy_xn, cy_yn = 1, 0

	elseif orient == "bottomleft" then

		lx1,ly1, lx2,ly2 = x   ,  y   , x+w , y   -- top side
		lnx, lny         = 0,-1
		jx1,jy1, jx2,jy2 = x+w ,  y   , x+w , y+h -- right side
		jnx, jny         = 1,0

		hx1, hy1, hx2, hy2 = x   ,   y+clipy  ,   x+w-clipx   ,   y+h
		hnx, hny           = tnormalx, tnormaly

		cx_x1, cx_y1, cx_x2, cx_y2 =  x+w-clipx   ,    y+h    ,    x+w  ,  y+h
		cx_xn, cx_yn = 0, 1
		cy_x1, cy_y1, cy_x2, cy_y2 =  x      ,   y   ,        x       ,     y+clipy
		cy_xn, cy_yn = -1, 0

	elseif orient == "bottomright" then

		lx1,ly1, lx2,ly2 = x   ,  y   , x+w , y   -- top side
		lnx, lny         = 0,-1
		jx1,jy1, jx2,jy2 = x   ,  y   , x   , y+h   -- left side
		jnx, jny         = -1,0

		hx1, hy1, hx2, hy2 = x+clipx   ,   y+h  ,   x+w   ,   y+clipy
		hnx, hny           = tnormalx, tnormaly

		cx_x1, cx_y1, cx_x2, cx_y2 =  x   ,    y+h    ,    x+clipx  ,  y+h
		cx_xn, cx_yn = 0, 1
		cy_x1, cy_y1, cy_x2, cy_y2 =  x+w      ,   y   ,        x+w       ,     y+clipy
		cy_xn, cy_yn = 1, 0

	end

	love.graphics.line(lx1,ly1, lx2,ly2)
	love.graphics.line(jx1,jy1, jx2,jy2)
	love.graphics.line(hx1, hy1, hx2, hy2)
	love.graphics.line(cx_x1, cx_y1, cx_x2, cx_y2)
	love.graphics.line(cy_x1, cy_y1, cy_x2, cy_y2)

	local collision, contactx, contacty, normalx, normaly, time = nil
	time = 1/0

	local lcollision, lcontactx, lcontacty, lnormalx, lnormaly, ltime = RayLineCollision(rx,ry,dx,dy,  lx1,ly1, lx2,ly2)
	if lcollision and ltime < time then
		--collision, contactx, contacty, normalx, normaly, time = lcollision, lcontactx, lcontacty, lnormalx, lnormaly, ltime end
		collision, contactx, contacty, normalx, normaly, time = lcollision, lcontactx, lcontacty, lnx, lny, ltime end
	local jcollision, jcontactx, jcontacty, jnormalx, jnormaly, jtime = RayLineCollision(rx,ry,dx,dy,  jx1,jy1, jx2,jy2)
	if jcollision and jtime < time then
		--collision, contactx, contacty, normalx, normaly, time = jcollision, jcontactx, jcontacty, jnormalx, jnormaly, jtime end
		collision, contactx, contacty, normalx, normaly, time = jcollision, jcontactx, jcontacty, jnx, jny, jtime end
	local hcollision, hcontactx, hcontacty, hnormalx, hnormaly, htime = RayLineCollision2(rx,ry,dx,dy,  hx1,hy1, hx2,hy2)
	if hcollision and htime < time then
		--collision, contactx, contacty, normalx, normaly, time = hcollision, hcontactx, hcontacty, hnormalx, hnormaly, htime end
		collision, contactx, contacty, normalx, normaly, time = hcollision, hcontactx, hcontacty, hnx, hny, htime end
	local cxcollision, cxcontactx, cxcontacty, cxnormalx, cxnormaly, cxtime = RayLineCollision(rx,ry,dx,dy, cx_x1,cx_y1,cx_x2,cx_y2)
	if cxcollision and cxtime < time then
		--collision, contactx, contacty, normalx, normaly, time = cxcollision, cxcontactx, cxcontacty, cxnormalx, cxnormaly, cxtime end
		collision, contactx, contacty, normalx, normaly, time = cxcollision, cxcontactx, cxcontacty, cx_xn, cx_yn, cxtime end
	local cycollision, cycontactx, cycontacty, cynormalx, cynormaly, cytime = RayLineCollision(rx,ry,dx,dy, cy_x1,cy_y1,cy_x2,cy_y2)
	if cycollision and cytime < time then
		--collision, contactx, contacty, normalx, normaly, time = cycollision, cycontactx, cycontacty, cynormalx, cynormaly, cytime end
		collision, contactx, contacty, normalx, normaly, time = cycollision, cycontactx, cycontacty, cy_xn, cy_yn, cytime end

	if collision then
		local dp = dx*normalx + dy*normaly
		if dp > 0 then return false end

		local n = math.sqrt(normalx*normalx + normaly*normaly)
		normalx = normalx / n
		normaly = normaly / n

		return collision, contactx, contacty, normalx, normaly, time
	else
		return false
	end
end

-- returns false if no collision
-- returns true, newxvel, newyvel, newdx, newdy if collision 
function DynamicRectStaticRectCollisionFull(dx,dy,dw,dh, xvel, yvel, sx,sy,sw,sh, friction1, friction2)
	local collision, contactx, contacty, normalx, normaly, time =
		DynamicRectStaticRectCollision(dx,dy,dw,dh, xvel, yvel, sx,sy,sw,sh)
	if collision then
		return true, ResolveDynamicRectStaticRectCollision(xvel,yvel,contactx,contacty,normalx,normaly,time,friction1,friction2)
	else
		return false
	end
end

-- returns false if no collision
-- returns true, newxvel, newyvel, newdx, newdy if collision 
function DynamicRectStaticTriangleCollisionFull(dx,dy,dw,dh, xvel, yvel, sx,sy,sw,sh, orient, friction1, friction2, tnormalx, tnormaly)
	local collision, contactx, contacty, normalx, normaly, time =
		DynamicRectStaticTriangleCollision(dx,dy,dw,dh, xvel, yvel, sx,sy,sw,sh, orient, tnormalx, tnormaly)
	if collision then
		return true, ResolveDynamicStaticTriangleRectCollision(xvel,yvel,contactx,contacty,normalx,normaly,time,friction1,friction2)
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

-- returns false if no collision
-- returns true, contactx, contacty, normalx, normaly, time if collision happens
function DynamicRectStaticTriangleCollision(dx,dy,dw,dh, xvel, yvel, sx,sy,sw,sh, orient, tnormalx, tnormaly)
	if xvel == 0 and yvel == 0 then
		return false
	end

	local dwhalf, dhhalf = dw/2, dh/2
	local rayx,rayy = dx+dwhalf, dy+dhhalf
	local collision, contactx, contacty, normalx, normaly, time =
		RayTriangleCollision(rayx,rayy,xvel,yvel, sx-dwhalf, sy-dhhalf, sw+dw, sh+dh, orient, dw,dh, tnormalx, tnormaly)
	if collision and time >= 0 and time <= 1.0 then
		return collision, contactx, contacty, normalx, normaly, time
	else
		return false
	end
end

-- returns newxvel, newyvel, onfloor, onleftwall, onrightwall, onceil
function ResolveDynamicRectStaticRectCollision(xvel, yvel, contactx, contacty, normalx, normaly, time, friction1, friction2)
		local friction = math.min(friction1 or 0, friction2 or 0)
		local newxvel = xvel + normalx * math.abs(xvel) * (1 - time) - xvel * math.abs(normaly) * friction
		local newyvel = yvel + normaly * math.abs(yvel) * (1 - time) - yvel * math.abs(normalx) * friction
		return newxvel, newyvel, normaly==-1, normalx==1, normalx==-1, normaly==1
end

-- returns newxvel, newyvel, onfloor, onleftwall, onrightwall, onceil
function ResolveDynamicStaticTriangleRectCollision(xvel, yvel, contactx, contacty, normalx, normaly, time, friction1, friction2)
		local friction = math.min(friction1 or 0, friction2 or 0)
		--newxvel = xvel + normalx * math.abs(xvel) * (1 - time) - xvel * math.abs(normaly) * friction
		--newyvel = yvel + normaly * math.abs(yvel) * (1 - time) - yvel * math.abs(normalx) * friction
		--local newxvel = xvel + normalx * math.abs(xvel) * (1 - time) -- xvel * math.abs(normaly) * friction
		--local newyvel = yvel + normaly * math.abs(yvel) * (1 - time) -- yvel * math.abs(normalx) * friction

		local dx = xvel*(1-time)
		local dy = yvel*(1-time)
		local dot = dx*normalx + dy*normaly

		local fx = xvel
		local fy = yvel
		local fdot = -xvel*normaly + yvel*normalx

		local friction = math.min(friction1 or 0, friction2 or 0)
		local friction = 0.1

		local newxvel = xvel - normalx * dot + normaly*fdot * friction
		local newyvel = yvel - normaly * dot - normalx*fdot * friction

		return newxvel, newyvel, normaly<0, normalx==1, normalx==-1, normaly>1
end

-- returns false if no collision
-- returns true, newxvel1, newyxvel1, xoffset1, yoffset1, newxvel2, newyxvel2 if collision
function DynamicRectDynamicRectCollisionFull(dx,dy,dw,dh, dxv, dyv, sx,sy,sw,sh, sxv, syv, mass1,mass2, bounce1,bounce2, friction1,friction2)
	local collision, contactx, contacty, normalx, normaly, time, rayinrect, collisiontype =
		DynamicRectDynamicRectCollision(dx,dy,dw,dh,dxv,dyv, sx,sy,sw,sh,sxv,syv)
	if collision then
		local newxvel1, newyvel1, newxvel2, newyvel2, onfloor, onleftwall, onrightwall, onceil
		  = ResolveDynamicRectDynamicRectCollision(dxv,dyv,sxv,syv,contactx,contacty,normalx,normaly,time,rayinrect,
		                                           mass1,mass2,bounce1,bounce2,friction1,friction2, collisiontype)
		if newxvel1 then
			return true, newxvel1, newyvel1, newxvel2, newyvel2, onfloor, onleftwall, onrightwall, onceil
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
		RayRectangleCollision3(rayx,rayy,dxvel,dyvel, sx-dwhalf+sxvel, sy-dhhalf+syvel, sw+dw, sh+dh)

	if collision and time >= 0.0 and time < 1.0 then
		return collision, contactx, contacty, normalx, normaly, time, rayinrect, "1"
	elseif rayinrect then
		local collision, contactx, contacty, normalx, normaly, time, rayinrect =
			RayRectangleCollision3(rayx,rayy,dxvel-sxvel,dyvel-syvel, sx-dwhalf, sy-dhhalf, sw+dw, sh+dh)
		if collision and time >= 0.0 and time < 1.0 then
			return collision, contactx, contacty, normalx, normaly, time, rayinrect, "2"
		end
		--else
		--	return collision, contactx, contacty, normalx, normaly, time, rayinrect, "3"
		--end
		return false
	else
		return false
	end
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
		return collision, contactx, contacty, normalx, normaly, time, rayinrect
	else
		return false
	end
end

__PERCENTAGE__ = 0.15

function ResolveDynamicRectDynamicRectCollision(xvel1, yvel1, xvel2, yvel2, contactx, contacty, normalx, normaly, time, rayinrect,
 mass1, mass2, bounce1, bounce2, friction1, friction2, collisiontype)
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

		local newxvel1, newyvel1 = xvel1, yvel1
		local newxvel2, newyvel2 = xvel2, yvel2
		local xoffset, yoffset = 0,0
		local xpush, ypush = 0,0
		if not rayinrect and collisiontype == "1" then
			xoffset = normalx * math.abs(xvel1) * (1 - time)
			yoffset = normaly * math.abs(yvel1) * (1 - time)
		elseif collisiontype == "2" then
			xoffset = normalx * math.abs(xvel1 - xvel2) * (1 - time)
			yoffset = normaly * math.abs(yvel1 - yvel2) * (1 - time)
		elseif collisiontype == "3" then
		end

		if mass2 == 1/0 then
			newxvel1 = xvel1 + xoffset - tx*friction
			newyvel1 = yvel1 + yoffset - ty*friction
			newxvel2 = xvel2
			newyvel2 = yvel2
		else
			--newxvel1 = xvel1 - px*bounce1*(1 - impulsex1) + xoffset -- - tx*friction
			--newyvel1 = yvel1 - py*bounce1*(1 - impulsey1) + yoffset -- - ty*friction
			--newxvel2 = xvel2 + px*bounce2*(1 - impulsex2) - xoffset -- + tx*friction
			--newyvel2 = yvel2 + py*bounce2*(1 - impulsey2) - yoffset -- + ty*friction
			newxvel1 = xvel1 - px*bounce1*(1 - impulsex1) * __PERCENTAGE__  + xoffset  - tx*friction * __PERCENTAGE__
			newyvel1 = yvel1 - py*bounce1*(1 - impulsey1) * __PERCENTAGE__  + yoffset  - ty*friction * __PERCENTAGE__
			newxvel2 = xvel2 + px*bounce2*(1 - impulsex2) * __PERCENTAGE__  - xoffset  + tx*friction * __PERCENTAGE__
			newyvel2 = yvel2 + py*bounce2*(1 - impulsey2) * __PERCENTAGE__  - yoffset  + ty*friction * __PERCENTAGE__
		end

		return newxvel1, newyvel1, newxvel2, newyvel2,
		       normaly==-1, normalx==1, normalx==-1, normaly==1
end
