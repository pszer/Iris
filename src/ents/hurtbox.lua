require "props/entprops"
require "ent"

IrisEnt_Hurtbox = {
	props = {

		ent_dieonnohp = false,
		ent_hp = 1,

	},

	bodyconf = {
		"irisent_hurtbox",

		body_classes = { "world" },
		body_classesenabled = { "entity" },

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
