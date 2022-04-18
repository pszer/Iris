--[[ The world of iris is stored in individual rooms
-- rooms have map geometry for things to walk on, decoration, an entity table,
-- warps to other rooms etc.
--]]
--

require "props/roomprops"
require "body"
require "world"
require "enttable"

IrisRoomData = {}
IrisRoomData.__index = IrisRoomdata
IrisRoomData.__type  = "irisroomdata"

function IrisRoomData:new(props)
	local this = {
		props = IrisRoomPropPrototype(props)
	}
	setmetatable(this, IrisRoomData)
	return this
end

--testroom = IrisRoomData:new()
--testroom.props.room_body = testbody

-- table of all room data
IrisRooms = {rooms = {}}
IrisRooms.__index = IrisRooms

function IrisRooms:AddRoom(room, overwrite)
	local name = room.props.room_name

	if self.rooms[name] and not overwrite then
		print("tried to overwite room with name \"" .. name "\"")
		return false
	end

	self.rooms[name] = room
	return true
end

-- populates a world and entity table and returns them
function IrisRooms:LoadRoom(room, enttablecollection)
	local room_name = room.props.room_name

	local worldprops = room.props.room_worldprops
	world = IrisWorld:new(worldprops)
	enttable = EntTable:new{enttable_name = (room_name or "room") .. "_enttable"}

	for _,entprops in ipairs(room.props.room_entspawners) do
		enttable:AddEntity(IrisEnt:new(entprops))
	end

	geometry_bodies = {}
	local count = 1
	for _,shape in ipairs(room.props.room_geometry) do
		local x,y,w,h = shape.x, shape.y, shape.w, shape.h
		local orient = shape.orient
		local hshape
		if orient then
			hshape = "triangle"
		else
			orient = "nil"
			hshape = "rect"
		end
		local props = shape.props or {}

		local hitbox = IrisHitbox:new{hitbox_w = w, hitbox_h = h, 
		                               hitbox_shape = hshape, hitbox_triangleorientation = orient}
		local fixture = IrisFixture:new{fixture_solid = true}
		fixture:AddHitbox(hitbox)
		local body = IrisBody:new{body_x = x, body_y = y, body_type = "static", body_classes = {"world"}}
		body.props(props)
		body:AddFixture(fixture, true)
		table.insert(geometry_bodies, body)
	end

	for _,entspawner in ipairs(room.props.room_entspawners) do
		local entdescriptor = entspawner[1]
		local entpropsoverride = entspawner[2]
		local bodypropsoverride = entspawner[3]

		local ent = IrisCreateEntity(entdescriptor, entpropsoverride, bodypropsoverride)
		if ent then
			enttable:AddEntity(ent)
		end
	end

	if enttablecollection then
		enttablecollection:AddTable(enttable)
		world:CollectEntTableCollection(enttablecollection)
		world:CollectTable(geometry_bodies)
	else
		world:CollectEntTable(enttable)
		world:CollectTable(geometry_bodies)
	end

	return world,enttable
end

function IrisRooms:LoadRoomFromFile(name, enttablecollection)
	self:LoadRoom(require(name), enttablecollection)
end

function IrisRooms:AddRoomFile(fname, enttablecollection)
	local room = require(fname)
	if iristype(room) ~= "irisroomdata" then
		print(fname .. " is not a valid room file, no irisroomdata returned")
		return false
	end

	return self.LoadRoom(room, enttablecollection)
end

function IrisRooms:AddRoomFiles(fnames, enttablecollection)
	for i,v in ipairs(fnames) do
		self:AddRoomFile(v)
	end
end
