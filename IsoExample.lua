
-- Setup
local loader = require("AdvTiledLoader/loader")
loader.path = "maps/"
local map = loader.load("isometric.tmx")
local layer = map.tl.Ground

-- The guy we're going to be moving around
local Guy = {
	tileX = 1,				-- The horizontal tile
	tileY = 1,				-- The vertical tile
	facing = "downleft",	-- The direction our guy is facing
	quads = {				-- The frames of the image
		down = 		love.graphics.newQuad(0,0,32,64,256,64),
		downright = love.graphics.newQuad(32,0,32,64,256,64),
		right = 	love.graphics.newQuad(64,0,32,64,256,64),
		upright = 	love.graphics.newQuad(96,0,32,64,256,64),
		up = 		love.graphics.newQuad(128,0,32,64,256,64),
		upleft = 	love.graphics.newQuad(160,0,32,64,256,64),
		left = 		love.graphics.newQuad(192,0,32,64,256,64),
		downleft = 	love.graphics.newQuad(224,0,32,64,256,64),
	},
	-- The image
	image = love.graphics.newImage("images/guy.png"),
}


-- Move the guy to the relative location
function Guy.move(x,y)
	-- Change the facing direction
	if x > 0 then Guy.facing = "downright"
	elseif x < 0 then Guy.facing = "upleft"
	elseif y > 0 then Guy.facing = "downleft"
	else Guy.facing = "upright" end
	-- Grab the tile
	local tile = layer.tileData(Guy.tileX+x, Guy.tileY+y)
	-- If the tile doesn't exist or is an obstacle then exit the function
	if tile == nil then return end
	if tile.properties.obstacle then return end
	-- Otherwise change the guy's tile
	Guy.tileX = Guy.tileX + x
	Guy.tileY = Guy.tileY + y
end

-- Draw our guy. This function is passed to TileSet.drawAfterTile() which calls it passing the
-- x and y value of the bottom left corner of the tile.
function Guy.draw(x,y)
	love.graphics.drawq(Guy.image, Guy.quads[Guy.facing], x+15, y-80)
end

-- Our example class
local IsoExample = {}

-- Called from love.keypressed()
function IsoExample.keypressed(k)
	if k == 'w' then Guy.move(0,-1) end
	if k == 'a' then Guy.move(-1,0) end
 	if k == 's' then Guy.move(0,1) end
	if k == 'd' then Guy.move(1,0) end
end

-- Resets the example
function IsoExample.reset()
	global.tx = -840
	global.ty = 280
	Guy.tileX = 1
	Guy.tileY = 1
	Guy.facing = "downleft"
	displayTime = 0
end

-- Update the display time for the character control instructions
function IsoExample.update(dt)
	displayTime = displayTime + dt
end

-- Called from love.draw()
function IsoExample.draw()

	-- Set sprite batches
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
		if layer.map.useSpriteBatch then
			layer:clearAfterTile()
		else
			layer:drawAfterTile(Guy.tileX, Guy.tileY, Guy.draw)
		end
		map:draw() 
	end
	love.graphics.rectangle("line", map:getDrawRange())
	
	-- Reset the scale and translation.
	love.graphics.pop()
	
end

return IsoExample