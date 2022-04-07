--[[
-- entities are stored in entity tables
-- entity tables can be added to and from the global ENT_TABLES to
-- become active/inactive
-- each room has its own entity table thats swapped in/out whenever when
-- the player enters and leaves, the player has his own entity table for
-- itself and entities tied to it.
-- makes managing entities easier
--
-- each ent table has a unique number id
--
-- entities in an entity table are stored sorted by their numeric id
--]]

require "ent"
require "sortedtable"
require "props/enttableprops"
require "pairs"

EntTable = {
	__id_less_than = function (ent1, ent2)
		return ent1.props.ent_id < ent2.props.ent_id
	end ,

	__id_equality = function (ent1, ent2)
		return ent1.props.ent_id == ent2.props.ent_id
	end
}
EntTable.__index = EntTable
EntTable.__type  = "enttable"

function EntTable:new(props)
	local this = {
		props = EntTablePropPrototype(props),
		ents = SortedTable:new(EntTable.__id_less_than, EntTable.__id_equality)
	}

	setmetatable(this, EntTable)
	return this
end

-- gets an entity by it's unique id
-- returns entity and its key in self.ents
-- if not found it returns nil, nil
function EntTable:Find(id)
	return this.ents.Search(id)
end

-- adds entity to a table
-- should be used when adding newly constructed entity
-- to a table
-- should not be used for moving entities between tables
function EntTable:AddEntity(ent)
	self.ents:Add(ent)
end

-- move entity from this table to another
-- use to avoid duplicating references to an entity
-- returns true if moved, false if failed
function EntTable:MoveEntity(entid, dest)
	local ent, index = self:Search(entid)
	if ent then
		dest:AddEntity(ent)
		self.ents:Remove(index)
		return true
	end
	return false
end

-- deleted entities marked for deletion
function EntTable:DeleteMarked()
	for k,v in pairs(self.ents) do
		if v:GetProp("ent_delete") then
			self.ents[k] = nil
		end
	end
end

-- applies a function to all entities in
-- entity table, function takes 1 argument
-- for the entity
function EntTable:Apply(lambda)
	for _,v in pairs(self.ents) do
		lambda(v)
	end
end

function EntTable.__tostring(enttable)
	local str = "Entity Table \"" .. enttable.props.enttable_name .. "\" id:" .. enttable.props.enttable_id .. " (" ..
	            #(enttable.ents) .. " entities)" 
	for k,ent in pairs(enttable.ents.__entries) do
		str = str .. "\n| " .. tostring(ent)
	end
	return str
end

--[[
-- EntTableCollection
-- A collection of entity tables, entity tables can be swapped in and out of the collection
-- Adds functionality for easily accessing entities, namely pairs(enttablecollection) for iterating
-- over all entities in an entity table collection
--]]
--

EntTableCollection = {}
EntTableCollection.__index = EntTableCollection
EntTableCollection.__type  = "enttablecollection"
-- BIG OL FUNCTION, maybe clean it up

EntTableCollection.__next = function(t, index)
	::recur::
	if index == nil or index[2] == nil then
		--[[
		if index ~= nil and index[2] == nil then
			print("yo dat index[2] is nil doe")
			print("index and index[1] is ", index and index[2])
		end--]]

		--print("point 1")
		local n1 = pairs(t.__active_tables)
		local i,ent_table = n1(t.__active_tables, index and index[1])

		if not i then
			--print("point 2")
			return nil, nil
		else
			local n2 = pairs(ent_table.ents.__entries)
			local ent_i, ent = n2(ent_table.ents.__entries)

			if not ent_i then
				--print("point 3")
				index = {i, nil}
				goto recur
			else
				--print("point 4")
				return {i, ent_i}, ent
			end
		end
	end

	local ent_table_index = index[1]
	local ent_table = t.__active_tables[ent_table_index]
	local ent_index = index[2]
	local ent_table_next = pairs(ent_table.ents.__entries)
	local next_ent_i, next_ent = ent_table_next(ent_table.ents.__entries, ent_index)

	if not next_ent_i then
		index = {ent_table_index, nil}
		goto recur
	else
		return {ent_table_index, next_ent_i}, next_ent
	end
end

EntTableCollection.__pairs = function (t)
	return EntTableCollection.__next, t, nil
end

function EntTableCollection:new()
	local table = {
		__active_tables = {}
	}
	setmetatable(table, EntTableCollection)
	return table
end

function EntTableCollection:AddTable(ent_table)
	-- check if entity table is already active
	for _,e in pairs(self.__active_tables) do
		if ent_table.props.enttable_id == e.props.enttable_id then
			return
		end
	end

	table.insert(self.__active_tables, ent_table) 
end

-- disables and entity table by it's unique id
function EntTableCollection:RemoveTable(id)
	for k,e in pairs(self.__active_tables) do
		if e.id == id then
			table.remove(self.__active_tables, k)
		end
	end
end

function EntTableCollection:DeleteMarked()
	for _,etable in pairs(self.__active_tables) do
		etable:DeleteMarked()
	end
end

PlayerEntTable = EntTable:new()
PlayerEntTable:AddEntity(test_ent)
