--[[ property table prototype for rooms
--]]

require "prop"
require "body"

IrisRoomPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"room_name", "string", "room", nil,  "rooms name"},

	{"room_body", "irisbody", IrisBody:new(), "rooms body holding all of its fixtures and hitboxes"}
}
