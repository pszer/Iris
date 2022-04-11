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
require "room"
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
		__sortedaabb = nil
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
		return enttable:CreateBodies()
	end
	self:AddBodySourceFunction(f)
end

function IrisWorld:CollectBody(body)
	local f = function ()
		return {body}
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

function IrisWorld:UpdateBodies(bodies)
	bodies = bodies or self:CollectBodies()

	for i,v in ipairs(bodies) do
		local vprops = v.props
		if vprops.body_type ~= "static" then
			vprops.body_x = vprops.body_x + vprops.body_xvel
			vprops.body_y = vprops.body_y + vprops.body_yvel
			vprops.body_yvel = vprops.body_yvel + self.props.world_gravity
		end
	end
end

function IrisWorld:ApplyGravity(bodies)
	bodies = bodies or self:CollectBodies()

	for i,v in ipairs(bodies) do
		if v.props.body_type ~= "static" then
			v.props.body_yvel = v.props.body_yvel + self.props.world_gravity
		end
	end
end


-- recalculates body velocities
--[[
function IrisWorld:CollideBodies(bodies, updatebodies)
	bodies = bodies or self:CollectBodies()
	local sortedaabb = self.__sortedaabb

	local oldxvels = self.__oldxvelmemory
	local oldyvels = self.__oldyvelmemory
	for i,b in ipairs(bodies) do
		local bprops = b.props
		-- memorise bodies velocity before recalculation
		oldxvels[b], oldyvels[b] = bprops.body_xvel, bprops.body_yvel
		bprops.body_x = bprops.body_x + bprops.body_xvel
		bprops.body_y = bprops.body_y + bprops.body_yvel

		-- reinsert body into sortedaabb
		if sortedaabb then
			-- do something
		end
	end

	if sortedaabb == nil then
		sortedaabb = SortedAABB:new()
		sortedaabb:SortBodies(bodies, true)
		--self.__sortedaabb = sortedaabb <---- add reusing aabb
	end


	for i,b in ipairs(bodies) do
		local bprops = b.props
		--bprops.body_x = bprops.body_x - oldxvels[b]
		--bprops.body_y = bprops.body_y - oldyvels[b]
		bprops.body_x = bprops.body_x - bprops.body_xvel
		bprops.body_y = bprops.body_y - bprops.body_yvel
	end

	collisions = sorted:GetPossibleCollisions()
	for bodya,v in pairs(collisions) do
		local bodyaprops = bodya.props

		x1,y1,w1,h1 = bodya:ComputeBoundingBox(true)
		local xvel = bodyaprops.body_xvel
		local yvel = bodyaprops.body_yvel

		local orderedcols = {}
		for _,bodyb in ipairs(v) do
			x2,y2,w2,h2 = bodyb:ComputeBoundingBox(true)
			print()
			print(x1,y1,w1,h1, xvel,yvel)
			print(x2,y2,w2,h2)

			local arecolliding, contactx, contacty, normalx, normaly, time =
				DynamicRectStaticRectCollision(x1,y1,w1,h1 , xvel,yvel, x2,y2,w2,h2)

			if arecolliding then
				table.insert(orderedcols, {bodyb,contactx,contacty,normalx,normaly,time})
			end
		end

		table.sort(orderedcols, function(a,b) return a[6]<b[6] end)
		for _,c in ipairs(orderedcols) do
			--[[local newxvel, newyvel = ResolveDynamicRectStaticRectCollision(w1, h1, xvel, yvel,
			  c[2], c[3], c[4], c[5], c[6])--]]

			--[[
			local bodyb = c[1]
			local bodyatype = bodyaprops.body_type
			local bodybtype = bodyb.props.body_type

			local handler = __BODY_TYPE_COLLISION_HANDLER__[bodyatype][bodybtype]
			if handler then
				handler(bodya, bodyb, true, true)
			end
			local newxvel, newyvel = ResolveDynamicRectStaticRectCollision(w1, h1, xvel, yvel,
			  c[2], c[3], c[4], c[5], c[6])
			bodyaprops.body_xvel = newxvel
			bodyaprops.body_yvel = newyvel
		end

		--[[local old_xvel = oldxvels[bodya]
		local old_yvel = oldyvels[bodya]
		bodyaprops.body_x = bodyaprops.body_x - old_xvel
		bodyaprops.body_y = bodyaprops.body_y - old_yvel
	end

	self.__sortedaabb = nil
	self:UpdateBodies(bodies)
end--]]

function IrisWorld:CollideBodies(bodies)
	local bodies = bodies or self:CollectBodies()

	local sortedaabb = self.__sortedaabb
	if sortedaabb == nil then
		sortedaabb = SortedAABB:new()
		sortedaabb:SortBodies(bodies, true, "x", true)
		--self.__sortedaabb = sortedaabb <---- add reusing aabb
	end

	print("")
	local possiblecollisions = sortedaabb:GetPossibleCollisions()
	for bodya,v in pairs(possiblecollisions) do
		local bodyaprops = bodya.props
		--x1,y1,w1,h1 = bodya:ComputeBoundingBoxLastFrame(true)
		x1,y1,w1,h1 = bodya:ComputeBoundingBox(true)
		local xvel = bodyaprops.body_xvel
		local yvel = bodyaprops.body_yvel

		local orderedcols = {}
		for _,b in ipairs(v) do
			x2,y2,w2,h2 = b:ComputeBoundingBox(true)
			local arecolliding, contactx, contacty, normalx, normaly, time =
				DynamicRectStaticRectCollision2(x1,y1,w1,h1 , xvel,yvel, x2,y2,w2,h2)
			if arecolliding then
				print("testing ", b.props.body_name)
				table.insert(orderedcols, {b,contactx,contacty,normalx,normaly,time})
			end
		end

		table.sort(orderedcols, function(a,b) if a[6] and b[6] then return a[6]<b[6] else return true end end)
		for _,c in ipairs(orderedcols) do
			local bodyb = c[1]
			local bodyatype = bodyaprops.body_type
			local bodybtype = bodyb.props.body_type

			local handler = __BODY_TYPE_COLLISION_HANDLER__[bodyatype][bodybtype]
			if handler then
				handler(bodya, bodyb, true, true)
			end
		end
	end

	self.__sortedaabb = nil
	self:UpdateBodies(bodies)
end

--[[
function IrisWorld:CollideBodies(bodies)
	local bodies = bodies or self:CollectBodies()

	local sortedaabb = self.__sortedaabb
	if sortedaabb == nil then
		sortedaabb = SortedAABB:new()
		sortedaabb:SortBodies(bodies, true)
		--self.__sortedaabb = sortedaabb <---- add reusing aabb
	end

	local possiblecollisions = sortedaabb:GetPossibleCollisions()
	self:TestPossibleCollisions(possiblecollisions)
	for bodya,v in pairs(possiblecollisions) do
		local bodyaprops = bodya.props
		x1,y1,w1,h1 = bodya:ComputeBoundingBoxLastFrame(true)
		local xvel = bodyaprops.body_xvel
		local yvel = bodyaprops.body_yvel

		local orderedcols = {}
		for _,b in ipairs(v) do
			--print("  ", b.props.body_name)
			x2,y2,w2,h2 = b:ComputeBoundingBoxLastFrame(true)
			--print("  ",x2,y2,w2,h2)
			local arecolliding, contactx, contacty, normalx, normaly, time =
				DynamicRectStaticRectCollision(x1,y1,w1,h1 , xvel,yvel, x2,y2,w2,h2)
			if arecolliding then
				table.insert(orderedcols, {b,contactx,contacty,normalx,normaly,time})
			end
		end


		table.sort(orderedcols, function(a,b) return a[6]<b[6] end)
		for _,c in ipairs(orderedcols) do
			local newxvel, newyvel = ResolveDynamicRectStaticRectCollision(w1, h1, xvel, yvel,
			  c[2], c[3], c[4], c[5], c[6])
			bodya.props.body_xvel = newxvel
			bodya.props.body_yvel = newyvel
		end
		

		local old_xvel = bodya.props.body_xvel
		local old_yvel = bodya.props.body_yvel
		for _,bodyb in ipairs(v) do

			local bodyatype = bodyaprops.body_type
			local bodybtype = bodyb.props.body_type

			local handler = __BODY_TYPE_COLLISION_HANDLER__[bodyatype][bodybtype]
			if handler then
				handler(bodya, bodyb, true, true)
			end
		end
			
		bodyaprops.body_x = bodyaprops.body_x - old_xvel
		bodyaprops.body_y = bodyaprops.body_y - old_yvel
	end

	self.__sortedaabb = nil
	self:UpdateBodies(bodies)
end--]]


testworld = IrisWorld:new()
testworld:CollectBody(testbody)
testworld:CollectBody(testbody2)
testworld:CollectBody(testbody3)
testworld:CollectBody(testbody4)
testworld:CollectBody(testbody5)
testworld:CollectBody(testbody6)

sorted = SortedAABB:new()
sorted:SortBodies(testworld:CollectBodies(), true)

--[[for i,v in ipairs(sorted.data) do
	print(unpack(v))
end--]]

collisions = sorted:GetPossibleCollisions()
--[[for i,v in pairs(collisions) do
	print("possible")
	print(i.props.body_name, v[2].props.body_name)
end--]]
