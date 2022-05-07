-- signal called by entities to hurt others

require "signal"

SIG_HURT = { sig_type = "signal_hurt" }
SIG_HURT.__index = SIG_HURT

function SIG_HURT:__new(ent)
	local this = {
		sig_type = self.sig_type,
		sig_debug = true,
		sig_debug_text = tostring(ent) .. " deleted",

		sig_sender = ent.props.ent_id
	}
	return this
end

IRIS_REGISTER_SIGNAL(SIG_DELETED)
