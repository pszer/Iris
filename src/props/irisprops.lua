--[[ property table prototype for iris gamestate
--]]
--

require "prop"

IrisGamePropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"iris_paused", "boolean", false, nil,             "if true show game pause menu and pause game logic"}, -- done
	{"iris_tick", "function", GetTick, nil,                "ingame tick", "callonly"},
	{"iris_signals", "table", nil, PropDefaultTable{}, "signals sent this tick"},
	{"iris_enttables", "enttablecollection", EntTableCollection:new(), nil, "active collection of entity tables"},

	{"iris_roomenttableid", "number", -1, nil, "enttable id for current room entities"},
	{"iris_world", "irisworld", IrisWorld:new(), nil, "active world simulation" }

}
