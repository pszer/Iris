--[[
-- put bodies in a world and the world then handles collision and physics
--]]
--

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
