--[[
-- put bodies in a world and the world then handles collision and physics
--
-- coarse collision detection (broad phase)
-- see coarsecollision.lua
--
--]]
--

require "body"
require "fixture"
require "hitbox"
require "props/worldprops"
require "coarsecollision"

IrisWorld = {}
IrisWorld.__index = IrisWorld
IrisWorld.__type = "irisworld"

function IrisWorld:new(props)
	local this = {
		props = IrisWorldPropPrototype(props),
		__oldxvelmemory = { __mode = "k" },
		__oldyvelmemory = { __mode = "k" },
		__sortedaabb = nil,
		__sortedaabb_nonsolid = nil
	}
	setmetatable(this.__oldxvelmemory, this.__oldxvelmemory)
	setmetatable(this.__oldyvelmemory, this.__oldyvelmemory)
	setmetatable(this, IrisWorld)
	return this
end

function IrisWorld:CollectEntTable(enttable)
	local f = function ()
		return enttable:CollectBodies()
	end
	self:AddBodySourceFunction(f)
end

function IrisWorld:CollectEntTableCollection(enttable)
	local f = function ()
		return enttable:CollectBodies()
	end
	self:AddBodySourceFunction(f)
end

function IrisWorld:CollectBody(body)
	local f = function ()
		return {body}
	end
	self:AddBodySourceFunction(f)
end

function IrisWorld:CollectTable(table)
	local f = function ()
		return table
	end
	self:AddBodySourceFunction(f)
end

function IrisWorld:AddBodySourceFunction(f)
	table.insert(self.props.world_bodysources, f)
end

-- collects bodies from all of its given body collecting
-- functions
function IrisWorld:CollectBodies()
	local bodies = {}

	for _,collector in pairs(self.props.world_bodysources) do
		local b = collector()

		for _,v in ipairs(b) do
			table.insert(bodies, v)
		end
	end

	return bodies
end

-- given a table of possible body collisions to test, it will see what
-- bodies collide, settings the pairs that don't collide to nil
function IrisWorld:TestPossibleCollisions(totest, solid)
	for body1,possibles in ipairs(totest) do
		local body1 = p[1]
		local body2 = p[2]

		for i=(#possibles),1,-1 do
			--if the bodies bounding box do not collide, it is impossible
			--for their individual hitboxes to collide
			local x1,y1,w1,h1 = body1:ComputeBoundingBox(solid)
			local x2,y2,w2,h2 = body2:ComputeBoundingBox(solid)

			if not RectangleCollision(x1,y1,w1,h1, x2,y2,w2,h2) then
				table.remove(possibles, i)
			end
		end
	end
end

-- should be called at the end of game logic
function IrisWorld:UpdateBodies(bodies)
	bodies = bodies or self:CollectBodies()

	for i,v in ipairs(bodies) do
		local vprops = v.props
		if vprops.body_type ~= "static" then
			vprops.body_x = vprops.body_x + vprops.body_xvel
			vprops.body_y = vprops.body_y + vprops.body_yvel
			vprops.body_yvel = vprops.body_yvel + self.props.world_gravity

			v.__xoffset = 0
			v.__yoffset = 0
		end
	end
end


function IrisWorld:CollideBodies(bodies)
	local bodies = bodies or self:CollectBodies()

	local sortedaabb = self.__sortedaabb
	if sortedaabb == nil then
		sortedaabb = SortedAABB:new()
		sortedaabb:SortBodies(bodies, true, "", true)
		self.__sortedaabb = sortedaabb
	else
		for _,b in ipairs(bodies) do
			if b.props.body_type ~= "static" then
				self.__sortedaabb:RemoveBody(b)
				self.__sortedaabb:AddBody(b, true, true)
			end
		end
	end

	for _,b in ipairs(bodies) do
		local bprops = b.props
		bprops.body_onfloor     = false
		bprops.body_onceil      = false
		bprops.body_onleftwall  = false
		bprops.body_onrightwall = false
	end

	local possiblecollisions = sortedaabb:GetPossibleCollisions()

	-- static collisions
	for bodya,v in pairs(possiblecollisions) do
		local bodyaprops = bodya.props
		--x1,y1,w1,h1 = bodya:ComputeBoundingBoxLastFrame(true)
		x1,y1,w1,h1 = bodya:ComputeBoundingBox(true)
		local xvel = bodyaprops.body_xvel
		local yvel = bodyaprops.body_yvel
		-- we first resolve dynamic collisions, then static collisions
		local orderedcols = {}
		for _,b in ipairs(v) do
			local bodybprops = b.props
			if bodybprops.body_type == "static" then
				x2,y2,w2,h2 = b:ComputeBoundingBox(true)
				local arecolliding, contactx, contacty, normalx, normaly, time =
					DynamicRectStaticRectCollision2(x1,y1,w1,h1 , xvel,yvel, x2,y2,w2,h2)
				if arecolliding then
					table.insert(orderedcols, {b,contactx,contacty,normalx,normaly,time})
				end
			end
		end

		table.sort(orderedcols, function(a,b) return a[6]<b[6] end)
		for _,c in ipairs(orderedcols) do
			local bodyb = c[1]
			local bodyatype = bodyaprops.body_type
			local bodybtype = bodyb.props.body_type

			local handler = __BODY_TYPE_COLLISION_HANDLER__[bodyatype][bodybtype]
			if handler then
				local collided = handler(bodya, bodyb)
			end
		end
	end

	-- we first resolve dynamic collisions, then static collisions
	dynamiccols = {}
	for bodya,v in pairs(possiblecollisions) do
		local bodyaprops = bodya.props
		--x1,y1,w1,h1 = bodya:ComputeBoundingBoxLastFrame(true)
		x1,y1,w1,h1 = bodya:ComputeBoundingBox(true)
		local xvel = bodyaprops.body_xvel
		local yvel = bodyaprops.body_yvel

		local orderedcols = {}
		for _,b in ipairs(v) do
			local bodybprops = b.props
			if bodybprops.body_type == "dynamic" then
				x2,y2,w2,h2 = b:ComputeBoundingBox(true)

				local xvel2 = bodybprops.body_xvel
				local yvel2 = bodybprops.body_yvel

				local arecolliding, contactx, contacty, normalx, normaly, time, rayinrect =
					DynamicRectDynamicRectCollision2(x1,y1,w1,h1 , xvel,yvel, x2,y2,w2,h2, xvel2, yvel2)
				if arecolliding then
					table.insert(orderedcols, {b,contactx,contacty,normalx,normaly,time})
				end
			end
		end

		table.sort(orderedcols, function(a,b) return a[6]<b[6] end)
		for _,c in ipairs(orderedcols) do
			local bodyb = c[1]
			local bodyatype = bodyaprops.body_type
			local bodybtype = bodyb.props.body_type

			local handler = __BODY_TYPE_COLLISION_HANDLER__[bodyatype][bodybtype]
			if handler then
				if handler(bodya, bodyb) then
					table.insert(dynamiccols, bodya)
					table.insert(dynamiccols, bodyb)
				end
			end
		end
	end

	-- recalculate static collisions on dynamic bodies that collided
	for _,bodya in pairs(dynamiccols) do
		local v = possiblecollisions[bodya]

		if v then

			local bodyaprops = bodya.props
			local x1,y1,w1,h1 = bodya:ComputeBoundingBox(true)
			local xvel = bodyaprops.body_xvel
			local yvel = bodyaprops.body_yvel

			local orderedcols = {}
			for _,b in ipairs(v) do
				local bodybprops = b.props
				if bodybprops.body_type == "static" then
					x2,y2,w2,h2 = b:ComputeBoundingBox(true)
					local arecolliding, contactx, contacty, normalx, normaly, time =
						DynamicRectStaticRectCollision2(x1,y1,w1,h1 , xvel,yvel, x2,y2,w2,h2)
					if arecolliding then
						table.insert(orderedcols, {b,contactx,contacty,normalx,normaly,time})
					end
				end
			end

			table.sort(orderedcols, function(a,b) return a[6]<b[6] end)
			for _,c in ipairs(orderedcols) do
				local bodyb = c[1]
				local bodyatype = bodyaprops.body_type
				local bodybtype = bodyb.props.body_type

				local handler = __BODY_TYPE_COLLISION_HANDLER__[bodyatype][bodybtype]
				if handler then
					local collided = handler(bodya, bodyb)
				end
			end

		end
	end
end


-- updates entity velocities and handles collisions
-- does not update entity positions
function IrisWorld:CollideLogicBodies(bodies)
	local bodies = bodies or self:CollectBodies()

	local sortedaabb = self.__sortedaabb_nonsolid
	if sortedaabb == nil then
		sortedaabb = SortedAABB:new()
		sortedaabb:SortBodies(bodies, true, "", false)
		self.__sortedaabb_nonsolid = sortedaabb
	else
		for _,b in ipairs(bodies) do
			if b.props.body_type ~= "static" then
				self.__sortedaabb:RemoveBody(b)
				self.__sortedaabb:AddBody(b, true, false)
			end
		end
	end

	local possiblecollisions = sortedaabb:GetPossibleCollisions()

	-- static collisions
	for bodya,v in pairs(possiblecollisions) do
		local bodyaprops = bodya.props
		--x1,y1,w1,h1 = bodya:ComputeBoundingBoxLastFrame(true)
		x1,y1,w1,h1 = bodya:ComputeBoundingBox(true)
		local xvel = bodyaprops.body_xvel
		local yvel = bodyaprops.body_yvel
		-- we first resolve dynamic collisions, then static collisions
		local cols = {}
		for _,b in ipairs(v) do
			local bodybprops = b.props
			if bodybprops.body_type == "static" then
				x2,y2,w2,h2 = b:ComputeBoundingBox(true)
				local arecolliding, contactx, contacty, normalx, normaly, time =
					DynamicRectStaticRectCollision2(x1,y1,w1,h1 , xvel,yvel, x2,y2,w2,h2)
				if arecolliding then
					table.insert(cols, {b,contactx,contacty,normalx,normaly,time})
				end
			end
		end

		for _,c in ipairs(cols) do
			local bodyb = c[1]
			local bodyatype = bodyaprops.body_type
			local bodybtype = bodyb.props.body_type

			local handler = __BODY_TYPE_NONSOLID_COLLISION_HANDLER__[bodyatype][bodybtype]
			if handler then
				local collided = handler(bodya, bodyb)
			end
		end
	end

	-- we first resolve dynamic collisions, then static collisions
	for bodya,v in pairs(possiblecollisions) do
		local bodyaprops = bodya.props
		--x1,y1,w1,h1 = bodya:ComputeBoundingBoxLastFrame(true)
		x1,y1,w1,h1 = bodya:ComputeBoundingBox(true)
		local xvel = bodyaprops.body_xvel
		local yvel = bodyaprops.body_yvel

		local cols = {}
		for _,b in ipairs(v) do
			local bodybprops = b.props
			if bodybprops.body_type == "dynamic" then
				x2,y2,w2,h2 = b:ComputeBoundingBox(true)

				local xvel2 = bodybprops.body_xvel
				local yvel2 = bodybprops.body_yvel

				local arecolliding, contactx, contacty, normalx, normaly, time, rayinrect =
					DynamicRectDynamicRectCollision2(x1,y1,w1,h1 , xvel,yvel, x2,y2,w2,h2, xvel2, yvel2)
				if arecolliding then
					table.insert(cols, {b,contactx,contacty,normalx,normaly,time})
				end
			end
		end

		for _,c in ipairs(cols) do
			local bodyb = c[1]
			local bodyatype = bodyaprops.body_type
			local bodybtype = bodyb.props.body_type

			local handler = __BODY_TYPE_NONSOLID_COLLISION_HANDLER__[bodyatype][bodybtype]
			if handler then
				if handler(bodya, bodyb) then
					table.insert(dynamiccols, bodya)
					table.insert(dynamiccols, bodyb)
				end
			end
		end
	end
end

testworld = IrisWorld:new()
testworld:CollectBody(testbody)
testworld:CollectBody(testbody2)
testworld:CollectBody(testbody3)
testworld:CollectBody(testbody4)
testworld:CollectBody(testbody5)
testworld:CollectBody(testbody6)
testworld:CollectBody(testbody7)
testworld:CollectBody(testbody8)
