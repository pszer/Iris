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
--]]

require "ent"

EntTable = { ENT_TABLE_COUNTER=0 }
EntTable.__index = EntTable

function EntTable:new(entities)
	local this = {
		ents = entities or {},
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
		if v:GetFlag("ENT_DELETE") then
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

PlayerEntTable = EntTable:new()
PlayerEntTable:AddEntity(test_ent)
