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
		props = IrisBodyPropPrototype(props)

		-- add AABB memo here
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
	local fixtures = self:ActiveFixtures()

	local boxes = {}
	local empty = true
	for _,fixture in ipairs(fixtures) do
		if fixture.props.fixture_solid == solid then
		local box = {fixture:ComputeBoundingBox()}
			if box[1] then
				empty = false
				table.insert(boxes, box)
			end
		end
	end

	if boxes then
		return ComputeBoundingBox(boxes)
	else
		return nil
	end
end

-- returns a table of all the active fixtures in this
-- body
function IrisBody:ActiveFixtures()
	local a = {}
	for _,key in pairs(self.props.body_activefixtures) do
		local fixture = self.props.body_fixtures[key]
		if fixture then
			table.insert(a, fixture)
		else
			print("fixture (" .. key .. ") is active in body (" .. self.props.body_name ..
			      " but this fixture doesn't exist in this body")
		end
	end
	return a
end

function IrisBody:ActiveHitboxes()
	local f = self:ActiveFixtures()
	local hitboxes = {}

	for _,fixture in ipairs(f) do
		for i,h in pairs(fixture.props.fixture_hitboxes) do
			table.insert(hitboxes, h)
		end
	end

	return hitboxes
end

-- adds a fixture to the body
-- if activate is true then it is automatically activated
function IrisBody:AddFixture(fixture, activate)
	local name = fixture.props.fixture_name
	if self.props.body_fixtures[name] then
		print("a fixture called (" .. ") already exists in body, tried to add a fixture with same name")
	else
		fixture.props.fixture_parent_x     = PropLink(self.props, "body_x")
		fixture.props.fixture_parent_y     = PropLink(self.props, "body_y")

		self.props.body_fixtures[name] = fixture
		if activate then
			self:ActivateFixture(name)
		end
	end
end

function IrisBody:ActivateFixture(key)
	self.props.body_activefixtures:Add(key)
end

function IrisBody:DisableFixture(key)
	self.props.body_activefixtures:Remove(key)
end

function IrisBody.__tostring(b)
	local s = "IrisBody " .. b.props.body_name .. "\n"
	for _,fixture in pairs(b.props.body_fixtures) do
		s = s .. tostring(fixture)
	end
	return s
end

testbody = IrisBody:new({body_x = 0, body_y = 0})
testbody:AddFixture(testfixture, true)
testbody:AddFixture(testfixture2, true)

print(testbody:ComputeBoundingBox(true))
