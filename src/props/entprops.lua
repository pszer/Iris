--[[ property table prototype for entities
--]]
--

require "prop"

EntPropPrototype = Props:prototype{

	{"ent_name", "string", "undefined", nil,   "entities name"}, -- done
	{"ent_id",   "number", -1, nil,            "entities unique id"}, -- done

	{"ent_x", "number", 0, nil,                "entities x position"}, -- done
	{"ent_y", "number", 0, nil,                "entities x position"}, -- done

	{"ent_draw", "boolean", true , nil,        "if false entity is not drawn"}, -- done
	{"ent_update", "boolean", true , nil,      "if false entity is not updated by its update function"}, -- done
	{"ent_catchsignal", "boolean", true , nil, "if false entity will be skipped in signal handling"}, -- done

	{"ent_delete", "boolean", false, nil,      "if true the entity is marked for deletion"}, -- done
	{"ent_deletewhendisabled", "boolean", false, nil, "if true the entity is deleted if in a disabled entity table"}, -- needs to be implemented 
	{"ent_sigdeletion", "boolean", true , nil, "if true the entity will send out SIG_DELETED upon deletion"}, -- done

	{"ent_hp", "number", 1, nil,               "entities health points"},
	{"ent_dieonnohp", "boolean", false, nil,   "if true an entity dies on 0 or less hp and activates death behaviour"} -- needs to be implemented

}
