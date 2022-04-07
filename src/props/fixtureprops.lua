--[[ property table prototype for fixtures
--]]
--

require "prop"

IrisFixturePropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only
	--
	
	{"fixture_hitboxes", "table", {}, nil, "hitboxes owned by this fixture"}

	{"fixture_parent_x", "link", PropConst(0), nil, "link to a hitbox's body x to be treated as origin"},
	{"fixture_parent_y", "link", PropConst(0), nil, "link to a hitbox's body y to be treated as origin"},
	{"fixture_parent_scale", "link", PropConst(0), nil, "link to a hitbox's body scale"},

}
