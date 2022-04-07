--[[
-- basic hitboxes
--]]
--

require "props/hitboxprops"

Hitbox = {}
Hitbox.__index = Hitbox

function Hitbox:new(props)
	local box = {
		props = HitboxPropPrototype(props)
	}
	setmetatable(box, Hitbox)
	return box
end
