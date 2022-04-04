require "ent_table"

IRISGAME = {
	TICKTIME = 1/64.0,
	TICKACC = 0.0,

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
			print(v:DebugText())
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

function IRISGAME:update(dt)
	self.TICKACC = self.TICKACC + dt
	if self.TICKACC >= self.TICKTIME then
		self.TICKACC = self.TICKACC - self.TICKTIME

		-- game logic tied to 64 HZ
		--

		self:update_ents()
	end
end

function IRISGAME:draw()

end
