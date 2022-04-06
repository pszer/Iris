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
function Signal:new(signalprops)
	local this = {
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
	       "(" .. self.props.sig_type .. "," .. self.props.sig_sender .. "," .. self.props.sig_dest .. ")"
end
Signal.__tostring = function (sig)
	return sig:DebugText()
end

IRIS_SIGNALS = {

}

function IRIS_SIGNAL_REGISTERED(name)
	return IRIS_SIGNALS[name] ~= nil
end

function IRIS_REGISTER_SIGNAL(signal_prototype)
	IRIS_SIGNALS[signal_prototype.sig_type] = signal_prototype
end

function IrisCreateSignal(name, ent)
	if IRIS_SIGNALS[name] then
		return Signal:new(IRIS_SIGNALS[name]:__new(ent))
	end

	print("IrisCreateSignal: " .. name .. " is not a registered signal")
end
