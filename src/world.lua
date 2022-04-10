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
	}
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

function IrisWorld:UpdateBodies()
	bodies = self:CollectBodies()

	for i,v in ipairs(bodies) do
		if v.props.body_type ~= "static" then
			v.props.body_x = v.props.body_x + v.props.body_xvel
			v.props.body_y = v.props.body_y + v.props.body_yvel
			v.props.body_yvel = v.props.body_yvel + self.props.world_gravity
		end
	end
end

testworld = IrisWorld:new()
testworld:CollectBody(testbody)
testworld:CollectBody(testbody2)
testworld:CollectBody(testbody3)
testworld:CollectBody(testbody4)

sorted = SortedAABB:new()
sorted:SortBodies(testworld:CollectBodies(), true)

--[[for i,v in ipairs(sorted.data) do
	print(unpack(v))
end--]]

collisions = sorted:GetPossibleCollisions()
for i,v in pairs(collisions) do
	print("possible")
	print(v[1].props.body_name, v[2].props.body_name)
end
