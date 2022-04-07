--[[
-- basic hitboxes
--]]
--

require "prop"

Hitbox = {}
Hitbox.__index = Hitbox

function Hitbox:new(ax, ay, aw, ah, space, props)
	local box = {
		x = ax, y = ay,
		w = aw, h = ah,

		space = space
		props = 
	}
	setmetatable(box, Hitbox)
	return box
end
