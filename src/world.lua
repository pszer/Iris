--[[
-- put bodies in a world and the world then handles collision and physics
--]]
--

require "body"
require "fixture"
require "hitbox"

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
