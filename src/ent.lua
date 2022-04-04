--[[
--
-- base class for entities
-- each entity is guaranteed to have a unique numeric ID, an
-- x and y position and an update function, get/set flag function
-- and handle signal function
--
--]]

require 'table'

require "signals"

IrisEnt = { ENT_COUNTER=0 }
IrisEnt.__index = IrisEnt

function IrisEnt:new(parameters, flags)
	local this = {
		ID = self.ENT_COUNTER , -- give unique id, counter increased at end of function
		x = 0 , y = 0 ,
		name = "IrisEnt" ,

		ENTFLAGS = flags ,
		SIGNALS_PENDING = {}
	}

	for k,v in pairs(parameters) do
		if k ~= "ENTFLAGS" then
			this[k] = v
		end
	end

	self.ENT_COUNTER = self.ENT_COUNTER + 1
	setmetatable(this,IrisEnt)

	return this
end

function IrisEnt:Update()
	-- do nothing
end

function IrisEnt:GetFlag(k)
	return self.ENTFLAGS[k]
end

function IrisEnt:SetFlag(k, v)
	self.ENTFLAGS[k] = v
end

-- marks entity for deletion
function IrisEnt:Delete()
	self:SetFlag("ENT_DELETE", true)
	if self:GetFlag("ENT_SIGDELETION") then
		self:SendSignal(SIG_DELETED:new(self))
	end
end

function IrisEnt:HandleSignal(sig)
	-- do nothing
end

-- adds a signal to entities table of signals to be sent next tick
-- an entity can send multiple signals in a tick
-- same arguments as Signal:new, if sender is nil it uses this entities ID
function IrisEnt:SendNewSignal(sig, sender, dest, data, flags)
	table.insert(self.SIGNALS_PENDING, Signal:new(sig,sender or self.ID,dest,data,flags))
end
-- sends signal passed as argument, sending pre-existing signals in src/sig is preferable
function IrisEnt:SendSignal(sig)
	table.insert(self.SIGNALS_PENDING, sig)
end

function IrisEnt:ClearSignals()
	self.SIGNALS_PENDING = {}
end

function IrisEnt:DebugName()
	return self.name + "{" + tostring(self.ID) + "}"
end

test_ent = IrisEnt:new({x=100,y=100,name="hi",ENTFLAGS={"zomg"}}, {big=true})
test_ent:SendNewSignal("TEST_SIGNAL", nil, nil, nil, nil)
