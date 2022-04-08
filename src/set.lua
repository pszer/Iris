--[[
-- utility function for a set
--]]

Set = {}
Set.__index = Set
Set.__type  = "set"

function Set:new()
	local s = {}
	setmetatable(s,Set)
	return s
end

function Set:Add(x)
	for _,v in self do
		if v == x then return end
	end
	table.insert(self, x)
end

function Set:RemoveByIndex(i)
	table.remove(self. i)
end

function Set:Remove(x)
	local i = self:Search(x)
	if i then
		table.remove(self. i)
	end
end

function Set:Search(x)
	for i,v in self do
		if v == x then
			return i
		end
	end
	return nil
end
