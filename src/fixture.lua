--[[
-- hitboxes are attached to a body through a fixture
--
-- the purpose of having fixtures instead of having bodies store the hitboxes themselves
-- is so that a body can have multiple fixtures that can be disabled/enabled. for example
-- a body may be for an entity with an animation and we want the hitboxes to match the animation,
-- a fixture can be made for each frame of the animation that describe the hitboxes for that frame
-- and these fixtures can then be cycled through along with the animation. doing the same thing
-- if bodies held hitboxes themselves would be a lot less organised.
--]]
--

require "props/fixtureprops"
require "hitbox"
require "physicsutils"

IrisFixture = {}
IrisFixture.__index = IrisFixture
IrisFixture.__type  = "irisfixture"

function IrisFixture:new(props)
	local this = {
		props = IrisFixturePropPrototype(props),

		__hitboxes_changed = true, -- used by compute bounding box to reduce recomputation
		__memo_aabb = {nil,nil,nil,nil}
	}
	setmetatable(this, IrisFixture)
	return this
end

--[[ computes the smallest bounding box enclosing the
--   hitboxes in a fixture
--
--   returns x,y,w,h
--   if no hitboxes are in this fixture
--   then it returns nil
--]]
function IrisFixture:ComputeBoundingBox()
	if self.__hitboxes_changed == false then
		local xp = self.props.fixture_parent_x
		local yp = self.props.fixture_parent_y

		return self.__memo_aabb[1] + xp,
		       self.__memo_aabb[2] + yp,
		       self.__memo_aabb[3],
		       self.__memo_aabb[4]
	end

	local boxes = {}
	local empty = true
	for _,box in pairs(self.props.fixture_hitboxes) do
		empty = false
		local b = {box:PositionOrigin()}
		table.insert(boxes, b)
	end

	if empty then
		return nil,nil,nil,nil
	else
		self.__hitboxes_changed = false
		local x,y,w,h = ComputeBoundingBox(boxes)

		self.__memo_aabb[1] = x
		self.__memo_aabb[2] = y
		self.__memo_aabb[3] = w
		self.__memo_aabb[4] = h

		return self:ComputeBoundingBox()
	end
end

-- adds a new hitbox, settings up the corrent links
function IrisFixture:AddHitbox(hitbox)
	self.__hitboxes_changed = true
	hitbox.props.hitbox_parent_x     = PropLink(self.props, "fixture_parent_x")
	hitbox.props.hitbox_parent_y     = PropLink(self.props, "fixture_parent_y")
	table.insert(self.props.fixture_hitboxes, hitbox)
end

-- creates a new hitbox with given properties
function IrisFixture:NewHitbox(props)
	self.__hitboxes_changed = true
	local hitbox = IrisHitbox:new(props)
	self:AddHitbox(hitbox)
end

function IrisFixture.__tostring(f)
	local s = "IrisFixture " .. f.props.fixture_name .. "\n"
	for _,h in pairs(f.props.fixture_hitboxes) do
		s = s .. tostring(h) .. "\n"
	end
	return s
end

testfixture = IrisFixture:new({fixture_name = "fixture1"})
testfixture:NewHitbox({hitbox_x = 5, hitbox_y = 5, hitbox_w = 10, hitbox_h = 10 })
testfixture:NewHitbox({hitbox_x = 10, hitbox_y = 10, hitbox_w = 10, hitbox_h = 10 })

testfixture2 = IrisFixture:new({fixture_name = "fixture2"})
testfixture2:NewHitbox({hitbox_x = 30, hitbox_y = 30, hitbox_w = 10, hitbox_h = 10, hitbox_solid=true})

print(testfixture.props.fixture_name)
print(testfixture2.props.fixture_name)
print(testfixture:ComputeBoundingBox())
print(testfixture:ComputeBoundingBox())
