require "prop"
require "set"

IrisImagePropPrototype = Props:prototype{

	-- prop      prop     prop default    prop input     prop      read
	-- name      type        value        validation     info      only

	{"image_graphic", nil, nil, nil, "love2d image data"}, -- done

	{"image_cachepermanent", "boolean", false, nil, "if true this image is cached permanently unless its a quad"}, -- done
	{"image_cachelifetime", "number", 300, nil, [[determines how long this image should stay cached when
	                                           not being used (in seconds)]]}, -- done
	{"image_cachelastpoll", "number", 0, nil, "the time when this image was last polled"},

	{"image_quadparent", nil, nil, nil, "if this image is a quad, this is the quads parent string path"}

}
