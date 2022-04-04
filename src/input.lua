--[[ ingame key/mouse inputs should be queried through here
--]]
--

--[[
-- When inputs are to be queried, they are queried at some control lock level.
-- Control locks can be opened/closed, if a control lock is closed
-- all queries at that control lock level will be blocked (false). When
-- control locks are open, only queries for the highest priority lock are
-- enabled. All control locks are placed at unique priority levels.
--
-- This means that controls are only read by one part of the game at a time, e.g.
-- if an inventory menu is opened inputs for character movement which is at a lower
-- priority is blocked.
--
-- A control lock can be forced open to read inputs even if higher priority locks
-- are open. It will be skipped in checking priority for other open locks.
-- A control lock can be given elevated priority to block inputs to all other locks
--
--]]

--[[
-- Use:
--
-- CONTROL_LOCK.lockname returns if lockname is enabled
--
-- these functions change a locks status
-- CONTROL_LOCK.lockname.Close()
-- CONTROL_LOCK.lockname.Open()
-- CONTROL_LOCK.lockname.ForceOpen()
-- CONTROL_LOCK.lockname.Elevate()
--
--]]

require 'table'

-- lower priority number = higher priority
--
-- status
-- 0 = closed
-- 1 = opened
-- 2 = forced open
-- 3 = elevated priority
--
CONTROL_LOCK = {
--              priority | status
	CONSOLE     = {0,        0},

	TOPMENU     = {5,        0},
	MENU4       = {6,        0},
	MENU3       = {7,        0},
	MENU1       = {8,        0},
	MENU1       = {9,        0},

	INGAMETEXT  = {100,      0},
	INGAME      = {101,      0}
}

function ADD_CONTROL_LOCK(name, priority)
	for _,lock in pairs(CONTROL_LOCK) do
		if priority == lock[1] then
			print("Failed adding control lock " .. name .. ". Priority level " .. priority
			      .. " already exists")
			return
		end
	end
	CONTROL_LOCK[name] = {priority, 0}
	setmetatable(CONTROL_LOCK, CONTROL_LOCK_METATABLE)
end

-- metatable for each control lock in CONTROL_LOCK
CONTROL_LOCK_METATABLE = {
	Close      = function(lock) lock[2] = 0 end,
	Open       = function(lock) lock[2] = 1 end,
	ForceOpen  = function(lock) lock[2] = 2 end,
	Elevate    = function(lock) lock[2] = 3 end
}
CONTROL_LOCK_METATABLE.__index = function (lock,t)
	return function() CONTROL_LOCK_METATABLE[t](lock) end
end
CONTROL_LOCK_METATABLE.__call  = function(t)
	if t == nil then
		print("Control lock " .. lock_name .. " doesn't exist!")
		return false
	end

	-- closed
	if t[2] == 0 then
		return false
	end

	-- forced open / elevated priority
	if t[2] == 3 or t[2] == 2 then
		return true
	end

	for _,lock in pairs(CONTROL_LOCK) do
		if lock ~= t then
			-- ignore this lock if its closed/forced open
			if not (lock[2] == 0 or t[2] == 2) then

				-- if a lock has elevated priority this lock
				-- and all others are disabled
				if lock[2] == 3 then
					return false
				end

				-- if a lock with higher priority is open
				-- this lock is disabled
				if lock[2] == 1 and lock[1] < t[1] then
					return false
				end
			end
		end
	end

	return true
end
setmetatable(CONTROL_LOCK_METATABLE, CONTROL_LOCK_METATABLE)

for _,lock in pairs(CONTROL_LOCK) do
	setmetatable(lock, CONTROL_LOCK_METATABLE)
end
