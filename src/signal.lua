--[[
-- utility object for communication between entities
-- entities can send signals to all other entities, each signal
-- has a sender id and destination id but all entities can recieve the
-- signal and respond to it. each signal has a payload and flags
--]]

require "flags"

Signal = {}
Signal.__index = Signal

-- STRING, INT, INT, TABLE, FLAGS
function Signal.new(signaltype, senderid, destinationid, payload, signalflags)
	local this = {
		signal = signaltype,
		sender = senderid,
		destination = destionationid,
		data = payload,
		flags = signalflags
	}
	setmetatable(this, Signal)
	return this
end
