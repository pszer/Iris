--[[
-- put bodies in a world and the world then handles collision and physics
--]]
--

require "body"
require "fixture"
require "hitbox"
require "room"
require "props/worldprops"

IrisWorld = {}
IrisWorld.__index = IrisWorld
IrisWorld.__type = "irisworld"

function IrisWorld:new(props)
	local this = {
		props = IrisWorldPropPrototype(props)
	}
	setmetatable(this, IrisWorld)
	return this
end

function IrisWorld:CollectEntTable(enttable)
	return function ()
		return enttable:CollectBodies()
	end
end

function IrisWorld:CollectEntTableCollection(enttable)
	return function ()
		return enttable:CollectBodies()
	end
end

function IrisWorld:CollectBody(body)
	return function ()
		return body
	end
end

-- collects bodies from all of its given body collecting
-- functions
function IrisWorld:CollectBodies()
	local bodies = {}

	for _,collector in pairs(self.props.world_bodycollectors) do
		local b = collector()

		for _,v in pairs(b) do
			table.insert(bodies, v)
		end
	end

	return bodies
end

testworld = IrisWorld:new()
testworld:CollectBody(testroom.props.room_body)
print(testworld:CollectBodies())
