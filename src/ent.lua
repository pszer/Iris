--[[
--
-- base class for entities
--
-- all entities have the following
-- ID                   - unique integer ID assigned at creation
-- name                 - string name for entity, not guaranteed to be
--                        unique but more convenient for identifying
--                        entities
-- x,y                  - position co-ordinates
-- Update()             - update function
-- Delete()             - marks entity for deletion
-- GetFlag(flag)        - gets flag value
-- SetFlag(flag, value) - sets flag value
-- HandleSignal(sig)    - gets given current signals
-- SendSignal(sig)      - queues a signal to send next tick
-- Props                - entity property table, properties are listed in props/entprops.lua 
--
--]]

require 'table'

require "signals"
require "timer"

IrisEnt = { ENT_COUNTER=0 , __type = "irisent"}
IrisEnt.__index = IrisEnt

function IrisEnt:new(parameters, props)
	local this = {
		ID = self.ENT_COUNTER , -- give unique id, counter increased at end of function
		x = 0 , y = 0 ,
		name = "IrisEnt" ,

		props = props ,
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

function IrisEnt:GetProp(k)
	return self.props[k]
end

function IrisEnt:SetProp(k, v)
	self.props[k] = v
end

-- marks entity for deletion
function IrisEnt:Delete()
	self:SetProp("ent_delete", true)
	if self:GetProp("ent_sigdeletion") then
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
	return self.name .. "{" .. tostring(self.ID) .. "}"
end

function IrisEnt.__tostring(ent)
	return ent:DebugName()
end

test_ent = IrisEnt:new( {x=100,y=100,name="hi"}, {ent_sigdeletion=true})
test_ent:SendNewSignal("TEST_SIGNAL", nil, nil, nil, nil)
test_ent:Delete()
