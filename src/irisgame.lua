require "ent_table"
require "input"
require "prop"

IRISGAME = {
	SIGNAL_TABLE = {},

	ENT_TABLES = {PlayerEntTable}
}

--[[ order for entity updates
-- 1. collect signals
-- 2. delete entities marked for deletion
-- 3. for each entity, let them handle signals then call their update function
-- 4. delete old signals
--]]
function IRISGAME:update_ents()
	-- collect all signals from entities
	local collect_signals = function (e)
		for _,sig in pairs(e.SIGNALS_PENDING) do
			table.insert(self.SIGNAL_TABLE, sig)
		end
		e:ClearSignals()
	end


	for _,etable in pairs(self.ENT_TABLES) do
		etable:Apply(collect_signals)
	end

	-- print signals for debugging
	for _,v in pairs(self.SIGNAL_TABLE) do
		if v:GetKey("SIG_DEBUG") then
			print(GetTick() .. " SIGNAL " .. v:DebugText())
		end
	end

	-- delete any entities marked for deletion (ENT_DELETE)
	for _,etable in pairs(self.ENT_TABLES) do
		etable:DeleteMarked()
	end

	-- each entity will handle current signals
	-- then call their update functions (if flags for these are enabled)
	--
	local update = function (e)
		if e:GetFlag("ENT_CATCHSIGNAL") then
			for _,sig in pairs(self.SIGNAL_TABLE) do
				e:HandleSignal(sig)
			end
		end

		if e:GetFlag("ENT_UPDATE") then
			e:Update()
		end
	end

	for _,etable in pairs(self.ENT_TABLES) do
		etable:Apply(update)
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

		IncrementTick()

		self:update_ents()
	end
end

function IRISGAME:draw()

end
