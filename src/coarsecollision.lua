--[[ coarse (broad-phase) collision is implemented as sweep and prune
--]]
--

SortedAABB = SortedAABB
SortedAABB.__index = SortedAABB

function SortedAABB:new()
	local t = {
		
	}
	setmetatable(this, SortedAABB)
	return t
end
