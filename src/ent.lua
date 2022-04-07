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

require "props/entprops"
require "signals"
require "timer"
require "body"

IrisEnt = {__type = "irisent"}
IrisEnt.__index = IrisEnt

function IrisEnt:new(props)
	local this = {
		props = EntPropPrototype(props),
		__signals_pending = {}
	}

	--this.props.ent_id = IrisEnt.ID()
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
		self:SendSignal("signal_deleted")
	end
end

function IrisEnt:HandleSignal(sig)
	-- do nothing
end

-- adds a signal to entities table of signals to be sent next tick
-- an entity can send multiple signals in a tick
-- same arguments as Signal:new, if sender is nil it uses this entities ID
function IrisEnt:SendNewSignal(sig, sender, dest, data, flags)
	table.insert(self.__signals_pending, Signal:new(sig,sender or self.ID,dest,data,flags))
end
-- sends signal passed as argument
function IrisEnt:SendSignalInstance(sig)
	table.insert(self.__signals_pending, sig)
end
-- sends premade signal
function IrisEnt:SendSignal(sig_type)
	local sig = IrisCreateSignal(sig_type, self)
	if sig then
		table.insert(self.__signals_pending, sig)
	end
end

function IrisEnt:ClearSignals()
	self.__signals_pending = {}
end

function IrisEnt:DebugName()
	return self.props.ent_name .. "{" .. tostring(self.props.ent_id) .. "}"
end

function IrisEnt.__tostring(ent)
	return ent:DebugName()
end

test_ent = IrisEnt:new( {x=100,y=100,name="hi",ent_sigdeletion=true})
test_ent:SendNewSignal("TEST_SIGNAL", nil, nil, nil, nil)
test_ent:Delete()
