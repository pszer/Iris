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
	{"body_classes", "table", nil, PropDefaultTable{}, [[a list of strings that determine the bodies classes i.e what they
	                                                     are in the game, bodies will only collide with bodies of classes specified
														 in body_classesenabled]]},
	{"body_classesenabled", "table", nil, PropDefaultTable{"world"}, [[a list of strings that determine the bodies classes i.e what they
	                                                          are in the game, bodies will only collide with bodies of classes specified
										    			      in body_classesenabled]]}
}
