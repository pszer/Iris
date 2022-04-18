--[[
-- bodies are objects with a position and velocity
-- there are three types of bodies, dynamic bodies that
-- collide with all types of bodies, static bodies that do not
-- move and kinematic bodies that only collide with dynamic bodies
--
-- a bodies shape is described by a collection of hitboxes
-- hitboxes serve two main purposes, they can be solid and collide with other hitboxes
-- for physics or they can be non-solid logic hitboxes that describe the area
-- an attack hits, areas a player can interact with objects, environment
-- damage areas etc.
-- these collections of hitboxes are called fixtures (src/fixture.lua)
--
-- bodies are used in the game mainly for two purposes, the geometry and trigger areas of a map
-- is a static body and entities have dynamic/kinematic bodies for physics with the world and
-- interaction with other entities
--
--]]
--

require "props/bodyprops"
require "hitbox"
require "fixture"
require "coarsecollision"
require "physicsutils"
require "set"

IrisBody = {}
IrisBody.__index = IrisBody
IrisBody.__type = "irisbody"
function IrisBody:new(props)
	local t = {
		props = IrisBodyPropPrototype(props),

		__activehitboxesmemo_solid = {},
		__activehitboxesmemo_solid_changed = true,
		__activehitboxesmemo_nonsolid = {},
		__activehitboxesmemo_nonsolid_changed = true,
		-- add AABB memo here
		__activeAABBmemo_solid = {nil,nil,nil,nil},
		__activeAABBmemo_solid_changed = true,
		__activeAABBmemo_nonsolid = {nil,nil,nil,nil},
		__activeAABBmemo_nonsolid_changed = true,

		__xoffset = 0,
		__yoffset = 0,

		__fixtures = {},
		__activefixtures = Set:new()
	}
	setmetatable(t, IrisBody)
	return t
end

--[[ computes the smallest bounding box enclosing the
--   active hitboxes in a body. the argument is for whether
--   you want the bounding box for solid fixtures or non-solid fixtures
--
--   returns x,y,w,h
--   if no active hitboxes are in this body or no active hitboxes match the filter
--   then it returns nil
--]]
function IrisBody:ComputeBoundingBox(solid)
	solid = solid or true

	local aabbmemo, aabbmemochanged
	if solid then
		aabbmemo = self.__activeAABBmemo_solid
		aabbmemochanged = self.__activeAABBmemo_solid_changed
	else
		aabbmemo = self.__activeAABBmemo_nonsolid
		aabbmemochanged = self.__activeAABBmemo_nonsolid_changed
	end

	if not aabbmemochanged then
		return self.props.body_x + aabbmemo[1],
		       self.props.body_y + aabbmemo[2],
		       aabbmemo[3], aabbmemo[4]
	end

	local fixtures = self:ActiveFixtures()

	local boxes = {}
	local empty = true
	for _,fixture in ipairs(fixtures) do
		if fixture.props.fixture_solid == solid then
			local box = {fixture:ComputeBoundingBox()}
			if box[1] then
				empty = false
				boxes[#boxes+1] = box
			end
		end
	end

	local x,y,w,h = nil,nil,nil,nil
	if boxes then
		x,y,w,h = ComputeBoundingBox(boxes)

		for i,v in ipairs(boxes) do
			print("box, ", unpack(v))
		end

		if not x then
			return nil, nil, nil, nil
		end

		local tx = x - self.props.body_x
		local ty = y - self.props.body_y

		aabbmemo[1],aabbmemo[2],aabbmemo[3],aabbmemo[4] = tx,ty,w,h
	end

	if solid then
		self.__activeAABBmemo_solid_changed = false
	else
		self.__activeAABBmemo_nonsolid_changed = false
	end
	
	return x,y,w,h
end

function IrisBody:ComputeBoundingBoxLastFrame(solid)
	local x,y,w,h = self:ComputeBoundingBox(solid)
	if x then
		local selfprops = self.props
		return x-selfprops.body_xvel, y-selfprops.body_yvel, w,h
	end
end

-- returns a table of all the active fixtures in this
-- body
function IrisBody:ActiveFixtures()
	return self.__activefixtures
end

function IrisBody:ActiveHitboxes(solid)
	local boxmemo, boxmemochanged
	if solid then
		boxmemo = self.__activehitboxesmemo_solid
		boxmemochanged = self.__activehitboxesmemo_solid_changed
	else
		boxmemo = self.__activehitboxesmemo_nonsolid
		boxmemochanged = self.__activehitboxesmemo_nonsolid_changed
	end

	if not boxmemochanged then
		return boxmemo
	end

	local f = self:ActiveFixtures()
	local a = boxmemo

	for i=1,#a do
		a[i]=nil
	end
	for _,fixture in ipairs(f) do
		if fixture.props.fixture_solid == solid then
			for i,h in pairs(fixture.props.fixture_hitboxes) do
				if h.props.hitbox_enable then
				a[#a+1] = h
				end
			end
		end
	end

	if solid then
		self.__activehitboxesmemo_solid_changed = false
	else
		self.__activehitboxesmemo_nonsolid_changed = false
	end
	return a
end

-- adds a fixture to the body
-- if activate is true then it is automatically activated
function IrisBody:AddFixture(fixture, activate)
	local selfprops = self.props
	fixture.props.fixture_parent_x = PropLink(selfprops, "body_x")
	fixture.props.fixture_parent_y = PropLink(selfprops, "body_y")
	fixture.props.fixture_parent = self
	--fixture:SetFixtureHitboxesParent(self)

	local f = self.__fixtures
	f[#f+1] = fixture
	if activate then
		self:ActivateFixture(fixture)
	end
end

function IrisBody:ActivateFixture(fixture)
	self.__activefixtures:Add(fixture)
	self.__activehitboxeschanged = true

	if fixture.props.fixture_solid then
		self.__activeAABBmemo_solid_changed = true
	else
		self.__activeAABBmemo_nonsolid_changed = true
	end
end

function IrisBody:DisableFixture(fixture)
	self.__activefixtures:Remove(fixture)
	self.__activehitboxeschanged = true

	if fixture.props.fixture_solid then
		self.__activeAABBmemo_solid_changed = true
		self.__activehitboxesmemo_solid_changed = true
	else
		self.__activeAABBmemo_nonsolid_changed = true
		self.__activehitboxesmemo_nonsolid_changed = true
	end
end

function IrisBody.__tostring(b)
	local s = "IrisBody " .. b.props.body_name .. "\n"
	for _,fixture in pairs(b.__fixtures) do
		s = s .. tostring(fixture)
	end
	return s
end

__BODY_TYPE_COLLISION_COMPARE__ = {
 static={}, dynamic={}, kinematic={}}
__BODY_TYPE_COLLISION_COMPARE__["static"]["static"]    = false
__BODY_TYPE_COLLISION_COMPARE__["static"]["dynamic"]   = true
__BODY_TYPE_COLLISION_COMPARE__["dynamic"]["static"]   = true
__BODY_TYPE_COLLISION_COMPARE__["dynamic"]["dynamic"]  = true
__BODY_TYPE_COLLISION_COMPARE__["kinematic"]["static"]  = false
__BODY_TYPE_COLLISION_COMPARE__["static"]["kinematic"]  = false
__BODY_TYPE_COLLISION_COMPARE__["kinematic"]["dynamic"]  = true
__BODY_TYPE_COLLISION_COMPARE__["dynamic"]["kinematic"]  = true
__BODY_TYPE_COLLISION_COMPARE__["kinematic"]["kinematic"]  = true
-- collisions between bodies should be stored in the following order
-- dynamic collides with static
-- dynamic collides with dynamic
-- kinematic collides with dynamic
-- kinematic collides with kinematic
__BODY_TYPE_COLLISION_SWAP_ORDER__ = {
 static={}, dynamic={}, kinematic={}}
__BODY_TYPE_COLLISION_SWAP_ORDER__["static"]["static"]    = false
__BODY_TYPE_COLLISION_SWAP_ORDER__["static"]["dynamic"]   = true
__BODY_TYPE_COLLISION_SWAP_ORDER__["dynamic"]["static"]   = false
__BODY_TYPE_COLLISION_SWAP_ORDER__["dynamic"]["dynamic"]  = false
__BODY_TYPE_COLLISION_SWAP_ORDER__["kinematic"]["static"]  = true
__BODY_TYPE_COLLISION_SWAP_ORDER__["static"]["kinematic"]  = false
__BODY_TYPE_COLLISION_SWAP_ORDER__["kinematic"]["dynamic"]  = false
__BODY_TYPE_COLLISION_SWAP_ORDER__["dynamic"]["kinematic"]  = false
__BODY_TYPE_COLLISION_SWAP_ORDER__["kinematic"]["kinematic"]  = false
-- returns true/false and the bodies in collide type order
-- eg staticbody:CanCollideWith(dynamicbody) = true, dynamicbody, staticbody
function IrisBody:CanCollideWith(body)
	local selftype = self.props.body_type
	local bodytype = body.props.body_type
	if not __BODY_TYPE_COLLISION_COMPARE__[selftype][bodytype] then
		return false
	end

	local sprops = self.props
	local bprops = body.props
	local sclasses = sprops.body_classes
	local sclassesenabled = sprops.body_classesenabled
	local bclasses = bprops.body_classes
	local bclassesenabled = sprops.body_classesenabled

	local classmatch = false
	for _,c1 in ipairs(sclassesenabled) do
		if classmatch then break end
		for _,c2 in ipairs(bclasses) do
			if c1 == c2 then classmatch = true break
			end
		end
	end

	for _,c1 in ipairs(bclassesenabled) do
		if classmatch then break end
		for _,c2 in ipairs(sclasses) do
			if c1 == c2 then classmatch = true break
			end
		end
	end

	if not classmatch then return false end

	if __BODY_TYPE_COLLISION_SWAP_ORDER__[selftype][bodytype] then
		return true, body, self
	else
		return true, self, body
	end
end
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

HandleBodyCollision_static_static_nonsolid       = nil
HandleBodyCollision_static_dynamic_nonsolid      = nil
HandleBodyCollision_dynamic_static_nonsolid      = function (bodya, bodyb)
	local bodyaprops = bodya.props
	local bodyahitboxes = bodya:ActiveHitboxes(true)
	local bodybhitboxes = bodyb:ActiveHitboxes(true)

	local collided = false

	-- this is quadratic time, do something better
	for _, hitboxa in ipairs(bodyahitboxes) do
		local x1,y1,w1,h1 = hitboxa:Position()
		for _, hitboxb in ipairs(bodybhitboxes) do
			local bodybprops = bodyb.props
			local x2,y2,w2,h2 = hitboxb:Position()
			local xvel = bodyaprops.body_xvel
			local yvel = bodyaprops.body_yvel

			local collision, newxvel, newyvel, onfloor, onleftwall, onrightwall, onceil
		
			local haprops = hitboxb.props
			local hbprops = hitboxb.props
			if hbprops.hitbox_shape == "rect" then
				collision
					= DynamicRectStaticRectCollision(x1,y1,w1,h1, xvel, yvel, x2,y2,w2,h2)
			else
				collision
					= DynamicRectStaticTriangleCollision(x1,y1,w1,h1, xvel, yvel, x2,y2,w2,h2,
						hbprops.hitbox_triangleorientation) 
			end
			if collision then
				local enititya = bodyaprops.body_parententity
				local enitityb = bodybprops.body_parententity

				local hitboxacallback = haprops.hitbox_callback 
				local hitboxbcallback = hbprops.hitbox_callback

				if hitboxacallback then
					hitboxacallback(hitboxa, hitboxb, bodya, bodyb, entitya, entityb)
				end
				if hitboxbcallback then
					hitboxbcallback(hitboxb, hitboxa, bodyb, bodya, entityb, entitya)
				end
			end
		end
	end

	return collided
end
HandleBodyCollision_dynamic_dynamic_nonsolid     = function (bodya, bodyb)
	local bodyaprops = bodya.props
	local bodyahitboxes = bodya:ActiveHitboxes(true)
	local bodybhitboxes = bodyb:ActiveHitboxes(true)

	local collided = false

	-- this is quadratic time, do something better
	for _, hitboxa in ipairs(bodyahitboxes) do
		local bodyaprops = bodya.props
		local bodya = bodya

		local amass = bodyaprops.body_mass
		for _, hitboxb in ipairs(bodybhitboxes) do
			local bodybprops = bodyb.props
			local bodyb = bodyb

			local b1, b2 = bodyaprops, bodybprops
			local hitbox1, hitbox2 = hitboxa, hitboxb

			local x1,y1,w1,h1 = hitboxa:Position()
			local x2,y2,w2,h2 = hitboxb:Position()

			local xvel1 = b1.body_xvel
			local yvel1 = b1.body_yvel
			local xvel2 = b2.body_xvel
			local yvel2 = b2.body_yvel

			local collision
				= DynamicRectDynamicRectCollision(x1,y1,w1,h1, xvel1, yvel1,
				                                  x2,y2,w2,h2, xvel2, yvel2)
			if collision then
				local enitity1 = b1.body_parententity
				local enitity2 = b2.body_parententity

				local hitbox1callback = hitbox1.props.hitbox_callback 
				local hitbox2callback = hitbox2.props.hitbox_callback

				if hitbox1callback then
					hitbox1callback(h1, h2, b1, b2, entity1, entity2)
				end
				if hitbox2callback then
					hitbox2callback(h2, h1, b2, b1, entity2, entity1)
				end
			end
		end
	end

	return collided
end
HandleBodyCollision_kinematic_static_nonsolid    = nil
HandleBodyCollision_static_kinematic_nonsolid    = nil
HandleBodyCollision_kinematic_kinematic_nonsolid = nil
HandleBodyCollision_dynamic_kinematic_nonsolid   = nil
HandleBodyCollision_kinematic_dynamic_nonsolid   = nil

-- collision handlers for handling body non solid collisions of specific types
__BODY_TYPE_NONSOLID_COLLISION_HANDLER__ = {
 static={}, dynamic={}, kinematic={}}
__BODY_TYPE_NONSOLID_COLLISION_HANDLER__["static"]["static"]       = HandleBodyCollision_static_static_nonsolid       
__BODY_TYPE_NONSOLID_COLLISION_HANDLER__["static"]["dynamic"]      = HandleBodyCollision_static_dynamic_nonsolid      
__BODY_TYPE_NONSOLID_COLLISION_HANDLER__["dynamic"]["static"]      = HandleBodyCollision_dynamic_static_nonsolid      
__BODY_TYPE_NONSOLID_COLLISION_HANDLER__["dynamic"]["dynamic"]     = HandleBodyCollision_dynamic_dynamic_nonsolid     
__BODY_TYPE_NONSOLID_COLLISION_HANDLER__["kinematic"]["static"]    = HandleBodyCollision_kinematic_static_nonsolid    
__BODY_TYPE_NONSOLID_COLLISION_HANDLER__["static"]["kinematic"]    = HandleBodyCollision_static_kinematic_nonsolid    
__BODY_TYPE_NONSOLID_COLLISION_HANDLER__["kinematic"]["dynamic"]   = HandleBodyCollision_kinematic_dynamic_nonsolid   
__BODY_TYPE_NONSOLID_COLLISION_HANDLER__["dynamic"]["kinematic"]   = HandleBodyCollision_dynamic_kinematic_nonsolid   
__BODY_TYPE_NONSOLID_COLLISION_HANDLER__["kinematic"]["kinematic"] = HandleBodyCollision_kinematic_kinematic_nonsolid

--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

HandleBodyCollision_static_static       = nil
HandleBodyCollision_static_dynamic      = nil
HandleBodyCollision_dynamic_static      = function (bodya, bodyb)
	local bodyaprops = bodya.props
	local bodyahitboxes = bodya:ActiveHitboxes(true)
	local bodybhitboxes = bodyb:ActiveHitboxes(true)

	local collided = false

	-- this is quadratic time, do something better
	for _, hitboxa in ipairs(bodyahitboxes) do
		local x1,y1,w1,h1 = hitboxa:Position()
		for _, hitboxb in ipairs(bodybhitboxes) do
			local bodybprops = bodyb.props
			local x2,y2,w2,h2 = hitboxb:Position()
			local xvel = bodyaprops.body_xvel
			local yvel = bodyaprops.body_yvel

			local collision, newxvel, newyvel, onfloor, onleftwall, onrightwall, onceil
		
			local haprops = hitboxb.props
			local hbprops = hitboxb.props
			if hbprops.hitbox_shape == "rect" then
				collision, newxvel, newyvel, onfloor, onleftwall, onrightwall, onceil
					= DynamicRectStaticRectCollisionFull(x1,y1,w1,h1, xvel, yvel, x2,y2,w2,h2,
						bodyaprops.body_friction, bodybprops.body_friction)
			else
				collision, newxvel, newyvel, onfloor, onleftwall, onrightwall, onceil
					= DynamicRectStaticTriangleCollisionFull(x1,y1,w1,h1, xvel, yvel, x2,y2,w2,h2,
						hbprops.hitbox_triangleorientation, bodyaprops.body_friction, bodybprops.body_friction, hitboxb.__hyp_normalx, hitboxb.__hyp_normaly)
			end
			if collision then
				if bodyaprops.body_collide and bodybprops.body_collide then

					bodyaprops.body_xvel = newxvel
					bodyaprops.body_yvel = newyvel

					bodyaprops.body_onfloor = bodyaprops.body_onfloor or onfloor
					bodyaprops.body_onleftwall = bodyaprops.body_onleftwall or onleftwall
					bodyaprops.body_onrightwall = bodyaprops.body_onrightwall or onrightwall
					bodyaprops.body_onceil = bodyaprops.body_onceil or onceil

					bodybprops.body_onfloor = bodybprops.body_onfloor or onceil
					bodybprops.body_onleftwall = bodybprops.body_onleftwall or onrightwall
					bodybprops.body_onrightwall = bodybprops.body_onrightwall or onleftwall
					bodybprops.body_onceil = bodybprops.body_onceil or onfloor

					collided = true

				end

				local enititya = bodyaprops.body_parententity
				local enitityb = bodybprops.body_parententity

				local hitboxacallback = haprops.hitbox_callback 
				local hitboxbcallback = hbprops.hitbox_callback

				if hitboxacallback then
					hitboxacallback(hitboxa, hitboxb, bodya, bodyb, entitya, entityb)
				end
				if hitboxbcallback then
					hitboxbcallback(hitboxb, hitboxa, bodyb, bodya, entityb, entitya)
				end
			end
		end
	end

	return collided
end
HandleBodyCollision_dynamic_dynamic     = function (bodya, bodyb)
	local bodyaprops = bodya.props
	local bodyahitboxes = bodya:ActiveHitboxes(true)
	local bodybhitboxes = bodyb:ActiveHitboxes(true)

	local collided = false

	-- this is quadratic time, do something better
	for _, hitboxa in ipairs(bodyahitboxes) do
		local bodyaprops = bodya.props
		local bodya = bodya

		local amass = bodyaprops.body_mass
		for _, hitboxb in ipairs(bodybhitboxes) do
			local bodybprops = bodyb.props
			local bodyb = bodyb

			local b1, b2 = bodyaprops, bodybprops
			local hitbox1, hitbox2 = hitboxa, hitboxb

			local bmass = b2.body_mass
			local x1,y1,w1,h1 = hitboxa:Position()
			local x2,y2,w2,h2 = hitboxb:Position()

			local xvel1 = b1.body_xvel
			local yvel1 = b1.body_yvel
			local xvel2 = b2.body_xvel
			local yvel2 = b2.body_yvel


			local mass1,bounce1,friction1 = b1.body_mass,b1.body_bounce,b1.body_friction
			local mass2,bounce2,friction2 = b2.body_mass,b2.body_bounce,b2.body_friction

			if mass1 < mass2 then
				b1,b2 = bodyaprops, bodybprops
			else
				b1,b2 = bodybprops, bodyaprops
				hitbox1, hitbox2 = hitbox2, hitbox1
				x1,x2=x2,x1
				y1,y2=y2,y1
				w1,w2=w2,w1
				h1,h2=h2,h1
				xvel1,xvel2,yvel1,yvel2=xvel2,xvel1,yvel2,yvel1
				mass1,mass2,bounce1,bounce2,friction1,friction2 = mass2,mass1,bounce2,bounce1,friction2,friction1
				bodya, bodyb = bodyb, bodya
			end

			local collision, newxvel1, newyvel1, newxvel2, newyvel2, onfloor, onleftwall, onrightwall, onceil
				= DynamicRectDynamicRectCollisionFull(x1,y1,w1,h1, xvel1, yvel1,
				                                      x2,y2,w2,h2, xvel2, yvel2,
													  mass1,mass2, bounce1,bounce2, friction1,friction2)
			if collision then
				if bodyaprops.body_collide and bodybprops.body_collide then
					b1.body_xvel = newxvel1
					b1.body_yvel = newyvel1

					b2.body_xvel = newxvel2
					b2.body_yvel = newyvel2

					b1.body_onfloor = b1.body_onfloor or onfloor
					b1.body_onleftwall = b1.body_onleftwall or onleftwall
					b1.body_onrightwall = b1.body_onrightwall or onrightwall
					b1.body_onceil = b1.body_onceil or onceil

					b2.body_onfloor = b2.body_onfloor or onceil
					b2.body_onleftwall = b2.body_onleftwall or onrightwall
					b2.body_onrightwall = b2.body_onrightwall or onleftwall
					b2.body_onceil = b2.body_onceil or onfloor

					collided = true
				end

				local enitity1 = b1.body_parententity
				local enitity2 = b2.body_parententity

				local hitbox1callback = hitbox1.props.hitbox_callback 
				local hitbox2callback = hitbox2.props.hitbox_callback

				if hitbox1callback then
					hitbox1callback(h1, h2, b1, b2, entity1, entity2)
				end
				if hitbox2callback then
					hitbox2callback(h2, h1, b2, b1, entity2, entity1)
				end
			end
		end
	end

	return collided
end
HandleBodyCollision_kinematic_static    = nil
HandleBodyCollision_static_kinematic    = nil
HandleBodyCollision_kinematic_kinematic = nil
HandleBodyCollision_dynamic_kinematic   = nil
HandleBodyCollision_kinematic_dynamic   = nil

-- collision handlers for handling body collisions of specific types
__BODY_TYPE_COLLISION_HANDLER__ = {
 static={}, dynamic={}, kinematic={}}
__BODY_TYPE_COLLISION_HANDLER__["static"]["static"]       = HandleBodyCollision_static_static       
__BODY_TYPE_COLLISION_HANDLER__["static"]["dynamic"]      = HandleBodyCollision_static_dynamic      
__BODY_TYPE_COLLISION_HANDLER__["dynamic"]["static"]      = HandleBodyCollision_dynamic_static      
__BODY_TYPE_COLLISION_HANDLER__["dynamic"]["dynamic"]     = HandleBodyCollision_dynamic_dynamic     
__BODY_TYPE_COLLISION_HANDLER__["kinematic"]["static"]    = HandleBodyCollision_kinematic_static    
__BODY_TYPE_COLLISION_HANDLER__["static"]["kinematic"]    = HandleBodyCollision_static_kinematic    
__BODY_TYPE_COLLISION_HANDLER__["kinematic"]["dynamic"]   = HandleBodyCollision_kinematic_dynamic   
__BODY_TYPE_COLLISION_HANDLER__["dynamic"]["kinematic"]   = HandleBodyCollision_dynamic_kinematic   
__BODY_TYPE_COLLISION_HANDLER__["kinematic"]["kinematic"] = HandleBodyCollision_kinematic_kinematic

--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--


testfixture = IrisFixture:new({fixture_name = "fixture1"})
testfixture:NewHitbox({hitbox_x = 50, hitbox_y = 50, hitbox_w = 100, hitbox_h = 100 })
testfixture:NewHitbox({hitbox_x = 0, hitbox_y = 00, hitbox_w = 100, hitbox_h = 100 })
testbody = IrisBody:new({body_x = 190, body_y = 80, body_name = "body1", body_xvel=0, body_mass=10,
	body_classes={"ent"}, body_classesenabled = {"world"} })
testfixture12 = IrisFixture:new({fixture_solid=false, fixture_name = "fixture12"})
testfixture12.props.fixture_solid = false
testfixture12:NewHitbox({hitbox_x = 165, hitbox_y = 165, hitbox_w = 100, hitbox_h = 100 })
testbody:AddFixture(testfixture, true)
testbody:AddFixture(testfixture12, true)

testfixture2 = IrisFixture:new({fixture_name = "fixture2"})
testfixture2:NewHitbox({hitbox_x = 0, hitbox_y = 0, hitbox_w = 200, hitbox_h = 3})
testbody2 = IrisBody:new({body_x = 800, body_y = 400, body_name = "body2", body_xvel=0, body_mass=1/0,
	body_classes={"world"}, body_classesenabled = {"world"} })
testbody2:AddFixture(testfixture2, true)

testfixture3 = IrisFixture:new({fixture_name = "fixture3"})
testfixture3:NewHitbox({hitbox_x = 0, hitbox_y = 0, hitbox_w = 50, hitbox_h = 50})
testbody3 = IrisBody:new({body_x = 450, body_y = 150, body_name = "body3",
	body_classes={"ent"}, body_classesenabled = {"world"} })
testbody3:AddFixture(testfixture3, true)

testfixture4 = IrisFixture:new({fixture_name = "fixture4"})
testfixture4:NewHitbox({hitbox_x = 0, hitbox_y = 0, hitbox_w = 580, hitbox_h = 100})
--testfixture4:NewHitbox({hitbox_x = 600, hitbox_y = 50, hitbox_w = 200, hitbox_h = 100})
testbody4 = IrisBody:new({body_x = 0, body_y = 350, body_name = "body4", body_type = "static", body_classes={"world"}})
testbody4:AddFixture(testfixture4, true)

testfixture8 = IrisFixture:new({fixture_name = "fixture8"})
testfixture8:NewHitbox({hitbox_x = 0, hitbox_y = 0, hitbox_w = 180, hitbox_h = 50})
testbody8 = IrisBody:new({body_x = 600, body_y = 400, body_name = "body8", body_type = "static", body_classes={"world"}})
testbody8:AddFixture(testfixture8, true)

testfixture7 = IrisFixture:new({fixture_name = "fixture7"})
testfixture7:NewHitbox({hitbox_x = 0, hitbox_y = 0, hitbox_w = 100, hitbox_h = 50, hitbox_shape="triangle",
hitbox_triangleorientation="topright"})
testbody7 = IrisBody:new({body_x = 600, body_y = 350, body_name = "body7", body_type = "static", body_classes={"world"}})
testbody7:AddFixture(testfixture7, true)

testfixture5 = IrisFixture:new({fixture_name = "fixture5"})
testfixture5:NewHitbox({hitbox_x = 0, hitbox_y = 0, hitbox_w = 600, hitbox_h = 100})
testbody5 = IrisBody:new({body_x = 0, body_y = -50, body_name = "body5", body_type = "static", body_classes={"world"}})
testbody5:AddFixture(testfixture5, true)

testfixture6 = IrisFixture:new({fixture_name = "fixture6"})
testfixture6:NewHitbox({hitbox_x = 0, hitbox_y = 0, hitbox_w = 25, hitbox_h = 25})
testbody6 = IrisBody:new({body_x = 200, body_y = 200, body_name = "body6", body_type = "static", body_classes={"world"}})
testbody6:AddFixture(testfixture6, true)
