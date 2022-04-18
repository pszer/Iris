require "props/entprops"
require "ent"

IrisEnt_Player = {
	props = {

		ent_dieonnohp = true,
		ent_hp = 100,

		ent_update = function(self)
			local entprops = self.props
			local body = self.props.ent_body

			entprops.ent_hp = entprops.ent_hp - 1

			if QueryScancode("left", CONTROL_LOCK.INGAME) then
				body.props.body_xvel = -4
			end
			if QueryScancode("right", CONTROL_LOCK.INGAME) then
				body.props.body_xvel = 4
			end
			if QueryScancode("up", CONTROL_LOCK.INGAME) then
				if body.props.body_onfloor then
					body.props.body_yvel = -13
				end
			end
			if QueryScancode("down", CONTROL_LOCK.INGAME) then
				body.props.body_yvel = testbody3.props.body_yvel + 100
			end
		end

	},

	bodyconf = {
		"irisent_player",

		body_classes = { "entity" },
		body_classesenabled = { "world" },

		{
			"solid",

			{
				0,0,30,60
			}
		},

		{
			"hurtbox",
			fixture_solid = false,

			{
				-16,-16,62,90
			}
		}
	}
}
