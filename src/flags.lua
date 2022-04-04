--[[
-- utility class, table of flags
-- allows for global default values of flags if not set
-- only true/false values should be used as flags,, because they're FLAGS
--]]

FLAGS_D = {

	-- flags for how an entity should be handled
	ENT_UPDATE      = true  , -- static entities should have update disabled
                              --
	ENT_DRAW        = false , -- if false an entity will be ignored during
	                          -- rendering, should be disabled for invisible
							  -- entities or if off-screen
							  --
	ENT_CATCHSIGNAL = false , -- entities that dont need signals should have this
	                          -- disabled
							  --
	ENT_DELETE      = false , -- if true the entity will be deleted at the end
	                          -- of current game tick
							  --
	ENT_SIGDELETION = true  , -- if true an entity will send a signal that its
	                          -- been deleted when deleted, keep true to make
							  -- life easier
							  --

	-- flags for how a signal should be handled
	SIG_DEBUG       = true    -- if true a signal will be printed to debug console_
}

Flags = {}

function Flags:new(v)
	local this = v
	local meta = { __index = FLAGS_D }
	setmetatable(this, meta)
	return this
end

-- empty table of flags to be used when passing no flags
-- to functions that expect them
NILFLAGS = Flags:new({})
