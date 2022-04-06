--[[
-- Provides functionality for a sorted table
-- Entries are inserted, removed and searched for
-- using a fast binary search
--
-- Use
-- s = SortedTable:new(lessthan, equality) - creates a new sorted table with a less than operator for order
--                                         - and an equality operator used to specify what to search for
--                                         - in Search
-- s:Add(x)    - adds x to the sorted table
-- s:Remove(i) - removes entry at index i
-- i,entry = s:Search(x) - finds entry x in table and returns it's index as well as the entry
--                         if entry doesn't exist it returns nil,nil
--
--]]

require 'table'
require 'math'

SortedTable = {}
SortedTable.__index = SortedTable

-- Creates a sorted table, a less than operator
-- is required to specify order and an equality operator
-- used for searching
function SortedTable:new(lessthan, equality)
	local t = {
		__entries = {},
		__lessthan = lessthan,
		__equality = equality,
		__length = 0
	}
	setmetatable(t, SortedTable)
	return t
end

function SortedTable:Add(x)
	local l, r, m = 1, self.__length+1, 1

	while l < r do
		m = math.floor((l+r)/2)
		local at_m = self.__entries[m]
		if self.__lessthan(at_m, x) then
			l = m+1
		else
			r = m
		end
	end

	table.insert(self.__entries, l, x)
	self.__length = self.__length + 1
end

function SortedTable:Remove(index)
	table.remove(self.__entries, index)
	self.__length = self.__length - 1
end

function SortedTable:Search(x)
	local l, r, m = 1, self.__length, 1

	while l <= r do
		m = math.floor((l+r)/2)
		local at_m = self.__entries[m]

		--print("l,r,m = " .. l .. " " .. r .. " " .. m)

		if self.__equality(at_m, x) then
			return m, at_m
		elseif self.__lessthan(at_m, x) then
			l = m+1
		else
			r = m-1
		end
	end

	local at_l = self.__entries[l]
	if self.__equality(l, x) then
		return at_l, l
	else
		return nil, nil
	end
end
