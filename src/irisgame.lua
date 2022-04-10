--[[
-- IRISGAME is responsible for storing all of the game state and has
-- the games main update and draw function
--]]

require "enttable"
require "input"
require "prop"
require "iristype"
require "world"
require "room"
require "props/irisprops"

IRISGAME = {
	props = IrisGamePropPrototype()
}

IRISGAME.props.iris_enttables:AddTable(PlayerEntTable)

--[[ order for entity updates
-- 1. collect signals
-- 2. delete entities marked for deletion
-- 3. for each entity, let them handle signals then call their update function
-- 4. delete old signals
--]]
function IRISGAME:update_ents()
	-- collect all signals from entities
	local collect_signals = function (e)
		for _,sig in pairs(e.__signals_pending) do
			table.insert(self.props.iris_signals, sig)
		end
		e:ClearSignals()
	end

	for _,entity in pairs(self.props.iris_enttables) do
		collect_signals(entity)
	end

	-- print signals for debugging
	for _,v in pairs(self.props.iris_signals) do
		if v.props.sig_debug then
			print(self.props.iris_tick .. " SIGNAL " .. tostring(v))
		end
	end

	-- delete any entities with props.ent_delete == true
	self.props.iris_enttables:DeleteMarked()

	-- each entity will handle current signals
	-- then call their update functions (if flags for these are enabled)
	--
	local update = function (e)
		if e.props.ent_catchsignal then
			for _,sig in pairs(self.props.iris_signals) do
				if not (sig.sig_onlyfordest and sig.sig_dest ~= e.ent_id) then
					e:HandleSignal(sig)
				end
			end
		end

		if e.props.ent_update then
			e:Update()
		end
	end

	for _,ent in pairs(self.props.iris_enttables) do
		if ent.props.ent_update then
			ent:Update()
		end
	end

	-- delete old signals
	self.props.iris_signals = { }
end

-- adds an entity table to the active entity table list
-- the reference for an entity table in the active table list
-- should not be the only one but stored elsewhere
function IRISGAME:ActivateEntTable(enttable)
	-- check if entity table is already active
	for _,e in pairs(self.props.iris_enttables) do
		if enttable.ID == e.ID then
			return
		end
	end

	table.insert(self.props.iris_enttables, enttable) 
end

-- disables and entity table by it's unique ID
function IRISGAME:DisableEntTable(ID)
	for k,e in pairs(self.props.iris_enttables) do
		if e.ID == ID then
			table.remove(self.props.iris_enttables, k)
		end
	end
end

fps = 0
function IRISGAME:update(dt)
	fps = 1/dt
	TICKACC = TICKACC + dt
	if TICKACC >= TICKTIME then
		TICKACC = TICKACC - TICKTIME

		-- game logic tied to 64 HZ
		--

		self:update_ents()
		testworld:UpdateBodies()

		UpdateKeys()

		IncrementTick()

	end
end

function IRISGAME:draw()
	love.graphics.print("FPS " .. tostring(fps), 0,0)
end
