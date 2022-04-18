--[[ property table prototype for rooms
--]]

require "prop"
require "body"

IrisRoomPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"room_name", "string", "room", nil,  "rooms name"},

	{"room_width", "number", 1, PropMin(100), "rooms width" },
	{"room_height", "number", 1, PropMin(100), "rooms width" },

	{"room_geometry", "table", nil, PropDefaultTable{}, [[rooms static geometry, each entry should have properties x,y,w,h
	                                                      orient (nil if not a triangle) and a property table called props]]},
	{"room_entspawners", "table", nil, PropDefaultTable{}, [[rooms entity information, each entry should be a table of properties
	                                                         for that entity]]},
	{"room_worldprops", "table", nil, PropDefaultTable{}, [[property table for world]]}
}
