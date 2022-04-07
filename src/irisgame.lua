--[[
-- IRISGAME is responsible for storing all of the game state and has
-- the games main update and draw function
--]]

require "ent_table"
require "input"
require "prop"
require "iristype"

IRISGAME = {

	-- All signals in the current tick are collected here
	-- then deleted
	SIGNAL_TABLE = {},

	-- List of enabled entity tables
	--ENT_TABLES = {PlayerEntTable},
	ENT_TABLES = EntTableCollection:new()

	-- ENTS provides functionality for easily accessing all
	-- active entities from the table of active entity tables
	--
	-- ENTS is indexed with an entities ID, which returns the
	-- active entity with that unique entity ID
	-- the true functionality of ENTS is calling pairs(ENTS) which
	-- allows for looping over all active entities
	--[[ENTS = {}
	ENTS.__index = function (id)
		for _,enttable in pairs(ENT_TABLES) do
			
		end
	end

	--ENTS.__pairs = function ()--]]
}

IRISGAME.ENT_TABLES:AddTable(PlayerEntTable)

--[[ order for entity updates
-- 1. collect signals
-- 2. delete entities marked for deletion
-- 3. for each entity, let them handle signals then call their update function
-- 4. delete old signals
--]]
function IRISGAME:update_ents()
	-- collect all signals from entities
	local collect_signals = function (e)
		for _,sig in pairs(e.__signals_pending) do
			table.insert(self.SIGNAL_TABLE, sig)
		end
		e:ClearSignals()
	end

	--for _,entity in self.ENT_TABLES:Pairs() do
	for _,entity in pairs(self.ENT_TABLES) do
		collect_signals(entity)
		--etable:Apply(collect_signals)
	end

	-- print signals for debugging
	for _,v in pairs(self.SIGNAL_TABLE) do
		if v:GetProp("sig_debug") then
			print(GetTick() .. " SIGNAL " .. tostring(v))
		end
	end

	-- delete any entities marked for deletion (ENT_DELETE)
	self.ENT_TABLES:DeleteMarked()

	-- each entity will handle current signals
	-- then call their update functions (if flags for these are enabled)
	--
	local update = function (e)
		if e:GetProp("ent_catchsignal") then
			for _,sig in pairs(self.SIGNAL_TABLE) do
				e:HandleSignal(sig)
			end
		end

		if e:GetProp("ent_update") then
			e:Update()
		end
	end

	for _,ent in pairs(self.ENT_TABLES) do
		if ent.props.ent_update then
			ent:Update()
		end
	end

	-- delete old signals
	self.SIGNAL_TABLE = { }
end

-- adds an entity table to the active entity table list
-- the reference for an entity table in the active table list
-- should not be the only one but stored elsewhere
function IRISGAME:ActivateEntTable(enttable)
	-- check if entity table is already active
	for _,e in pairs(self.ENT_TABLES) do
		if enttable.ID == e.ID then
			return
		end
	end

	table.insert(self.ENT_TABLES, enttable) 
end

-- disables and entity table by it's unique ID
function IRISGAME:DisableEntTable(ID)
	for k,e in pairs(self.ENT_TABLES) do
		if e.ID == ID then
			table.remove(self.ENT_TABLES, k)
		end
	end
end

function IRISGAME:update(dt)
	TICKACC = TICKACC + dt
	if TICKACC >= TICKTIME then
		TICKACC = TICKACC - TICKTIME

		-- game logic tied to 64 HZ
		--

		self:update_ents()

		UpdateKeys()

		IncrementTick()
	end
end

function IRISGAME:draw()

end
