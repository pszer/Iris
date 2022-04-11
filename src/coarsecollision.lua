--[[ coarse (broad-phase) collision is implemented as sweep and prune
--]]
--

require 'sortedtable'

SortedAABB = {}
SortedAABB.__index = SortedAABB

function SortedAABB:new()
	local t = {
		data = nil, -- each entry in data is {pos,is_min,body}
		xaxis = true, -- the axis used for sweep and pruning

		__lessthan = function (a,b)
			return a[1] < b[1]
		end,
		
		__equality = function (a,b)
			return a[1] == b[1]
		end
	}
	t.data = SortedTable:new(t.__lessthan, t.__equality)
	setmetatable(t, SortedAABB)
	return t
end

-- axis = "x" or "y"
function SortedAABB:SortBodies(bodies, solid, axis, addvelocity)
	local xaxismin = {}
	local xaxismax = {}
	local yaxismin = {}
	local yaxismax = {}

	local count = 1
	local bodies_reindex = {true,true,true,true,true,true,true} -- avoid too much rehashing
	for i,b in ipairs(bodies) do
		local x,y,w,h = b:ComputeBoundingBox(solid)
		if x then
			if addvelocity then
				local xv = b.props.body_xvel
				local yv = b.props.body_yvel
				if xv < 0 then
					x = x + xv
					w = w - xv
				else
					w = w + xv
				end

				if yv < 0 then
					y = y + yv
					h = h - yv
				else
					h = h + yv
				end
			end
			xaxismin[count] = x
			yaxismin[count] = y
			xaxismax[count] = x + w
			yaxismax[count] = y + h
			bodies_reindex[count] = bodies[i]
			count = count + 1
		end
	end
	local xvar, yvar
	if axis then
		if axis == "x" then
			xvar = 1
			yvar = 0
		else
			yvar = 1
			xvar = 0
		end
	else
		xvar = TableVariance(xaxismin)
		yvar = TableVariance(yaxismin)
	end

	local axismin, axismax

	if xvar > yvar then
		self.xaxis = true
		axismin = xaxismin
		axismax = xaxismax
	else
		self.xaxis = false
		axismin = yaxismin
		axismax = yaxismax
	end

	local maxes = SortedTable:new(self.__lessthan, self.__equality)
	for i=1,#axismin do
		self.data:Add{axismin[i], true, bodies_reindex[i]}
		maxes:Add{axismax[i], false, bodies_reindex[i]}
	end

	self.data:Merge(maxes)
end

function TableAverage(t)
	local total = 0
	local n = #t
	for i=1,n do
		total = total + t[i]
	end
	return total / n
end

function TableVariance(t)
	local avg = TableAverage(t)
	local n = #t
	local total = 0
	for i=1,n do
		local diff = t[i] - avg
		total = total + diff*diff
	end
	return total / n
end

-- returns a table of collision
-- the index to the returned table is a body and the key is a table
-- of other bodies it might collide with
function SortedAABB:GetPossibleCollisions()
	local interval_bodies = {}
	local bodies_in_interval = 0
	local collisions = {}

	for _,v in ipairs(self.data) do
		-- if the beginning of a new interval, add the body to current bodies in interval
		-- and add it as a possible collision with all other bodies in the interval
		if v[2] then
			for i=1,bodies_in_interval do
				local cancollide, body1, body2 = v[3]:CanCollideWith(interval_bodies[i])
				if cancollide then
					local collidetable = collisions[body1]
					if not collidetable then
						collidetable = {}
						collisions[body1] = collidetable
					end
					collidetable[#collidetable+1] = body2
				end
			end

			bodies_in_interval = bodies_in_interval + 1
			interval_bodies[bodies_in_interval] = v[3]
		else
			for i=1,bodies_in_interval do
				if v[3] == interval_bodies[i] then
					table.remove(interval_bodies, i)
					bodies_in_interval = bodies_in_interval - 1
				end
			end
		end
	end

	return collisions
end

function SortedAABB:RemoveBody(body)
	local ai, bi = nil, nil
	for i,v in ipairs(self.data) do
		if v[3] == body then
			if v[2] == true then
				ai = i
			else
				bi = i
				break
			end
		end
	end

	if ai then
		body.data:Remove(ai)
		body.data:Remove(bi)
	end
end
