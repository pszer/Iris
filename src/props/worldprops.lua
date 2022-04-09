--[[ property table prototype for worlds
--]]

require "prop"

IrisWorldPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"world_w", "number", 1000, PropMin(100),  "worlds width" , "readonly"},
	{"world_h", "number", 1000, PropMin(100),  "worlds height", "readonly"},

	{"world_hierarchydepth", "number", 3, PropInteger(), "worlds hierarchy grid depth", "readonly"},

	{"world_bodycollectors", "table", nil, PropDefaultTable{}, [[table of functions to call to collect bodies in this world,
	                                                             these collector functions should return tables of bodies]]}
}
