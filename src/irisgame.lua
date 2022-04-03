require "ent"

IRISGAME = {
	TICKTIME = 1/64.0,
	TICKACC = 0.0,

	SIGNAL_TABLE = {},
	ENT_TABLE = {}
}

function IRISGAME:update_ents()
	-- collect all signals from entities
	for _,v in pairs(ENT_TABLE) do
		for _,sig in pairs(v.SIGNALS_PENDING) do
			table.insert(SIGNAL_TABLE, sig)
		end
	end

	-- each entity will handle current signals
	-- then call their update functions (if these actions are enabled)
	for _,v in pairs(ENT_TABLE) do

		if v.GetFlag("ENT_CATCHSIGNAL") then
			for _,sig in pairs(SIGNAL_TABLE) do
				v.HandleSignal(sig)
			end
		end

		if v.GetFlag("ENT_UPDATE") then
			v.Update()
		end
	end

	-- delete any entities marked for deletion
	for _,v in pairs(ENT_TABLE) do
		if v.GetFlag("ENT_UPDATE") then
			v.Update()
		end
	end
end

function IRISGAME:update(dt)
	self.TICKACC = self.TICKACC + dt
	if self.TICKACC >= self.TICKTIME then
		self.TICKACC = self.TICKACC - self.TICKTIME

		-- game logic tied to 64 HZ
	end
end

function IRISGAME:draw()

end
