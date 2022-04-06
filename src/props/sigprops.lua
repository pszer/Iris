--[[ property table prototype for signals
--]]

require "prop"

SigPropPrototype = Props:prototype{

	{"sig_type",   "string", "signal_undef", nil, "signals type"},

	{"sig_sender", "number", -1, nil,    "entity signal is sent from, -1 if unspecified"},
	{"sig_dest",   "number", -1, nil,    "destination entity, -1 if unspecified"},

	{"sig_debug", "boolean", true, nil,  "if true signal will be printed to debug console"},
	{"sig_debugtext", "string", "", nil, "text to print to debug console"}

}
