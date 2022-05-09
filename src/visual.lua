-- a "visual" is an object that can be drawn to the screen, its a collection
-- of visual element sprites each with customisable position, scale and other attributes that can
-- then be positioned in the world.
-- visuals have support for animation by configuring sprites to enable/disable or move
-- for different animation frames

require "images"

IrisVisual = {}
IrisVisual.__index = IrisVisual
IrisVisual.__type = "irisvisual"

function IrisVisual:new(props)

end
