-- tick globals
TICKTIME = 1/64.0
TICKACC = 0.0

TICK = 0

function GetTick()
	return TICK
end
function GetSeconds()
	return love.timer.getTime()
end

function IncrementTick()
	TICK = TICK + 1
end

--[[
--timer utility classes
--time function used is passed as argument to Timer:new
--]]

Timer = {}
Timer.__index = Timer

function Timer:new(TIMEFUNC)
	local t = {
		timefunc = TIMEFUNC,
		starttick = TIMEFUNC(),
		pausetick = -1,         -- pausetick is -1 if not paused
		pausedifference = 0
	}
	setmetatable(t, Timer)
	return t
end

-- starts the timer, restarts if paused
function Timer:Start()
	self.starttick = self.TIMEFUNC()
	self.pausedifference = 0
	self.pausetick = -1
end

-- gets the current time since started
function Timer:Time()
	if pausetick == -1 then -- if unpaused
		return self.TIMEFUNC() - starttick - pausedifference
	else -- if paused, get time from start up to when paused
		return self.pausetick - starttick - pausedifference
	end
end

-- pauses counting ticks until resumed
-- if already paused do nothing
function Timer:Pause()
	if self.pausetick == -1 then
		self.pausetick = self.TIMEFUNC()
	end
end

-- resumes counting ticks if paused
function Timer:Resume()
	if self.pausetick ~= -1 then
		local dif = self.TIMEFUNC() - self.pausetick
		self.pausetick = -1
		self.pausedifference = self.pausedifference + dif
	end
end

-- common timers
--
-- uses ingame tick for timing
TimerTick = {}
function TimerTick:new() return Timer:new(GetTick) end

-- uses real time seconds
TimerReal = {}
function TimerReal:new() return Timer:new(GetSeconds) end

-- counts down X amount of time from creation, Done() returns true after X time passes
CountdownTimer = {}
CountdownTimer.__index = CountTicks
function CountdownTimer:new(ticks, TIMEFUNC)
	local t = Timer:new(TIMEFUNC)
	t[__ticks__] = ticks
	t:Start()
	return t
end
function CountdownTimer:Done() return self:Time() >= self.__ticks__ end

-- countdown with game ticks
CountdownTicks = {}
function CountdownTicks:new(ticks) return CountdownTimer(ticks, GetTicks) end
-- countdown with real seconds
CountdownReal = {}
function CountdownReal:new(secs) return CountdownTimer(secs, GetSeconds) end
