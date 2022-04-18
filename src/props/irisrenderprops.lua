--[[ property table prototype for iris game renderer
--]]

require "prop"
require "set"

IrisRenderPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"render_showfps", "boolean", true, nil, "if true, fps is rendered to screen"},
	{"render_renderworlddebug", "boolean", true, nil, "if true, fps is rendered to screen"},
	{"render_world", nil, nil, nil, "world rendered by render_renderworlddebug"}

}
