--[[
-- hitbox class
-- hitboxes are collected into hitbox collections called fixtures
--
-- hitboxes can be solid to use in physics or non-solid to be used
-- for logic
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
	local x = self.props.hitbox_x  + self.props.hitbox_parent_x
	local y = self.props.hitbox_y  + self.props.hitbox_parent_y
	local w = self.props.hitbox_w
	local h = self.props.hitbox_h

	return x,y,w,h
end

-- describes the hitboxes position without regards
-- to parent
function IrisHitbox:PositionOrigin()
	local x = self.props.hitbox_x
	local y = self.props.hitbox_y
	local w = self.props.hitbox_w
	local h = self.props.hitbox_h

	return x,y,w,h
end

function IrisHitbox.__tostring(h)
	 return "IrisHitbox\n" .. tostring(h.props)
end
