--[[ manages the loading/deloading of sprites
--]]

require "string"
require "props/imageprops"

IrisImage = {}
IrisImage = {}
IrisImage.__index = IrisImage
IrisImage.__type = "irisimage"

function IrisImage:new(props) 
	local t = {
		props = IrisImagePropPrototype(props)
	}
	setmetatable(t, IrisImage)
	t.props.image_cachelastpoll = love.timer.getTime()
	return t
end

function IrisImage:Poll()
	self.props.image_cachelastpoll = love.timer.getTime()
end

function IrisImage:MarkedForDecache()
	local props = v.props
	local time_elapsed = time - props.image_cachelastpoll

	-- clean if old
	if time_elapsed > props.image_cachelifetime
	   and not props.image_quadparent
	   and not props.image_cachelifetime then
		return true
	end

	-- clean quads if parent image is gone
	if props.image_quadparent and not LOADED_IMAGES[props.image_quadparent] then
		return true
	end

	return false
end

function IrisLoadImage(path, props)
	--[[local info = love.filesystem.getInfo(path, "file")
	if not info then
		print("nope")
		return nil
	end--]]


	props = props or {}
	props.image_quadparent = nil

	local ok, img = --love.graphics.newImage(path) 
		pcall(love.graphics.newImage, path)
	if not ok then
		print(path, img, "zomg")
		return nil
	end

	props.image_graphic = img
	local img = IrisImage:new(props)
	LOADED_IMAGES[path] = img 
	return img
end

function IrisPollImage(path)
	local img = LOADED_IMAGES[path]
	if not img then
		return nil
	end

	return true
end

function IrisGetImage(path)
	local img = LOADED_IMAGES[path]
	if not img then
		img = IrisLoadImage("img/" .. path) or IrisLoadImage(path)
		if img then
			return img.props.image_graphic
		else
			return nil
		end
	end

	img:Poll()
	return img.props.image_graphic
end

function IrisCleanImageCache()
	local time = love.timer.getTime()
	for i,v in ipairs(LOADED_IMAGES) do
		if v:MarkedForDecache() then
			LOADED_IMAGES[i] = nil
		end
	end
end

LOADED_IMAGES = {}
LOADED_IMAGES.__index = function(t,i)
	return rawget(LOADED_IMAGES, "img/" .. i)
end
setmetatable(LOADED_IMAGES, LOADED_IMAGES)

IrisLoadImage("null.png")
IrisGetImage("null.png")
