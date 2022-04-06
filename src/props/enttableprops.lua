--[[ property table prototype for entity tables
--]]
--

require "prop"

EntTablePropPrototype = Props:prototype{
	
	{"enttable_id", "number", -1, nil,     "unique numeric id for an entity table"},
	{"enttable_name", "string", "", nil,   "name for entity table"}

}
