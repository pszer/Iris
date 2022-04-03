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
		ents = entities or {}
		ID = ENT_TABLE_COUNTER
	}
	setmetatable(this, EntTable)
	return this
end

-- applies a function to all entities in
-- entity table
-- the function should take 1 argument which will be the entity
function EntTable:Apply(lambda)
	for _,v in self.ents do
		lambda(v)
	end
end
