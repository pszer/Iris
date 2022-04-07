--[[ property table prototype for hitboxes
--]]

require "prop"

SigPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"hitbox_x",   "number", 0, nil, "hitbox x position"},
	{"hitbox_y",   "number", 0, nil, "hitbox y position"},
	{"hitbox_w",   "number", 0, nil, "hitbox w position"},
	{"hitbox_h",   "number", 0, nil, "hitbox h position"},

}
