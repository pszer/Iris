--[[
utility class, table of flags
allows for global default values of flags if not set
--]]

FLAGS_D = {

	-- flags for how an entity should be handled
	ENT_UPDATE      = true  ,
	ENT_DRAW        = false ,
	ENT_CATCHSIGNAL = true  ,
	ENT_DELETE      = false
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
NILFLAGS = Flags:new()
