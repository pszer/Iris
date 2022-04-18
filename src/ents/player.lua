require "props/entprops"
require "ent"

IrisEnt_Player = {
	props = {

		ent_update = function(self)
			if QueryScancode("left", CONTROL_LOCK.INGAME) then
				self.props.body_xvel = -4
			end
			if QueryScancode("right", CONTROL_LOCK.INGAME) then
				self.props.body_xvel = 4
			end
			if QueryScancode("up", CONTROL_LOCK.INGAME) then
				if self.props.body_onfloor then
					self.props.body_yvel = -13
				end
			end
			if QueryScancode("down", CONTROL_LOCK.INGAME) then
				self.props.body_yvel = testbody3.props.body_yvel + 100
			end
		end

	}

	bodyconf = {
		"irisent_player"

		{
			"solid"

			{
				0,0,30,60
			}
		}
	}
}
