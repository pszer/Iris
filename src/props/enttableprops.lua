--[[ property table prototype for entity tables
--]]
--

require "prop"

EntTablePropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"enttable_id", "number", 0, UniqueID_Valid(), "unique numeric id for an entity table", "readonly"},
	{"enttable_name", "string", "", nil,            "name for entity table"}

}
