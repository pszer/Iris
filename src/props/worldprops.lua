--[[ property table prototype for worlds
--]]

require "prop"

IrisWorldPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"world_w", "number", 1000, PropMin(100),  "worlds width" , "readonly"},
	{"world_h", "number", 1000, PropMin(100),  "worlds height", "readonly"},

	{"world_gravity", "number", 0.4, nil, "worlds gravity"},

	{"world_bodysources", "table", nil, PropDefaultTable{}, [[table of functions to call to get bodies in this world,
	                                                          these collector functions should take the world as argument]]}
}
