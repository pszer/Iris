--[[
--
-- base class for entities
-- each entity is guaranteed to have a unique numeric ID, an
-- x and y position and an update function, get/set flag function
-- and handle signal function
--
--]]

require 'table'

require "signal"

IrisEnt = { ENT_COUNTER=0 }
IrisEnt.__index = IrisEnt

function IrisEnt:new(parameters, flags)
	local this = {
		ID = self.ENT_COUNTER , -- give unique id, counter increased at end of function
		x = 0 , y = 0 ,

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
		self:SendSignal("SIG_DELETED", self.ID, -1, {})
	end
end

function IrisEnt:HandleSignal(sig)
	-- do nothing
end

-- adds a signal to entities table of signals to be sent next tick
-- an entity can send multiple signals in a tick
-- same arguments as Signal:new
function IrisEnt:SendSignal(sig, sender, dest, data)
	table.insert(SIGNALS_PENDING, Signal:new(sig,sender,dest,data))
end

function IrisEnt:ClearSignals()
	self.SIGNALS_PENDING = {}
end

test_ent = IrisEnt:new({x=100,y=100,name="hi",ENTFLAGS={"zomg"}}, {big=true})
