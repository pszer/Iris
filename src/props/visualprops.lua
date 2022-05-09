require "prop"
require "set"

IrisVisualElementPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"viselement_graphic", "string", "", nil, "the image graphic for this visual element"}, -- done

	{"viselement_x", "number", 0, nil, "the x position of the visual element"}, -- done
	{"viselement_y", "number", 0, nil, "the y position of the visual element"}, -- done
	{"viselement_w", "number", 0, nil, "the width of the visual element"}, -- done
	{"viselement_h", "number", 0, nil, "the height of the visual element"}, -- done

	{"viselement_r", "number", 1, nil, "the red component multiplier of the visual element"}, -- done
	{"viselement_g", "number", 1, nil, "the green component multiplier of the visual element"}, -- done
	{"viselement_b", "number", 1, nil, "the blue component multiplier of the visual element"}, -- done
	{"viselement_a", "number", 1, nil, "the alpha component multiplier of the visual element"}, -- done

	{"viselement_flipx", "boolean", false, nil, "if true the image is flipped x-wise"}, -- done
	{"viselement_flipy", "boolean", false, nil, "if true the image is flipped y-wise"}, -- done

	{"viselement_enable", "boolean", true, nil, "if false this vis element will not be drawn"} -- done
}

IrisVisualPropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"visual_elements", "table", nil, PropDefaultTable{}, "the table of visual elements in this visual"}, -- done

}
