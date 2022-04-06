--[[
-- utility object for communication between entities and for communication
-- between entities and the game state
-- entities can send signals to all other entities, each signal
-- has a sender id and destination id but all entities can recieve the
-- signal and respond to it. each signal has a payload and properties
--
-- if sender/destination id is not required/unspecified use -1
--
-- entities handle signals before their update functions are called
--
-- if the sig_debug prop is set it will be printed for debugging
-- [sig_debug_text] should be used in property table for outputting debug text
--
-- common signals are in src/sig
--]]

require "props/sigprops"

Signal = {}
Signal.__index = Signal

-- STRING, INT, INT, TABLE, FLAGS
function Signal:new(signaltype, senderid, destinationid, payload, signalprops)
	local this = {
		signal = signaltype,
		sender = senderid or -1,
		destination = destionationid or -1,
		data = payload or {},
		props = SigPropPrototype(signalprops) 
	}
	setmetatable(this, Signal)
	return this
end

function Signal:GetProp(k)
	return self.props[k]
end

function Signal:DebugText()
	return (self.props.sig_debugtext or "") ..
	       "(" .. self.signal .. "," .. self.sender .. "," .. self.destination .. ")"
end
Signal.__tostring = function (sig)
	return sig:DebugText()
end
