--[[ The world of iris is stored in individual rooms
-- rooms have map geometry for things to walk on, decoration, an entity table,
-- warps to other rooms etc.
--]]
--

IrisRoom = {}
IrisRoom.__index = IrisRoom
IrisRoom.__type  = "irisroom"

function IrisRoom:new(props)
	local this = {
		props = IrisRoom
	}
end
