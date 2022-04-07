--[[
-- hitbox class
-- hitboxes are collected into hitbox collections called bodies 
--]]
--

require "props/hitboxprops"

IrisHitbox = {}
IrisHitbox.__index = IrisHitbox
IrisHitbox.__type = "irishitbox"

function IrisHitbox:new(props)
	local box = {
		props = IrisHitboxPropPrototype(props)
	}
	setmetatable(box, IrisHitbox)
	return box
end

-- describes the hitboxes position in regards to
-- it's parent body and properties
-- returns x,y,w,h
function IrisHitbox:Position()
	local scale = self.props.hitbox_scale * self.props.hitbox_parent_scale
	local x = self.props.hitbox_x * scale + self.props.hitbox_x_origin
	local y = self.props.hitbox_y * scale + self.props.hitbox_y_origin
	local w = self.props.hitbox_w * scale
	local h = self.props.hitbox_h * scale
end
