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

EntTable = { ENT_TABLE_COUNTER=0 }
EntTable.__index = EntTable

function EntTable:new(entities, entname)
	local this = {
		ents = entities or {},
		name = entname or "ent_table" .. self.ENT_TABLE_COUNTER,
		ID = self.ENT_TABLE_COUNTER
	}
	self.ENT_TABLE_COUNTER = self.ENT_TABLE_COUNTER + 1
	setmetatable(this, EntTable)
	return this
end

-- gets an entity by it's unique id
-- returns entity and its key in this table
-- if not found it returns nil
function EntTable:Find(id)
	for k,v in self.ents do
		if v.ID == id then
			return v,k
		end
	end
	return nil, nil
end

-- adds entity to a table
-- should be used when adding newly constructed entity
-- to a table
-- should not be used for moving entities between tables
function EntTable:AddEntity(ent)
	table.insert(self.ents, ent)
end

-- move entity from this table to another
-- use to avoid duplicating references to an entity
-- returns true if moved, false if failed
function EntTable:MoveEntity(entid, dest)
	local ent, key = self:Find(entid)
	if ent then
		dest:AddEntity(ent)
		self.ents[key] = nil -- delete reference in this table
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
	local str = "Entity Table \"" .. enttable.name .. "\" ID:" .. enttable.ID .. " (" ..
	            #enttable.ents .. " entities)" 
	for k,ent in pairs(enttable.ents) do
		str = str .. "\n| " .. tostring(ent)
	end
	return str
end

--[[
-- EntTableCollection
-- A collection of entity tables, entity tables can be swapped in and out of the collection
-- Adds functionality for easily accessing entities
--]]
--

--[[
EntTableCollection = {}
EntTableCollection.__index = EntTableCollection
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
		if ent_table.ID == e.ID then
			return
		end
	end

	table.insert(self.__active_tables, enttable) 
end

-- disables and entity table by it's unique ID
function IRISGAME:DisableEntTable(ID)
	for k,e in pairs(self.__active_tables) do
		if e.ID == ID then
			table.remove(self.ENT_TABLES, k)
		end
	end
end
--]]

PlayerEntTable = EntTable:new()
PlayerEntTable:AddEntity(test_ent)
