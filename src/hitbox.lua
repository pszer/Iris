--[[
-- hitbox class
-- hitboxes are collected into hitbox collections called fixtures
--
-- hitboxes can be solid to use in physics or non-solid to be used
-- for logic
--]]
--

require 'math'
require "props/hitboxprops"

IrisHitbox = {}
IrisHitbox.__index = IrisHitbox
IrisHitbox.__type = "irishitbox"

function IrisHitbox:new(props)
	local box = {
		props = IrisHitboxPropPrototype(props),

		-- normal of hypotenuse for triangle hitboxes
		__hyp_normalx = 0,
		__hyp_normaly = 0
	}
	setmetatable(box, IrisHitbox)

	if box.props.hitbox_shape == "triangle" then
		local W = box.props.hitbox_w
		local H = box.props.hitbox_h
		local d = math.sqrt(W*W + H*H)
		local w = H/d
		local h = W/d

		local orient = box.props.hitbox_triangleorientation

		local x,y = 0,0
		if orient == "topright" then
			x = w
			y = -h
		elseif orient == "topleft" then
			x = -w
			y = -h
		elseif orient == "bottomleft" then
			x = -w
			y = h
		else
			x = w
			y = h
		end

		box.__hyp_normalx = x
		box.__hyp_normaly = y
	end

	return box
end

-- describes the hitboxes position in regards to
-- it's parent body and properties
-- returns x,y,w,h
function IrisHitbox:Position(add_velocity)
	local props = self.props
	local xv, yv = 0, 0
	if add_velocity then
		local b = props.hitbox_parentbody
		if b then
			local bprops = b.props
			xv = bprops.body_xvel
			yv = bprops.body_yvel
		end
	end

	local x = props.hitbox_x  + props.hitbox_parent_x + xv
	local y = props.hitbox_y  + props.hitbox_parent_y + yv
	local w = props.hitbox_w
	local h = props.hitbox_h

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

function IrisHitbox:CanCollideWith(b)
	if not b then
		return false
	end
	local selfbody = self.props.hitbox_parentbody
	local bbody = b.props.hitbox_parentbody
	if selfbody and bbody then
		if selfbody:CanCollideWith(bbody) then
			return true, self, b
		end
		return false
	else
		return false
	end
end

function IrisHitbox.__tostring(h)
	 return "IrisHitbox " .. h.props.hitbox_name
end
