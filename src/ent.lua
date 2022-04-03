--[[
--
-- base class for entities
-- each entity is guaranteed to have a unique numeric ID, an
-- x and y position and an update function, get/set flag function
-- and handle signal function
--
--]]

require "signal"

IrisEnt = { ENT_COUNTER=0 }
IrisEnt.__index = IrisEnt

function IrisEnt:new(parameters, flags)
	local this = {
		ID = ENT_COUNTER , -- give unique id, counter increased at end of function
		x = 0 , y = 0 ,

		entflags = flags
	}

	for k,v in pairs(parameters) do
		if k ~= "entflags" then
			this[k] = v
		end
	end

	ENT_COUNTER = ENT_COUNTER + 1
	setmetatable(this,IrisEnt)

	return this
end

function IrisEnt:Update()
	-- do nothing
end

function IrisEnt:GetFlag(k)
	return self.entflags[k]
end

function IrisEnt:SetFlag(k, v)
	self.entflags[k] = v
end

-- marks entity for deletion
function IrisEnt:Delete()
	self:SetFlag("ENT_DELETE", true)
end

function IrisEnt:HandleSignal(sig)
	-- do nothing
end

test_ent = IrisEnt:new({x=100,y=100,name="hi",entflags={"zomg"}}, {big=true})
