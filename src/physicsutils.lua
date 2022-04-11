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

--[[
bool RayVsRect(const olc::vf2d& ray_origin, const olc::vf2d& ray_dir, const rect* target, olc::vf2d& contact_point, olc::vf2d& contact_normal, float& t_hit_near)
		{
			contact_normal = { 0,0 };
			contact_point = { 0,0 };

			// Cache division
			olc::vf2d invdir = 1.0f / ray_dir;

			// Calculate intersections with rectangle bounding axes
			olc::vf2d t_near = (target->pos - ray_origin) * invdir;
			olc::vf2d t_far = (target->pos + target->size - ray_origin) * invdir;

			if (std::isnan(t_far.y) || std::isnan(t_far.x)) return false;
			if (std::isnan(t_near.y) || std::isnan(t_near.x)) return false;

			// Sort distances
			if (t_near.x > t_far.x) std::swap(t_near.x, t_far.x);
			if (t_near.y > t_far.y) std::swap(t_near.y, t_far.y);

			// Early rejection		
			if (t_near.x > t_far.y || t_near.y > t_far.x) return false;

			// Closest 'time' will be the first contact
			t_hit_near = std::max(t_near.x, t_near.y);

			// Furthest 'time' is contact on opposite side of target
			float t_hit_far = std::min(t_far.x, t_far.y);

			// Reject if ray direction is pointing away from object
			if (t_hit_far < 0)
				return false;

			// Contact point of collision from parametric line equation
			contact_point = ray_origin + t_hit_near * ray_dir;

			if (t_near.x > t_near.y)
				if (invdir.x < 0)
					contact_normal = { 1, 0 };
				else
					contact_normal = { -1, 0 };
			else if (t_near.x < t_near.y)
				if (invdir.y < 0)
					contact_normal = { 0, 1 };
				else
					contact_normal = { 0, -1 };

			// Note if t_near == t_far, collision is principly in a diagonal
			// so pointless to resolve. By returning a CN={0,0} even though its
			// considered a hit, the resolver wont change anything.
			return true;
		}-]]

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
