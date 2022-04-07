--[[ property table prototype for bodies
--]]

require "prop"

IrisHitboxPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"body_x",   "number", 0, nil, "hitbox x position"},
	{"body_y",   "number", 0, nil, "hitbox y position"},

	{"body_name", "string", "", nil, "hitbox name"},

	{"body_enable", "boolean", false, nil, "if false a hitbox will be treated as not existing"},
	{"body_scale" , "number", 1, nil,      "multiplier for a hitbox position and scale"}

}
