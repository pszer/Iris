-- signal called by entities marked for deletion
-- if ENT_SIGDELETION is true 

require "signal"

SIG_DELETED = {}

function SIG_DELETED:new(ent)
	return Signal:new("SIG_DELETED", ent.ID, -1,
	                  {DEBUG_TEXT=(ent:DebugText()+" deleted")},
					  Flags:new({SIG_DEBUG = TRUE}))
end
