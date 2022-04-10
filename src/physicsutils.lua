--[[
-- utility functions used in the physics for the game
--]]
--

--[[ given a table of axis-aligned rectangles
--   it returns the minimum bounding box containing all
--   the rectangles
--   each entry in the table should be of form {x,y,w,h}
--   returns x,y,w,h
--]]
--

function ComputeBoundingBox(boxes)
	local xmin,ymin,xmax,ymax
	local first = true

	local mathmin = math.min
	local mathmax = math.max
	local unpack = unpack

	for _,box in ipairs(boxes) do
		if first then
			xmin,ymin, xmax,ymax = unpack(box)
			xmax = xmin + xmax
			ymax = ymin + ymax
			first = false
		else
			local x,y,w,h = unpack(box)

			xmin = mathmin(xmin, x)
			ymin = mathmin(ymin, y)
			xmax = mathmax(xmax, x+w)
			ymax = mathmax(ymax, y+h)
		end
	end

	if first then
		return nil,nil,nil,nil
	else
		return xmin,ymin, xmax-xmin, ymax-ymin
	end
end
