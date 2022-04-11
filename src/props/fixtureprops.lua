--[[ property table prototype for fixtures
--]]
--

require "prop"

IrisFixturePropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only
	--
	
	{"fixture_hitboxes", "table", nil, PropDefaultTable{}, "hitboxes owned by this fixture"},

	{"fixture_name", "string", "fixture", nil, "fixtures name, a fixtures name should be unique in a body"},

	{"fixture_parent_x", "link", PropConst(0), nil, "link to a fixtures's body x to be treated as origin"},
	{"fixture_parent_y", "link", PropConst(0), nil, "link to a fixtures's body y to be treated as origin"},

	{"fixture_solid", "boolean", true, nil, "if true a fixtures hitboxes are treated as solid"},

	{"fixture_onfloor", "boolean", false, nil, "if true a fixtures hitboxes are a floor"},
	{"fixture_onceil", "boolean", false, nil, "if true a fixtures hitboxes are touching a ceiling"},
	{"fixture_onleftwall", "boolean", false, nil, "if true a fixtures hitboxes are touching a left wall"},
	{"fixture_onrightwall", "boolean", false, nil, "if true a fixtures hitboxes are touching a right wall"}
}
