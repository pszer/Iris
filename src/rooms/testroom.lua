require "ents/player"

return IrisRoomData:new{

	room_name = "test_room",

	room_width = 3000,
	room_width = 3000,

	room_geometry = {

		{x=200,y=200,w=25,h=25},
		{x=600,y=350,w=100,h=50, orient="topright"},
		{x=0,y=-50,w=600,h=100},
		{x=0,y=350,w=600,h=100},
		{x=600,y=400,w=180,h=50}

	},

	room_entspawners = {
		{IrisEnt_Player, {}, {body_x = 350, body_y = 150}}
	},

	room_worldprops = {

		world_gravity = 0.48 

	}


}
