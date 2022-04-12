--[[ property table prototype for hitboxes
--]]

require "prop"

IrisHitboxPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"hitbox_x",   "number", 0, nil, "hitbox x position"},
	{"hitbox_y",   "number", 0, nil, "hitbox y position"},
	{"hitbox_w",   "number", 0, nil, "hitbox w position"},
	{"hitbox_h",   "number", 0, nil, "hitbox h position"},

	{"hitbox_parent_x", "link", PropConst(0), nil, "link to a hitbox's fixture x to be treated as origin"},
	{"hitbox_parent_y", "link", PropConst(0), nil, "link to a hitbox's fixture y to be treated as origin"},
	{"hitbox_parentbody", nil, nil, nil, "reference to a hitbox's parent body"},
	{"hitbox_parentfixture", nil, nil, nil, "reference to a hitbox's fixture"},

	{"hitbox_name", "string", "hitbox", nil, "hitbox name"},

	{"hitbox_enable", "boolean", false, nil,   "if false a hitbox will be treated as not existing"}, -- not done

}
