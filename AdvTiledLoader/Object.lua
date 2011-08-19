---------------------------------------------------------------------------------------------------
-- -= Object =-
---------------------------------------------------------------------------------------------------

-- Setup
local Object = {}
Object.__index = Object

-- Returns a new Object
function Object:new(layer, name, type, x, y, width, height, gid, prop)

	-- Public:
	local obj = {}
	obj.layer = layer			-- The layer that the object belongs to
	obj.name = name or ""		-- Name of the object
	obj.type = type or ""		-- Type of the object
	obj.x = x or 0				-- X location on the map
	obj.y = y  or 0				-- Y location on the map
	obj.width = width or 0		-- Object width in tiles
	obj.height = height or 0	-- Object height in tiles
	obj.gid = gid				-- The object's associated tile. If false an outline will be drawn.
	obj.properties = prop or {} -- Properties set by tiled.
	
	obj.draw = nil				-- You can assign a function to this to call instead of the object's
								-- normal drawing function. It must be able to take x and y as
								-- parameters.
	
	-- drawInfo stores values needed to actually draw the object. You can either set these yourself
	-- or use updateDrawInfo to do it automatically.
	obj.drawInfo = {
	
		-- x and y are the drawing location of the object. This is different than the object's x and
		-- y value which is the object's placement on the map.
		x = 0,		-- The x draw location
		y = 0,		-- The y draw location
		
		-- These limit the drawing of the object. If the object falls out of the bounds of
		-- the map's drawRange then the object will not be drawn. 
		left = 0,   -- The leftmost point on the object
		right = 0,	-- The rightmost point on the object
		top = 0,	-- The highest point on the object
		bottom = 0,	-- The lowest point on the object
		
		-- The order to draw the object in relation to other objects. Usually equal to bottom.
		order = 0,
		
		-- In addition to this, other drawing information can be stored in the numerical 
		-- indicies which is context sensitive to the map's orientation and if the object has a gid 
		-- associated with it or not.
	} 
	
	-- Update the draw info
	Object.updateDrawInfo(obj)
	
	-- Return our object
	return setmetatable(obj, Object)
end

-- Updates the draw information. Call this every time the object moves or changes size.
function Object:updateDrawInfo()
	local di = self.drawInfo
	local map = self.layer.map
	
	-- Isometric map
	if map.orientation == "isometric" then
	
		-- Is a tile object
		if self.gid then
			local t = map.tiles[self.gid]
			local tw, th = t.width, t.height
			di.x, di.y  = map:fromIso(self.x, self.y)
			di.order = di.y
			di.x, di.y = di.x - map.tileWidth/2, di.y - th
			di.left, di.right, di.top, di.bottom = di.x, di.x+tw, di.y , di.y +th
		
		-- Is not a tile object
		else
			-- 1-8:polygon verticies
			di[1], di[2] = map:fromIso(self.x, self.y)
			di[3], di[4] = map:fromIso(self.x + self.width, self.y)
			di[5], di[6] = map:fromIso(self.x + self.width, self.y + self.height)
			di[7], di[8] = map:fromIso(self.x, self.y + self.height)
			di.left, di.right, di.top, di.bottom = di[7], di[3], di[2], di[6]
			di.order = 1
		end
		
	-- Orthogonal map
	else
	
		-- Is a tile object
		if self.gid then
			local t = map.tiles[self.gid]
			local tw, th = t.width, t.height
			di.x, di.y = self.x, self.y
			di.order = di.y
			di.y = di.y - th
			di.left, di.top, di.right, di.bottom = di.x, di.y, di.x+tw, di.y+th
			
		-- Is not a tile object
		else
			-- 1:width, 2:height
			di.x, di.y = self.x, self.y
			di[1], di[2] = self.width, self.height
			di.left, di.top, di.right, di.bottom = di.x, di.y , di.x+di[1], di.y +di[2]
			di.order = 1
		end
	end
end

-- Moves the object to the relative location
function Object:move(x,y)
	self.x = self.x + x
	self.y = self.y + y
	self:updateDrawInfo()
end

-- Moves the object to the absolute location
function Object:moveTo(x,y)
	self.x = x
	self.y = y
	self:updateDrawInfo()
end

-- Resizes the object
function Object:resize(w,h)
	self.width = w or self.width
	self.height = h or self.height
	self.updateDrawInfo()
end

-- Returns the Object class
return Object


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