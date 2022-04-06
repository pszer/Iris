-- signal called by entities marked for deletion
-- if prop.ent_sigdeletion is true

require "signal"

SIG_DELETED = { sig_type = "signal_deleted" }
SIG_DELETED.__index = SIG_DELETED

function SIG_DELETED:__new(ent)
	local this = {
		sig_type = self.sig_type,
		sig_debug = true,
		sig_debug_text = tostring(ent) .. " deleted",

		sig_sender = ent.props.ent_id
	}
	return this
end

IRIS_REGISTER_SIGNAL(SIG_DELETED)
