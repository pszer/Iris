--[[ utility function used in creating properties that are links
--   to properties in other tables
--
--   should only be used in linking properties of children objects
--   to properties of parent objects
--]]
--

function PropLink(parent_prop, key)
	return function()
		return parent_prop[key]
	end
end

-- use in situations where a property is expected to be linked
-- but only a constant value is required
function PropLinkConst(const)
	return function()
		return const
	end
end
