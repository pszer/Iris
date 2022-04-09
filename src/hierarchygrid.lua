-- ARCHIVED CODE

--[[
--  the hierarchy grid system used in world coarse collision detection (world.lua)
--
-- coarse collision detection
-- the world is split into a hierarchy grid, at each level the grid is split
-- into four equal quadrants. for example a world with a hierarchy grid depth of
-- 3 would be split into 4 three times, so at the grids finest level it is split
-- into 4^3=64 equal quadrants.
--
-- each quadrant contains information on what bodies are inside it
--
-- a collision between two bodies can only happen if there exist a quadrant
-- with those two bodies in it
--
-- what depth level results in the best performance is yet to be tested, larger worlds
-- will require more depth so the coarse collision detection rules out a good enough number
-- of collisions but the higher the depth the more computation will be required. there should be
-- a balance somwehere
--
--]]
--

require 'math'
require 'table'
require 'profiler'

GridHierarchy = { MAX_DEPTH = 10 , ALLOC_STEPS = 8}
GridHierarchy.__index = GridHierarchy

POWER_OF_FOUR = {} -- calling math.pow is expensive so powers of four up to MAX_DEPTH are memorised here
POWER_OF_TWO  = {} 
for i=0,GridHierarchy.MAX_DEPTH do
	POWER_OF_FOUR[i] = math.pow(4,i)
	POWER_OF_TWO[i] = math.pow(2,i)
end


function GridHierarchy:new(depth, width, height)
	local t = {
		__depth  = math.min(depth, GridHierarchy.MAX_DEPTH),
		__width  = width,
		__height = height,

		__grid_bodies     = {},
		__grid_count      = 0,
		__grid_length     = 0,

		__cell_x_size = width  / math.pow(2, depth),
		__cell_y_size = height / math.pow(2, depth)
	}

	setmetatable(t, GridHierarchy)

	function traverse(e, i)
		for quad=1,4 do
			local emptytable = {}
			e[quad] = emptytable
			if i <= t.__depth then
				traverse(e[quad], i+1)
			end
		end

		e[5] = {}
	end
	traverse(t.__grid_bodies, 1)

	local count = t:NodeCount()
	t.__grid_count = count
	t.__grid_length = POWER_OF_TWO[t.__depth]

	return t
end

function GridHierarchy:GridCount()
	return POWER_OF_FOUR[self.__depth]
end

function GridHierarchy:NodeCount()
	local c = 0
	for i=1,self.__depth do
		c = c + POWER_OF_FOUR[i]
	end
end

-- the index for a grid cell at the finest level can be specified
-- using {i_1, i_2, i_3, ..., i_n} where n is the grid depth and each
-- each index specifies a quadrant, with i_1 being the coarsest quadrant
-- and i_n being the finest
--
-- i is a number from 1 to 4
-- 1 = top left quadrant
-- 2 = top right quadrant
-- 3 = bottom left quadrant
-- 4 = bottom right quadrant
--
-- instead of a quad tree data structure, the data for each grid is stored
-- in a sequential array for efficiency. the index returned by this function corresponds
-- to the index for that cell in __grid_indices and __grid_body_count (call it i).
-- __grid_body_count[i] (if non-nil) contains the number of bodies in the cell i (call it n)
-- __grid_indices[i]    (if non-nil) contains the index for the collection of bodies in cell i
--                      stored in __grid_bodies (call it j)
-- the bodies in cell i are then __grid_bodies[j+0], __grid_bodies[j+1], ... __grid_bodies[j+n-1]
function GridHierarchy:GridIndex(indices)
	local len = #indices
	local index = 0
	for i,q in ipairs(indices) do
		local exponent = self.__depth - i - (self.__depth - len)
		index = index + (q-1) * POWER_OF_FOUR[exponent]
	end
	return len, index + 1
end

-- the inverse function for GridHierarchy:GridIndex but only
-- for indices at leaf level (maximum depth)
function GridHierarchy:GridIndexInverse(depth, index)
	local result = {}
	index = index - 1

	for i = 0, depth do
		local p = POWER_OF_FOUR[i+1]
		local m = index % p

		index = index - m
		result[self.__depth - i] = m / POWER_OF_FOUR[i] + 1
	end

	return result
end

function GridHierarchy:CellIJToIndex(i,j)
	if i<=0 or j<=0 or i>self.__grid_length or j>self.__grid_length then
		return nil
	end

	local index = {}
	for depth = 1, self.__depth do
		local s = POWER_OF_TWO[self.__depth - depth]
		if i > s then
			i = i - s
			if j > s then
				j = j - s
				index[depth] = 4
			else
				index[depth] = 2
			end
		else
			if j > s then
				j = j - s 
				index[depth] = 3
			else
				index[depth] = 1
			end
		end

	end

	return index
end

function GridHierarchy:CellXYToIndex(x,y)
	return self:CellIJToIndex(math.floor(x / self.__cell_x_size) + 1, math.floor(y / self.__cell_y_size) + 1)
end

-- expects a tuple index
function GridHierarchy:AddBodyToCell(index, body)
	if not index then
		return
	end

	function traverse(e, j)
		if j == #index or not index[j+1] then
			return e[index[j]]
		else
			return traverse(e[index[j]], j+1)
		end
	end	

	local cell = traverse(self.__grid_bodies, 1)
	for i=1, #cell[5] do
		if body == cell[5][i] then
			return
		end
	end

	table.insert(cell[5], body)

	--[[print("data")
	for i,v in pairs(gridtest.__grid_bodies[depth]) do
		local p = nil
		for j,k in pairs(gridtest.__grid_indices[depth]) do
			if k == i then
				p = j
				break
			end
		end
		if not p then
			print(i,v)
		else
			print(i,v,p)
		end
	end--]]
end

function GridHierarchy:BodyExistsInCell(index, body)
	if not index then
		return false
	end

	local depth, cell_i = self:GridIndex(index)
	local data_i = self.__grid_indices[depth][cell_i]

	-- if this cell is currently empty, nothing is to be done
	if not data_i then
		return false
	else
		local body_count = self.__grid_body_count[depth][cell_i]

		-- check if this body is in this cell
		for i=0,body_count-1 do
			if body == self.__grid_bodies[depth][data_i + i] then
				return true
			end
		end
	end

	return false
end

-- adds body to all the gridpoints covered by bounding box
-- given by x,y,w,h
function GridHierarchy:AddBodyToGrid(body, x,y,w,h)
	local x_cells_covered = math.floor(w / self.__cell_x_size)
	local y_cells_covered = math.floor(h / self.__cell_y_size)

	for xi = 0, x_cells_covered do
		for yi = 0, y_cells_covered do
			local index = self:CellXYToIndex(x + xi*self.__cell_x_size, y + yi*self.__cell_y_size)
			local node = {}

			if index then
				for i = 1, self.__depth do
					node[i] = index[i]
					self:AddBodyToCell(node, body)
				end
			end
		end
	end

	local index1 = self:CellXYToIndex(x + w, y + h)
	local index2 = self:CellXYToIndex(x + w, y)
	local index3 = self:CellXYToIndex(x, y + h)
	local node1 = {}
	local node2 = {}
	local node3 = {}
	for i = 1, self.__depth do
		if index1 then
			node1[i] = index1[i]
			self:AddBodyToCell(node1, body)
		end
		if index2 then
			node2[i] = index2[i]
			self:AddBodyToCell(node2, body)
		end
		if index3 then
			node3[i] = index3[i]
			self:AddBodyToCell(node3, body)
		end
	end
end

function GridHierarchy:RemoveBodyFromGrid(body)
	function traverse(index, i)
		for quad=1,4 do
			index[i] = quad
			if self:RemoveBodyAtCell(index, body) and i < self.__depth then
				traverse(index, i+1)
			end

			for j = i+1,self.__depth do
				index[j] = nil
			end
		end
	end
	traverse({}, 1)
end

-- returns true if a body has been removed
function GridHierarchy:RemoveBodyAtCell(index, body)
	if not index then
		return false
	end

	function traverse(e, j)
		if j == #index or not index[j+1] then
			return e[index[j]]
		else
			return traverse(e[index[j]], j+1)
		end
	end	

	local cell = traverse(self.__grid_bodies, 1)
	for i=1,#cell[5] do
		if body == cell[5][i] then
			table.remove(cell[5], i)
			return true
		end
	end
	return false

	--[[print("data")
	for i,v in pairs(gridtest.__grid_bodies[depth]) do
		local p = nil
		for j,k in pairs(gridtest.__grid_indices[depth]) do
			if k == i then
				p = j
				break
			end
		end
		if not p then
			print(i,v)
		else
			print(i,v,p)
		end
	end--]]
end

function GridHierarchy:GetBodiesAtCell(index)
	local t = {}

	local depth, cell_i = self:GridIndex(index)
	local data_i = self.__grid_indices[depth][cell_i]

	if data_i then
		local body_count = self.__grid_body_count[depth][cell_i]
		for i=0, body_count-1 do
			table.insert(t, self.__grid_bodies[depth][data_i + i])
		end
	end

	return t
end

-- returns the corresponding x,y,w,h of a given index
function GridHierarchy:CellToArea(index)
	local x,y,w,h = 0,0, self.__cell_x_size, self.__cell_y_size

	for i=1,self.__depth do
		local quad = index[i]
		local quadsize = POWER_OF_TWO[self.__depth-i]

		if quad == 3 or quad == 4 then
			y = y + quadsize * h
		end

		if quad == 2 or quad == 4 then
			x = x + quadsize * w
		end
	end

	return x,y,w,h
end

function GridHierarchy:CellEmpty(index)

	function traverse(e, j)
		if j == #index or not index[j+1] then
			return e[index[j]]
		else
			return traverse(e[index[j]], j+1)
		end
	end	

	local cell = traverse(self.__grid_bodies, 1)

	return #cell[5] == 0
end

gridtest = GridHierarchy:new(3, 64, 64)

gridtest:AddBodyToCell({2,2,2}, "a")
gridtest:AddBodyToCell({2,2,2}, "b")

gridtest:AddBodyToCell({2,2,1}, "c")
gridtest:AddBodyToCell({2,2,1}, "d")
gridtest:AddBodyToCell({2,2,1}, "e")

gridtest:AddBodyToCell({2,2,2}, "f")

gridtest:AddBodyToCell({2,2,3}, "p")

gridtest:AddBodyToCell({2,2,1}, "g")

gridtest:AddBodyToCell({2,2,2}, "h")

gridtest:AddBodyToCell({2,2,2}, "L")
gridtest:AddBodyToCell({2}, "L")
gridtest:RemoveBodyAtCell({2}, "L")

gridtest:AddBodyToGrid("AA",16,16,8,8)
gridtest:RemoveBodyFromGrid("AA")

--print("bodies", unpack(gridtest:GetBodiesAtCell({2,2,2})))
print("fgfsfd", unpack(gridtest:CellXYToIndex(1,1)))
