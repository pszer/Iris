-- TODO: console, but nothing else. keep this file small
require "gamestate"

local profiler = require("profiler")

function love.load()
	SET_GAMESTATE(IRISGAME)

end

function love.update(dt)
	GAMESTATE:update(dt)
end

elevatorgoup = true
function love.draw()
	GAMESTATE:draw()

	--[[
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

	local bodies = testworld:CollectBodies()

	profiler.start()
	testworld:CollideBodies(bodies, true)
	profiler.stop()

	testworld:UpdateBodies(bodies)--]]
end

function love.quit()
	--profiler.report("profiler.log")
end
