
-- Setup
local loader = require("AdvTiledLoader.Loader")
loader.path = "maps/"
local map = loader.load("desert.tmx")
local layer = map.tl["Ground"]

-- This is the guy we'll be moving around.
local Guy = map.ol["Object1"]:newObject("Guy", "Entity",0,0,32,64)
Guy.tileX = 8		-- The horizontal tile
Guy.tileY = 22		-- The vertical tile
Guy.facing = "down"	-- The direction our guy is facing
Guy.quads = {		-- The frames of the image
		down = 		love.graphics.newQuad(0,0,32,64,256,64),
		downright = love.graphics.newQuad(32,0,32,64,256,64),
		right = 	love.graphics.newQuad(64,0,32,64,256,64),
		upright = 	love.graphics.newQuad(96,0,32,64,256,64),
		up = 		love.graphics.newQuad(128,0,32,64,256,64),
		upleft = 	love.graphics.newQuad(160,0,32,64,256,64),
		left = 		love.graphics.newQuad(192,0,32,64,256,64),
		downleft = 	love.graphics.newQuad(224,0,32,64,256,64),
	}
-- The image of our guy
Guy.image = love.graphics.newImage("images/guy.png")
Guy.width = Guy.image:getWidth()
Guy.height = Guy.image:getHeight()

-- Move the guy around the tiles
function Guy.moveTile(x,y)
	-- Change the facing direction
	if x > 0 then Guy.facing = "right"
	elseif x < 0 then Guy.facing = "left"
	elseif y > 0 then Guy.facing = "down"
	else Guy.facing = "up" end
	-- Grab the tile
	local tile = layer.tileData(Guy.tileX+x, Guy.tileY+y)

	-- If the tile doesn't exist or is an obstacle then exit the function
	if tile == nil then return end
	if tile.properties.obstacle then return end
	-- Otherwise change the guy's tile
	Guy.tileX = Guy.tileX + x
	Guy.tileY = Guy.tileY + y
	Guy:moveTo(Guy.tileX*map.tileWidth, (Guy.tileY+1)*map.tileHeight-Guy.height)
end

-- Do this at first to make sure the guy is drawn correctly.
Guy.moveTile(0,0)
Guy.facing = "down"

-- Draw our guy. This function is passed to TileSet.drawAfterTile() which calls it passing the
-- x and y value of the bottom left corner of the tile.
function Guy.draw()
	love.graphics.drawq(Guy.image, Guy.quads[Guy.facing], Guy.x, Guy.y)
end


-- Our example class
local DesertExample = {}

-- Called from love.keypressed()
function DesertExample.keypressed(k)
	if k == 'w' then Guy.moveTile(0,-1) end
	if k == 'a' then Guy.moveTile(-1,0) end
 	if k == 's' then Guy.moveTile(0,1) end
	if k == 'd' then Guy.moveTile(1,0) end
end

-- Resets the example
function DesertExample.reset()
	global.tx = -5
	global.ty = -434
	Guy.tileX = 8
	Guy.tileY = 22
	Guy.moveTile(0,0)
	Guy.facing = "down"
	displayTime = 0
end

-- Update the display time for the character control instructions
function DesertExample.update(dt)
	displayTime = displayTime + dt
end

-- Called from love.draw()
function DesertExample.draw()

	-- Set sprite batches if they are different than the settings.
	map.useSpriteBatch = global.useBatch

	-- Scale and translate the game screen for map drawing
	local ftx, fty = math.floor(global.tx), math.floor(global.ty)
	love.graphics.push()
	love.graphics.scale(global.scale)
	love.graphics.translate(ftx, fty)
	
	-- Limit the draw range 
	if global.limitDrawing then 
		map:autoDrawRange(ftx, fty, global.scale, -100) 
	else 
		map:autoDrawRange(ftx, fty, global.scale, 50) 
	end
	
	-- Queue our guy to be drawn after the tile he's on and then draw the map.
	local maxDraw = global.benchmark and 20 or 1
	for i=1,maxDraw do 
		map:draw() 
	end
	love.graphics.rectangle("line", map:getDrawRange())
	
	-- Reset the scale and translation.
	love.graphics.pop()
end

return DesertExample