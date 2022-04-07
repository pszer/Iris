--[[
-- hitboxes are attached to a body through a fixture
--]]
--

require "props/fixtureprops"

IrisFixture = {}
IrisFixture.__index = IrisFixture
IrisFixture.__type  = "irisfixture"

function IrisFixture:new(props)
	local this = {
		props = IrisFixturePropPrototype(props)
	}
	setmetatable(this, IrisFixture)
	return this
end
