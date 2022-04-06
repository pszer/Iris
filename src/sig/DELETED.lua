-- signal called by entities marked for deletion
-- if ENT_SIGDELETION is true 

require "signal"

SIG_DELETED = {}
SIG_DELETED.__index = SIG_DELETED

function SIG_DELETED:new(ent)
	local this = Signal:new("SIG_DELETED", ent.ID, -1, nil,
	                  {
					   sig_debug      = true,
					   sig_debug_text = tostring(ent) .. " deleted"}
					  )
	return this
end
