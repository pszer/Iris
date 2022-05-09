require 'string'

require "props/irisrenderprops"
require "room"
require "visual"

IrisRenderer = {
	props = IrisRenderPropPrototype()
}
IrisRenderer.__index = Renderer

function IrisRenderer:RenderWorldDebug(world)
	local bodies = world:CollectBodies()

	for _,b in ipairs(bodies) do
		local fixtures = b:ActiveFixtures()
		local hitboxes = b:ActiveHitboxes(true)

		if b.props.body_type ~= "static" then
			love.graphics.setColor(0.25,0.25,0.4,0.3)
		else
			love.graphics.setColor(0.4,0.4,0.1,0.5)
		end
		for i,H in ipairs(hitboxes) do
			local x,y,w,h = H:Position()

			if H.props.hitbox_shape == "rect" then
				love.graphics.rectangle("fill",x,y,w,h)
			else
				if H.props.hitbox_triangleorientation == "topright" then
					love.graphics.polygon("fill",x,y,x,y+h,x+w,y+h)
				elseif H.props.hitbox_triangleorientation == "topleft" then
					love.graphics.polygon("fill",x,y+h,x+w,y+h,x+w,y)
				elseif H.props.hitbox_triangleorientation == "bottomleft" then
					love.graphics.polygon("fill",x,y,x+w,y+h,x+w,y)
				else
					love.graphics.polygon("fill",x,y,x+w,y,x,y+h)
				end

				local mx,my = x+w/2, y+h/2
				love.graphics.setColor(0.6,0.6,0.1,0.7)
				love.graphics.line(mx,my, mx + H.__hyp_normalx* 25,my+H.__hyp_normaly* 25)
			end
		end

		love.graphics.setColor(1,0.5,1,0.5)
		for i,f in ipairs(fixtures) do
			local x,y,w,h = f:ComputeBoundingBox()

			love.graphics.rectangle("line",x,y,w,h)
		end

		love.graphics.setColor(1,0,0,0.9)
		local x,y,w,h = b:ComputeBoundingBox(true)

		if x then
		love.graphics.rectangle("line",x,y,w,h)
		love.graphics.setColor(1,1,1,0.5)
		love.graphics.print("body: " .. tostring(b.props.body_name) ..
		                  "\npos : " .. tostring(b.props.body_x) .. " " .. tostring(b.props.body_y) ..
		                  "\nvel : " .. tostring(b.props.body_xvel) .. " " .. tostring(b.props.body_yvel) ..
		                  "\nmass: " .. tostring(b.props.body_mass),
						  x,y)
		end
	end

	if testworld.__sortedaabb then
		for i,v in ipairs(testworld.__sortedaabb.data) do
			local x = v[1]
			if v[2] then
				love.graphics.setColor(0.1,0.9,0.1,0.6)
			else
				love.graphics.setColor(0.9,0.1,0.1,0.6)
			end
			love.graphics.line(x,-10000,x,10000)
		end
	end
end

function IrisRenderer:RenderFPSCounter()
	love.graphics.print(string.format("FPS %.1f", FPS or 0), 0,0)
end

function IrisRenderer:Draw()
	local props = self.props

	if props.render_showfps then
		self:RenderFPSCounter()
	end
	if props.render_renderworlddebug then
		if props.render_world then
			self:RenderWorldDebug(props.render_world)
		end
	end

	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(IrisGetImage("rb.png",256,256))
end
