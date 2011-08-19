---------------------------------------------------------------------------------------------------
-- -= ObjectLayer =-
---------------------------------------------------------------------------------------------------

-- Setup
local love = love
local unpack = unpack
local pairs = pairs
local ipairs = ipairs
local Object = require( TILED_LOADER_PATH .. "Object")
local ObjectLayer = {}
ObjectLayer.__index = ObjectLayer


-- Creates and returns a new ObjectLayer
function ObjectLayer:new(map, name, color, opacity, prop)
	
	-- Create a new table for our object layer and do some error checking.
	local ol = {}
	assert(map, "ObjectLayer:new - Requires a parameter for map")
	
	ol.map = map							-- The map this layer belongs to
	ol.name = name or "Unnamed ObjectLayer"	-- The name of this layer
	ol.color = color or {255,255,255}		-- The color theme
	ol.opacity = opacity or 1				-- The opacity
	ol.objects = {}							-- The layer's objects indexed by type
	ol.properties = prop or {}				-- Properties set by Tiled.
	
	-- Return the new object layer
	return setmetatable(ol, ObjectLayer)
end

-- Creates a new object, automatically inserts it into the layer, and then returns it
function ObjectLayer:newObject(name, type, x, y, width, height, gid, prop)
	local obj = Object:new(self, name, type, x, y, width, height, gid, prop)
	self.objects[#self.objects+1] = obj
	return obj
end

-- Sorting function for objects. We'll use this below in ObjectLayer:draw()
local function drawSort(o1, o2) 
	return o1.drawInfo.order < o2.drawInfo.order 
end

-- Draws the object layer. The way the objects are drawn depends on the map orientation and
-- if the object has an associated tile. It tries to draw the objects as closely to the way
-- Tiled does it as possible.
function ObjectLayer:draw()

	local obj, d, offset							-- Some temporary variables
	local r,g,b,a = love.graphics.getColor()		-- Store the color so we can set it back
	local line = love.graphics.getLineWidth()		-- Store the line width so we can set it back 
	local iso = self.map.orientation == "isometric"	-- If true then the map is isometric
	local tiles = self.map.tiles					-- The map tiles
	local rng = self.map.drawRange					-- The drawing range. [1-4] = x,y,width,height
	local drawList = {}								-- A list of the objects to be drawn
	
	-- Set the color and line width. Store the old values so we can revert them back at the end.
	r,g,b,a = love.graphics.getColor()
	line = love.graphics.getLineWidth()
	love.graphics.setLineWidth(2)
	self.color[4] = 255 * self.opacity
	
	-- Put only objects that are on the screen in the draw list. If the screen range isn't defined
	-- add all objects
	for i = 1,#self.objects do
		obj = self.objects[i]
		di = obj.drawInfo
		-- Draw list is defined
		if rng[1] and rng[2] and rng[3] and rng[4] then
			if 	di.right > rng[1]-20 and 
				di.bottom > rng[2]-20 and 
				di.left < rng[1]+rng[3]+20 and 
				di.top < rng[2]+rng[4]+20 then 
				
					drawList[#drawList+1] = obj
			end
			
		-- Draw list isn't defined
		else
			drawList[#drawList+1] = obj
		end
	end
	
	-- Sort the draw list by the object's draw order
	table.sort(drawList, drawSort)

	-- For every object in the draw list
	for i = 1,#drawList do
		obj = drawList[i]
		di = obj.drawInfo
		
		-- If the object has a custom draw function then call it
		if type(obj.draw) == "function" then
			love.graphics.setColor(r,g,b,a)
			obj.draw(di.x, di.y)
		
		-- The object has a gid - draw a tile
		elseif obj.gid then
				love.graphics.setColor(r,g,b,a)
				tiles[obj.gid]:draw(di.x, di.y)
				
		-- If map isn't set to draw tileless objects then do nothing
		elseif self.map.draw_objects == false then
		
		-- Map is isometric - draw a parallelogram
		elseif iso then
		
			-- Draw a parallelogram
			offset = {}	
			for k,v in ipairs(di) do 
				offset[k] = v + (k+1)%2
			end

			love.graphics.setColor(self.color[1], self.color[2], self.color[3], 50)
			love.graphics.polygon("fill", unpack(di))
			
			love.graphics.setColor(0, 0, 0, 255 * self.opacity)
			love.graphics.polygon("line", unpack(offset))
			
			love.graphics.setColor(unpack(self.color))
			love.graphics.polygon("line", unpack(di))

		-- Map is orthogonal - draw a rectangle
		else
			love.graphics.setColor(self.color[1], self.color[2], self.color[3], 50)
			love.graphics.rectangle("fill", di.x+1, di.y+1, di[1]-1, di[2]-1)
			
			love.graphics.setColor(0, 0, 0, 255 * self.opacity)
			love.graphics.rectangle("line", di.x+1, di.y+1, di[1], di[2])
			love.graphics.print(obj.name, di.x+1, di.y-19)
			
			love.graphics.setColor(unpack(self.color))
			love.graphics.rectangle("line", di.x, di.y, di[1], di[2])
			love.graphics.print(obj.name, di.x, di.y-20)
		end
	end

	-- Set back the line width and color as they were before
	love.graphics.setLineWidth(line)
	love.graphics.setColor(r,g,b,a)
end

-- Return the ObjectLayer class
return ObjectLayer


--[[Copyright (c) 2011 Casey Baxter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.--]]