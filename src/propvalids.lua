--[[ utility functions for creating input validity functions for
--   property tables
--]]
--

require 'math'

-- limits property to be one of the entries in given table argument t
function PropIsOneOf(t)
	return function(x)
		-- if x is in t then its a valid unput
		for _,v in pairs(t) do
			if v == x then
				return true, x
			end
		end
		-- otherwise its a bad input
		return false, t[0]
	end
end

-- limits numbers to integers
function PropInteger()
	return function (x)
		return true, math.floor(x)
	end
end

-- limits numbers to >= m
function PropMin(m)
	return function (x)
		return true, math.max(m,x)
	end
end

-- limits numbers to a <= x <= b
function PropClamp(a,b)
	return function (x)
		return true, math.max(a , math.min(x,b))
	end
end

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
function PropConst(const)
	return function()
		return const
	end
end
