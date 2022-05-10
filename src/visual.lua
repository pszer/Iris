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
	local t = {
		props = IrisVisualPropPrototype(props)
	}
	setmetatable(t, IrisVisual)
	return t
end

IrisVisualElement = {}
IrisVisualElement.__index = IrisVisualElement
IrisVisualElement.__type = "irisvisualelement"

function IrisVisualElement:new(props)
	local t = {
		props = IrisVisualElementPropPrototype(props)
	}
	setmetatable(t, IrisVisualElement)
	return t
end

-- returns info that can be used by renderer
-- returns a table, each entry is a table with the following entries
-- x,y,w,h, r,g,b,a, flipx,flipy, rotate
function IrisVisual:GetDrawInfo()
	local props = self.props

	if not props.visual_animationstate then
		local drawables = {}

		for i,v in ipairs(props.visual_elements) do
			local d = {}
			local vprops = v.props

			if vprops.viselement_enable then
				d.img = vprops.viselement_graphic
				d.x   = vprops.viselement_x + props.visual_x
				d.y   = vprops.viselement_y + props.visual_y
				d.w   = vprops.viselement_w
				d.h   = vprops.viselement_h

				d.r   = vprops.viselement_r
				d.g   = vprops.viselement_g
				d.b   = vprops.viselement_b
				d.a   = vprops.viselement_a

				d.flipx   = vprops.viselement_flipx
				d.flipy   = vprops.viselement_flipy

				d.rotate   = vprops.viselement_rotate

				drawables[#drawables] = d
			end
		end

		return drawables
	end

	local drawables = {}

	for i,v in ipairs(props.visual_animations[props.visual_animationstate]) do
		local d = {}
		local vprops = v.props
		local iprops = props.visual_elements[i].props

		d.img = iprops.viselement_graphic
		d.x   = vprops.viselement_x or iprops.viselement_x + props.visual_x
		d.y   = vprops.viselement_y or iprops.viselement_y + props.visual_y
		d.w   = vprops.viselement_w or iprops.viselement_w 
		d.h   = vprops.viselement_h or iprops.viselement_h 

		d.r   = vprops.viselement_r or iprops.viselement_r 
		d.g   = vprops.viselement_g or iprops.viselement_g 
		d.b   = vprops.viselement_b or iprops.viselement_b 
		d.a   = vprops.viselement_a or iprops.viselement_a 

		d.flipx   = vprops.viselement_flipx or iprops.viselement_flipx 
		d.flipy   = vprops.viselement_flipy or iprops.viselement_flipy 

		d.rotate   = vprops.viselement_rotate or iprops.viselement_rotate 

		drawables[#drawables] = d
	end

	return drawables
end

-- a more convenient way of creating visuals and animations
--
-- example
-- 
-- { 
--    visual_elements = {
--		viselement1 = {
--			viselement_graphic = "img1.png"
--			viselement_x = 0
--			viselement_y = 0
--			viselement_w = 100
--			viselement_h = 100
--		}
--
--		viselement1 = {
--			viselement_graphic = "img2.png"
--			viselement_x = 0
--			viselement_y = 100
--			viselement_w = 100
--			viselement_h = 50
--		}
--    }
--
--    visual_animations = {
--		anim1 = {
--		    viselement1 = {
--             viselement_x = 5
--             viselement_y = 5
--          }
--		 }
--
--		 anim2 = {
--		    viselement1 = {
--            viselement_x = 15
--            viselement_y = 15
--		    }
--
--		    viselement2 = {
--            viselement_x = 0
--            viselement_y = 0
--            viselement_rotate = 1
--		    }
--		 }
--	  }
--
--	  visual_x = PropLink(entityprops, x)
--	  visual_y = PropLink(entityprops, y)
-- }

require "visual"

function VisualConf(conf)
	local visual = IrisVisual:new()
	local visualprops = visual.props

	for i,v in ipairs(conf) do
		visualprops[i] = v
	end

	local viselements = visualprops.visual_elements
	for i,v in ipairs(viselements) do
		viselements[i] = IrisVisualElement(v)
	end

	return visual
end
