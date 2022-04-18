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
require "render"
require "bodyconf"

IRISGAME = {
	props = IrisGamePropPrototype()
}

IRISGAME.props.iris_enttables:AddTable(PlayerEntTable)

function IRISGAME:load()
	self:LoadRoom(require("rooms/testroom"))

	self.props.iris_world:CollectBody(testbody)
	self.props.iris_world:CollectBody(testbody2)
	self.props.iris_world:CollectBody(testbody3)
	self.props.iris_world:CollectBody(testbody4)
	self.props.iris_world:CollectBody(testbody5)
	self.props.iris_world:CollectBody(testbody6)
	self.props.iris_world:CollectBody(testbody7)
	self.props.iris_world:CollectBody(testbody8)
end

--[[ order for entity updates
-- 1. collect signals
-- 2. delete entities marked for deletion
-- 4. for each entity, let them handle signals then call their update function
-- 3. update world collisions
-- 5. delete old signals
--]]
function IRISGAME:UpdateEnts()
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
		if e.props.ent_catchsignalflag then
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
		if ent.props.ent_updateflag then
			ent:Update()
		end
	end

	local world = self.props.iris_world
	if world then

		CONTROL_LOCK.INGAME.Open()
		if QueryScancode("left", CONTROL_LOCK.INGAME) then
			testbody3.props.body_xvel = -4
		end
		if QueryScancode("right", CONTROL_LOCK.INGAME) then
			testbody3.props.body_xvel = 4
		end
		if QueryScancode("up", CONTROL_LOCK.INGAME) then
			if testbody3.props.body_onfloor then
				testbody3.props.body_yvel = -13
			end
		end
		if QueryScancode("down", CONTROL_LOCK.INGAME) then
			testbody3.props.body_yvel = testbody3.props.body_yvel + 100
		end

		if elevatorgoup then
			testbody2.props.body_yvel = -4
		else
			testbody2.props.body_yvel = 4
		end

		if testbody2.props.body_y < 200 and elevatorgoup then
			elevatorgoup = false
		elseif testbody2.props.body_y > 500 and not elevatorgoup then
			elevatorgoup = true
		end

		world:CollideBodies()
		world:CollideLogicBodies()
		world:UpdateBodies()
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

function IRISGAME:LoadRoom(room)
	local world, enttable = IrisRooms:LoadRoom(room, self.props.iris_enttables)

	if world then
		self.props.iris_enttables:RemoveTable(self.props.iris_roomenttableid)

		self.props.iris_roomenttableid = enttable.props.enttable_id
		self.props.iris_world = world

		IrisRenderer.props.render_renderworlddebug = true
		IrisRenderer.props.render_world = world
	end
end

FPS = 0
function IRISGAME:update(dt)
	FPS = 1/dt
	TICKACC = TICKACC + dt
	if TICKACC >= TICKTIME then
		TICKACC = TICKACC - TICKTIME

		-- game logic tied to 64 HZ
		--

		self:UpdateEnts()

		UpdateKeys()

		IncrementTick()

	end
end

function IRISGAME:draw()
	IrisRenderer:Draw()
	--love.graphics.print("FPS " .. tostring(fps), 0,0)
	--IrisRenderer:RenderWorldDebug(testworld)
end
