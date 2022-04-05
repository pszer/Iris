--[[ property table prototype for entities
--]]
--

require "prop"

EntPropPrototype = Props:prototype{

	{"ent_draw", "boolean", true , nil,        "if false entity is not drawn"}
	{"ent_update", "boolean", true , nil,      "if false entity is not updated by its update function"}
	{"ent_catchsignal", "boolean", true , nil, "if false entity will be skipped in signal handling"}
	{"ent_delete", "boolean", false, nil,      "if true the entity is marked for deletion"}
	{"ent_sigdeletion", "boolean", true , nil, "if true the entity will send out SIG_DELETED upon deletion"}

}
