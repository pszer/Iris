require "ent"

IRISGAME = {
	TICKTIME = 1/64.0,
	TICKACC = 0.0,

	ENT_TABLE
}

function IRISGAME:update(dt)
	self.TICKACC = self.TICKACC + dt
	if self.TICKACC >= self.TICKTIME then
		self.TICKACC = self.TICKACC - self.TICKTIME

		-- game logic tied to 64 HZ
	end
end

function IRISGAME:draw()

end
