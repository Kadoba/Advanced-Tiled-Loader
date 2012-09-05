
-- Some global stuff that the examples use.
global = {}
global.limitDrawing = false		-- If true then the drawing range example is shown
global.benchmark = false		-- If true the map is drawn 20 times instead of 1
global.useBatch = false			-- If true then the layers are rendered with sprite batches
global.tx = 0					-- X translation of the screen
global.ty = 0					-- Y translation of the screen
global.scale = 1				-- Scale of the screen

---------------------------------------------------------------------------------------------------
-- Load the examples
local example = {require("DesertExample"), require("IsoExample"),  
				 require("PerspExample"), require("SewerExample")}
				  
local num = 1					-- The map we're currently on
local fps = 0					-- Frames Per Second
local fpsCount = 0				-- FPS count of the current second
local fpsTime = 0				-- Keeps track of the elapsed time

---------------------------------------------------------------------------------------------------
-- Reset the current example
if example[num].reset then example[num].reset() end

---------------------------------------------------------------------------------------------------
-- Scroll in and out
function love.mousepressed( x, y, mb )
	if mb == "wu" then
		global.scale = global.scale + 0.1
	end

	if mb == "wd" then
		global.scale = global.scale - 0.1
	end
end

---------------------------------------------------------------------------------------------------
function love.update(dt)
	-- Move the camera
	if love.keyboard.isDown("up") then global.ty = global.ty + 250*dt end
	if love.keyboard.isDown("down") then global.ty = global.ty - 250*dt end
	if love.keyboard.isDown("left") then global.tx = global.tx + 250*dt end
	if love.keyboard.isDown("right") then global.tx = global.tx - 250*dt end
	
	-- Count the frames per second
	fpsCount = fpsCount+1
	fpsTime = fpsTime + dt
	if fpsTime >= 1 then
		fps = fpsCount
		fpsTime = 0
		fpsCount = 0
	end
	
	-- Call update in our example if it is defined
	if example[num].update then example[num].update(dt) end
end

---------------------------------------------------------------------------------------------------
function love.keypressed(k)
	-- quit
    if k == 'escape' then
        (love.event.push or love.event.quit)('q')
    end
	
	-- previous map
	if k == 'z' then
		num =  num <= 1 and #example or num - 1
		if example[num].reset then example[num].reset() end
	end
	
	-- next map
	if k == 'x' then
		num = num >= #example and 1 or num + 1
		if example[num].reset then example[num].reset() end
	end
	
	-- limit drawing
	if k == 'c' then
		if global.limitDrawing then global.limitDrawing = false else global.limitDrawing = true end
	end
	
	-- benchmark
	if k == 'v' then
		if global.benchmark then global.benchmark = false else global.benchmark = true end
	end
	
	-- use sprite batches
	if k == 'b' then
		if global.useBatch then global.useBatch = false else global.useBatch = true end
	end
	
	-- Call keypressed in our example if it is defined
	if example[num].keypressed then example[num].keypressed(k) end
end

---------------------------------------------------------------------------------------------------
function love.draw()
	
	-- Draw our example
	example[num].draw()
	
	-- Insert display text into tables
	instructions = {"Arrow Keys - Move", "Mouse Wheel - Zoom", "Z and X - Change Map", 
					"C - Toggle Limit Drawing", "V - Toggle Benchmark", "B - Toggle Batches",
					"WSAD - Move Character"}
	information = {string.format("(%d,%d)", -global.tx, -global.ty), 
					"Scale: " .. global.scale, string.format("Map %d of %d", num, #example), 
					global.limitDrawing and "Limiting drawing" or "Drawing entire screen",
				    string.format("Drawing %d time(s). FPS: %d", global.benchmark and 20 or 1, fps), 
					global.useBatch and "Using SpriteBatches" or "Not Using SpriteBatches"}
	
	-- Draw a box so we can see the text easier
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill",0,0,350, #instructions*20)
	love.graphics.setColor(255,255,255,255)
	
	-- print display text
	for i=1,#instructions do
		love.graphics.print(instructions[i], 0, (i-1)*20)
	end
	for i=1,#information do
		love.graphics.print(information[i], 160, (i-1)*20)
	end

end