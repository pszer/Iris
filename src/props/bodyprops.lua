--[[ property table prototype for bodies
--]]

require "prop"

IrisHitboxPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"body_x",    "number", 0, nil, "body x position"}, -- done
	{"body_y",    "number", 0, nil, "body y position"}, -- done
	{"body_xvel", "number", 0, nil, "body x velocity"}, -- done
	{"body_yvel", "number", 0, nil, "body x velocity"}, -- done

	{"body_name", "string", "", nil, "hitbox name"}, -- done

	{"body_scale" , "number", 1, nil,      "multiplier for the scale of a body (namely it scales children hitboxes)"}, -- done

	{"body_type", "string", "static", PropIsOneOf{"static","dynamic","kinematic"},  "type can either be static, dynamic, or kinematic"}

	{"body_fixtures", "table", {}, nil,       "collection of all fixtures owned by this body"}
	{"body_activefixtures", "table", {}, nil, "names for all the active fixtures in this body"}

}
