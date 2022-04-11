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
				table.insert(orderedcols, {b,contactx,contacty,normalx,normaly,time})
			end
		end

		table.sort(orderedcols, function(a,b) return a[6]<b[6] end)
		for _,c in ipairs(orderedcols) do
			local bodyb = c[1]
			local bodyatype = bodyaprops.body_type
			local bodybtype = bodyb.props.body_type

			local handler = __BODY_TYPE_COLLISION_HANDLER__[bodyatype][bodybtype]
			if handler then
				handler(bodya, bodyb)
			end
		end
	end

	self:UpdateBodies(bodies)
end


testworld = IrisWorld:new()
testworld:CollectBody(testbody)
testworld:CollectBody(testbody2)
testworld:CollectBody(testbody3)
testworld:CollectBody(testbody4)
testworld:CollectBody(testbody5)
testworld:CollectBody(testbody6)
