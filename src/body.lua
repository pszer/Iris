--[[
-- bodies are objects with a position and velocity
-- there are three types of bodies, dynamic bodies that
-- collide with all types of bodies, static bodies that do not
-- move and kinematic bodies that only collide with dynamic bodies
--
-- a bodies shape is described by a collection of hitboxes
-- hitboxes serve two main purposes, they can be solid and collide with other hitboxes
-- for physics or they can be non-solid logic hitboxes that describe the area
-- an attack hits, areas a player can interact with objects, environment
-- damage areas etc.
-- these collections of hitboxes are called fixtures (src/fixture.lua)
--
-- bodies are used in the game mainly for two purposes, the geometry and trigger areas of a map
-- is a static body and entities have dynamic/kinematic bodies for physics with the world and
-- interaction with other entities
--
--]]
--

require "props/bodyprops"
require "hitbox"
require "fixture"
require "set"

IrisBody = {}
IrisBody.__index = IrisBody
IrisBody.__type = "irisbody"
function IrisBody:new(props)
	local t = {
		props = IrisBodyPropPrototype(props),

		__activehitboxesmemo = {},
		__activehitboxeschanged = true,
		-- add AABB memo here
		__activeAABBmemo_solid = {nil,nil,nil,nil},
		__activeAABBmemo_solid_changed = true,
		__activeAABBmemo_nonsolid = {nil,nil,nil,nil},
		__activeAABBmemo_nonsolid_changed = true,

		__fixtures = {},
		__activefixtures = Set:new()
	}
	setmetatable(t, IrisBody)
	return t
end

--[[ computes the smallest bounding box enclosing the
--   active hitboxes in a body. the argument is for whether
--   you want the bounding box for solid fixtures or non-solid fixtures
--
--   returns x,y,w,h
--   if no active hitboxes are in this body or no active hitboxes match the filter
--   then it returns nil
--]]
function IrisBody:ComputeBoundingBox(solid)
	local aabbmemo, aabbmemochanged
	if solid then
		aabbmemo = self.__activeAABBmemo_solid
		aabbmemochanged = self.__activeAABBmemo_solid_changed
	else
		aabbmemo = self.__activeAABBmemo_nonsolid
		aabbmemochanged = self.__activeAABBmemo_nonsolid_changed
	end

	if not aabbmemochanged then
		return self.props.body_x + aabbmemo[1],
		       self.props.body_y + aabbmemo[2],
		       aabbmemo[3], aabbmemo[4]
	end

	local fixtures = self:ActiveFixtures()

	local boxes = {}
	local empty = true
	for _,fixture in ipairs(fixtures) do
		if fixture.props.fixture_solid == solid then
			local box = {fixture:ComputeBoundingBox()}
			if box[1] then
				empty = false
				boxes[#boxes+1] = box
			end
		end
	end

	print("BOXES",#boxes)

	local x,y,w,h = nil,nil,nil,nil
	if boxes then
		x,y,w,h = ComputeBoundingBox(boxes)

		local tx = x - self.props.body_x
		local ty = y - self.props.body_y

		aabbmemo[1],aabbmemo[2],aabbmemo[3],aabbmemo[4] = tx,ty,w,h
	end

	if solid then
		self.__activeAABBmemo_solid_changed = false
	else
		self.__activeAABBmemo_nonsolid_changed = false
	end
	
	return x,y,w,h
end

-- returns a table of all the active fixtures in this
-- body
function IrisBody:ActiveFixtures()
	return self.__activefixtures
end

function IrisBody:ActiveHitboxes()
	local a = self.__activehitboxesmemo
	if not self.__activehitboxeschanged then
		return a
	end

	local f = self:ActiveFixtures()

	for i=1,#a do
		a[i]=nil
	end
	for _,fixture in ipairs(f) do
		for i,h in pairs(fixture.props.fixture_hitboxes) do
			a[#a+1] = h
		end
	end

	self.__activehitboxeschanged = false
	return a
end

-- adds a fixture to the body
-- if activate is true then it is automatically activated
function IrisBody:AddFixture(fixture, activate)
	local selfprops = self.props
	fixture.props.fixture_parent_x = PropLink(selfprops, "body_x")
	fixture.props.fixture_parent_y = PropLink(selfprops, "body_y")

	local f = self.__fixtures
	f[#f+1] = fixture
	if activate then
		self:ActivateFixture(fixture)
	end
end

function IrisBody:ActivateFixture(fixture)
	self.__activefixtures:Add(fixture)
	self.__activehitboxeschanged = true

	if fixture.props.fixture_solid then
		self.__activeAABBmemo_solid_changed = true
	else
		self.__activeAABBmemo_nonsolid_changed = true
	end
end

function IrisBody:DisableFixture(fixture)
	self.__activefixtures:Remove(fixture)
	self.__activehitboxeschanged = true

	if fixture.props.fixture_solid then
		self.__activeAABBmemo_solid_changed = true
	else
		self.__activeAABBmemo_nonsolid_changed = true
	end
end

function IrisBody.__tostring(b)
	local s = "IrisBody " .. b.props.body_name .. "\n"
	for _,fixture in pairs(b.__fixtures) do
		s = s .. tostring(fixture)
	end
	return s
end

__BODY_TYPE_COLLISION_COMPARE__ = {
 static={}, dynamic={}, kinematic={}}
__BODY_TYPE_COLLISION_COMPARE__["static"]["static"]    = false
__BODY_TYPE_COLLISION_COMPARE__["static"]["dynamic"]   = true
__BODY_TYPE_COLLISION_COMPARE__["dynamic"]["static"]   = true
__BODY_TYPE_COLLISION_COMPARE__["dynamic"]["dynamic"]  = true
__BODY_TYPE_COLLISION_COMPARE__["kinematic"]["static"]  = false
__BODY_TYPE_COLLISION_COMPARE__["static"]["kinematic"]  = false
__BODY_TYPE_COLLISION_COMPARE__["kinematic"]["dynamic"]  = true
__BODY_TYPE_COLLISION_COMPARE__["dynamic"]["kinematic"]  = true
__BODY_TYPE_COLLISION_COMPARE__["kinematic"]["kinematic"]  = true
function IrisBody:CanCollideWith(body)
	local selftype = self.props.body_type
	local bodytype = body.props.body_type
	if not __BODY_TYPE_COLLISION_COMPARE__[selftype][bodytype] then
		return false
	end

	--[[local sprops = self.props
	local bprops = body.props
	local sclasses = sprops.body_classes
	local sclassesenabled = sprops.body_classesenabled
	local bclasses = bprops.body_classes
	local bclassesenabled = sprops.body_classesenabled--]]

	return true
end

testfixture = IrisFixture:new({fixture_name = "fixture1"})
testfixture:NewHitbox({hitbox_x = 50, hitbox_y = 50, hitbox_w = 100, hitbox_h = 100 })
testfixture:NewHitbox({hitbox_x = 0, hitbox_y = 00, hitbox_w = 100, hitbox_h = 100 })
testbody = IrisBody:new({body_x = 240, body_y = 0, body_name = "body1"})
testfixture12 = IrisFixture:new({fixture_name = "fixture12"})
testfixture12:NewHitbox({hitbox_x = 65, hitbox_y = 65, hitbox_w = 100, hitbox_h = 100 })
testbody:AddFixture(testfixture, true)
testbody:AddFixture(testfixture12, true)

testfixture2 = IrisFixture:new({fixture_name = "fixture2"})
testfixture2:NewHitbox({hitbox_x = 0, hitbox_y = 0, hitbox_w = 100, hitbox_h = 100})
testbody2 = IrisBody:new({body_x = 30, body_y = 30, body_name = "body2"})
testbody2:AddFixture(testfixture2, true)

testfixture3 = IrisFixture:new({fixture_name = "fixture3"})
testfixture3:NewHitbox({hitbox_x = 0, hitbox_y = 0, hitbox_w = 100, hitbox_h = 100})
testbody3 = IrisBody:new({body_x = 550, body_y = 150, body_name = "body3"})
testbody3:AddFixture(testfixture3, true)

testfixture4 = IrisFixture:new({fixture_name = "fixture4"})
testfixture4:NewHitbox({hitbox_x = 0, hitbox_y = 0, hitbox_w = 800, hitbox_h = 100})
testbody4 = IrisBody:new({body_x = 0, body_y = 350, body_name = "body3", body_type = "static"})
testbody4:AddFixture(testfixture4, true)

print("ppp")
--print(testbody:ComputeBoundingBox(true))
print(testbody2:ComputeBoundingBox(true))
print("ppp")
