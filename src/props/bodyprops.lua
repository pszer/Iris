--[[ property table prototype for bodies
--]]

require "prop"
require "set"

IrisBodyPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"body_x",    "number", 0, nil, "body x position"}, -- done
	{"body_y",    "number", 0, nil, "body y position"}, -- done
	{"body_xvel", "number", 0, nil, "body x velocity"}, -- done
	{"body_yvel", "number", 0, nil, "body x velocity"}, -- done

	{"body_name", "string", "irisbody", nil, "body name"}, -- done

	{"body_type", "string", "dynamic", PropIsOneOf{"static","dynamic","kinematic"},  "type can either be static or dynamic", "readonly"},

	-- following not implemented for now
	{"body_classes", "table", nil, PropDefaultTable{}, [[a list of strings that determine the body's classes i.e what they
	                                                     are in the game, bodies will only collide with bodies of classes specified
														 in body_classesenabled]]},
	{"body_classesenabled", "table", nil, PropDefaultTable{"world"}, [[a list of strings that determine the body's classes i.e what they
	                                                          are in the game, bodies will only collide with bodies of classes specified
										    			      in body_classesenabled]]},

	{"body_onfloor", "boolean", false, nil, "if true a body's hitboxes are a floor"},
	{"body_onceil", "boolean", false, nil, "if true a body's hitboxes are touching a ceiling"},
	{"body_onleftwall", "boolean", false, nil, "if true a body's hitboxes are touching a left wall"},
	{"body_onrightwall", "boolean", false, nil, "if true a body's hitboxes are touching a right wall"},

	-- for dynamic bodies
	{"body_friction", "number", 0, PropClamp(0,1), "a body's friction"},
	{"body_bounce",   "number", 1, nil, "a body's restitution/bounce"},

	{"body_mass", "number", 1, PropMin(0), "body mass used in dynamic collisions, +inf values are accepted"}

}
