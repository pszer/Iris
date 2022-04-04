--[[
-- utility object for communication between entities
-- entities can send signals to all other entities, each signal
-- has a sender id and destination id but all entities can recieve the
-- signal and respond to it. each signal has a payload and flags
--
-- if sender/destination id is not required/unspecified use -1
--
-- entities handle signals before their update functions are called
--
-- if the SIGNAL_DEBUG flag is set it will be printed for debugging
-- ["DEBUG_TEXT"] should be used in payload for outputting debug text
--
-- common signals are in src/sig
--]]

require "flags"

Signal = {}
Signal.__index = Signal

-- STRING, INT, INT, TABLE, FLAGS
function Signal:new(signaltype, senderid, destinationid, payload, signalflags)
	local this = {
		signal = signaltype,
		sender = senderid or -1,
		destination = destionationid or -1,
		data = payload or {},
		flags = signalflags or NILFLAGS
	}
	setmetatable(this, Signal)
	return this
end

function Signal:GetKey(k)
	return self.flags[k]
end

function Signal:DebugText()
	return (self.data.DEBUG_TEXT or "") ..
	       "(" .. self.signal .. "," .. self.sender .. "," .. self.destination .. ")"
end
