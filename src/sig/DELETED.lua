-- signal called by entities marked for deletion
-- if prop.ent_sigdeletion is true

require "signal"

SIG_DELETED = {
	props = {
		sig_type = "signal_deleted",
		sig_debug = true,
		sig_debug_text = "entity deleted",
	},

	payload = {
		
	}
}

IRIS_REGISTER_SIGNAL(SIG_DELETED)
