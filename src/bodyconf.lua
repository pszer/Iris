-- a more convenient way of creating bodies that calling body, fixture and hitbox creation functions
-- and joining them together
--
-- example
-- 
-- { 
--    "body name string",
--    -- body properties
--    body_type = "dynamic,
-- 
--    10,20, -- x y position
--
--    {
--       "fixture name string",
--       -- fixture activated?
--       true
--       -- fixture properties
--       fixture_solid = true,
-- 
--       {
--         "hitbox 1 name string"
--         -- hitbox properties
--         hitbox_callback = callback_function,
--         0,0,25,25 -- x y w h rectangle
--       }
--
--       {
--         "hitbox 2 name string"
--         -- hitbox properties
--         hitbox_callback = callback_function,
--         10,10,25,25 -- x y w h rectangle
--       }
--    }
-- }

require "body"
require "fixture"
require "hitbox"

function BodyConf(conf, propsoverride)
	local body = IrisBody:new()
	local bodyprops = body.props

	local hitbox_helper = function(conf)
		local hitbox = IrisHitbox:new()
		local hitboxprops = hitbox.props

		local count = 1
		local countlookup = {"hitbox_x","hitbox_y","hitbox_w","hitbox_h"}
		for i,v in pairs(conf) do
			if type(i) == "string" then
				hitboxprops[i] = v
			elseif type(v) == "string" then
				hitboxprops.hitbox_name = v
			elseif type(v) == "number" then
				if count ~= 5 then
					hitboxprops[countlookup[count]] = v
					count = count + 1
				end
			end
		end
		return hitbox
	end

	local fixture_helper = function(conf)
		local fixture = IrisFixture:new()
		local fixtureprops = fixture.props
		local activated = true
		for i,v in pairs(conf) do
			if type(i) == "string" then
				fixtureprops[i] = v
			elseif type(v) == "string" then
				fixtureprops.fixture_name = v
			elseif type(v) == "boolean" then
				activated = v
			elseif type(v) == "table" then
				local hitbox = hitbox_helper(v)
				if hitbox then
					fixture:AddHitbox(hitbox)
				end
			end
		end
		return fixture, activated
	end

	local count = 1
	local countlookup = {"body_x","body_y"}
	for i,v in pairs(conf) do
		if type(i) == "string" then
			bodyprops[i] = v
		elseif type(v) == "string" then
			bodyprops.body_name = v
		elseif type(v) == "number" then
			if count ~= 3 then
				bodyprops[countlookup[count]] = v
				count = count + 1
			end
		elseif type(v) == "table" then
			local fixture, activate = fixture_helper(v)
			if fixture then
				body:AddFixture(fixture, activate)
			end
		end
	end

	if propsoverride then
		bodyprops(propsoverride)
	end
	return body
end
