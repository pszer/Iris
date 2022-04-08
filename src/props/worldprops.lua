--[[ property table prototype for worlds
--]]

require "prop"

IrisWorldPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"world_w", "number", 1000, PropMin(1),  "worlds width"},
	{"world_h", "number", 1000, PropMin(1),  "worlds height"},

	{"world_bodycollectors", "table", nil, PropDefaultTable{}, [[table of functions to call to collect bodies in this world,
	                                                             these collector functions should return tables of bodies]]}
}
