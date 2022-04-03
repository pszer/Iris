require "ent"

IRISGAME = {
	TICKTIME = 1/64.0,
	TICKACC = 0.0,

	SIGNAL_TABLE = {},

	ENT_TABLES = {}
}

--[[ order for entity updates
-- 1. collect signals
-- 2. delete entities marked for deletion
-- 3. for each entity, let them handle signals then call their update function
-- 4. delete old signals
--]]
function IRISGAME:update_ents()
	-- collect all signals from entities
	for _,v in pairs(self.ENT_TABLE) do
		for _,sig in pairs(v.SIGNALS_PENDING) do
			table.insert(self.SIGNAL_TABLE, sig)
		end
	end

	-- delete any entities marked for deletion (ENT_DELETE)
	for k,v in pairs(self.ENT_TABLE) do
		if v:GetFlag("ENT_DELETE") then
			self.ENT_TABLE[k] = nil
		end
	end

	-- each entity will handle current signals
	-- then call their update functions (if flags for these are enabled)
	for _,v in pairs(self.ENT_TABLE) do

		if v:GetFlag("ENT_CATCHSIGNAL") then
			for _,sig in pairs(SIGNAL_TABLE) do
				v:HandleSignal(sig)
			end
		end

		if v:GetFlag("ENT_UPDATE") then
			v:Update()
		end
	end

	-- delete old signals
	SIGNAL_TABLE = { }
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
