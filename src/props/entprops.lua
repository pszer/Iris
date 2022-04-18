--[[ property table prototype for entities
--]]
--

require "prop"
require "body"

EntPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"ent_name", "string", "undefined", nil,    "entities name"}, -- done
	{"ent_id",   "number", 0, UniqueID_Valid(), "entities unique id", "readonly"}, -- done

	{"ent_x", "number", 0, nil,                "entities x position"}, -- done
	{"ent_y", "number", 0, nil,                "entities x position"}, -- done

	{"ent_drawflag", "boolean", true , nil,        "if false entity is not drawn"}, -- done
	{"ent_updateflag", "boolean", true , nil,      "if false entity is not updated by its update function"}, -- done
	{"ent_catchsignalflag", "boolean", true , nil, "if false entity will be skipped in signal handling"}, -- done

	{"ent_update", "function", function(ent) return end, nil, "entity update function"},
	{"ent_handlesignal", "function", function(ent, sig) return end, nil, "entity handle signal function"},

	{"ent_delete", "boolean", false, nil,      "if true the entity is marked for deletion"}, -- done
	{"ent_deletewhendisabled", "boolean", false, nil, "if true the entity is deleted if in a disabled entity table"}, -- needs to be implemented 
	{"ent_sigdeletion", "boolean", true , nil, "if true the entity will send out SIG_DELETED upon deletion"}, -- done

	{"ent_hp", "number", 1, nil,               "entities health points"},
	{"ent_dieonnohp", "boolean", false, nil,   "if true an entity dies on 0 or less hp and activates death behaviour"}, -- needs to be implemented

	{"ent_body", "irisbody", IrisBody:new(), nil,         "entities body"},

	{"ent_lifetimer", "timer", nil, PropNewTimer(TimerTick), "entities lifetime timer, starts counting at entity creation"}

}
