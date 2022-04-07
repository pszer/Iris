--[[ property table prototype for hitboxes
--]]

require "prop"

HitboxPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"hitbox_x",   "number", 0, nil, "hitbox x position"},
	{"hitbox_y",   "number", 0, nil, "hitbox y position"},
	{"hitbox_w",   "number", 0, nil, "hitbox w position"},
	{"hitbox_h",   "number", 0, nil, "hitbox h position"},

	{"hitbox_name", "string", "", nil, "hitbox name"},

	{"hitbox_x_origin", "link", PropConst(0), nil, "link to a hitbox's parent x to be treated as origin"},
	{"hitbox_y_origin", "link", PropConst(0), nil, "link to a hitbox's parent y to be treated as origin"},
}
