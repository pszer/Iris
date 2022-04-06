--[[ property table prototype for signals
--]]

require "prop"

SigPropPrototype = Props:prototype{

	{"sig_debug", "boolean", true, nil,   "if true signal will be printed to debug console"},
	{"sig_debugtext", "string", "", nil, "text to print to debug console"}

}
