-- tick globals
TICKTIME = 1/64.0
TICKACC = 0.0

TICK = 0

function GetTick()
	return TICK
end

function IncrementTick()
	TICK = TICK + 1
end

--[[
--timer utility classes
--two timers are offered, one counts ingame ticks, to be used for game logic
--the other counts real time
--]]

Timer = {}
Timer.__index = Timer

function Timer:new()
	local t = {
		starttick = GetTick()
		pausedifference = 0
	}
	setmetatable(t, Timer)
	return t
end

TimerReal = {}
TimerReal.__index = TimerReal

function TimerReal:new()
	local t = {
		starttick = GetTick()
		pausedifference = 0
	}
	setmetatable(t, TimerReal)
	return t
end
