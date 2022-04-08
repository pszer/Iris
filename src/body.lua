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

IrisBody = {}
IrisBody.__index = IrisBody
IrisBody.__type = "irisbody"
function IrisBody:new(props)
	local t = {
		props = IrisBodyPropPrototype(props)
	}
	setmetatable(t, IrisBody)
	return t
end

--[[ computes the smallest bounding box enclosing the
--   active hitboxes in a body. the hitboxes to include
--   in the calculation in the filter argument
--   for example, body:ComputeBoundingBox{"hitbox_solid" = true}
--   only includes solid hitboxes in the calculation
--
--   returns x,y,w,h
--   if no active hitboxes are in this body or no active hitboxes match the filter
--   then it returns nil
--]]
function IrisBody:ComputeBoundingBox(filter)
	local fixtures = self:ActiveFixtures()

	local boxes = {}
	local empty = true
	for _,fixture in pairs(self.props.body_fixtures) do
		local box = {fixture:ComputeBoundingBox(filter)}
		if box[0] then
			empty = false
			table.insert(boxes, box)
		end
	end

	return ComputeBoundingBox(boxes)
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
end

-- adds a fixture to the body
-- if activate is true then it is automatically activated
function IrisBody:AddFixture(fixture, activate)
	local name = fixture.props.fixture_name
	if self.props.body_fixtures[name] then
		print("a fixture called (" .. ") already exists in body, tried to add a fixture with same name")
	else
		self.props.body_fixtures[name] = fixture
		if activate then

		end
	end
end

function IrisBody:ActivateFixture(key)
	self.props.body_activefixtures:Add(key)
end

function IrisBody:DisableFixture(key)
	self.props.body_activefixtures:Remove(key)
end

body = IrisBody:new()
body:AddFixture(testfixture, true)

print(body:ComputeBoundingBox())
