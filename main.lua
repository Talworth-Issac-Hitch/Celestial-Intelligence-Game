-- IMPORTS --
_ = require "moses_min"
SpaceCraft = require "spaceCraft"


-- CONSTANTS -- 
-- TODO: Actually set window size using these same constants
VIEWPORT_HEIGHT = 600
VIEWPORT_WIDTH = 800

-- LOVE CALLBACKS -- 

function love.load()
	activeCrafts = {
		playerCraft = SpaceCraft:new {
			imagePath="assets/pig.png", sizeX=100, sizeY=100, xPosition=0, yPosition=100,
			xVelocity=10, yVelocity=0, speed=100, age=2
		}
	}

	score = 0
end

function love.update(dt)
	_.each(activeCrafts, function(craft)
		craft:update(dt, {height=VIEWPORT_HEIGHT, width=VIEWPORT_WIDTH})
	end)

	-- collision detection all enemies against the play craft
	_.eachi(activeCrafts, function(enemyCraft)
		if enemyCraft.age > 2 and CheckCollision(activeCrafts.playerCraft.xPosition, activeCrafts.playerCraft.yPosition, activeCrafts.playerCraft.sizeX, activeCrafts.playerCraft.sizeY, 
			enemyCraft.xPosition, enemyCraft.yPosition, enemyCraft.sizeX, enemyCraft.sizeY) then
			
			love.event.quit( )
		end 
	end)

	-- Spawn an enemy every second on the second
	if(math.floor(score) < math.floor(score + dt)) then
		table.insert(activeCrafts, SpaceCraft:new {
			imagePath="assets/head.png", sizeX=100, sizeY=100, xPosition=math.random(0,VIEWPORT_WIDTH), yPosition=math.random(0,VIEWPORT_HEIGHT),
			xVelocity=0, yVelocity=0, speed=0
		})
	end

	score = score + dt
end

function love.draw()
	-- Draw the objects
	_.each(activeCrafts, function(craft)
		craft:draw()
	end)

	-- Draw the score
	love.graphics.print("Score : " .. math.ceil(score), 400, 50)
end

function love.mousepressed(x, y, button, istouch)
	activeCrafts.playerCraft.xPosition = x
	activeCrafts.playerCraft.yPosition = y
end

function love.mousereleased(x, y, button, istouch)
	activeCrafts.playerCraft.xPosition = x
	activeCrafts.playerCraft.yPosition = y
end

function love.keypressed(key)
	if key == 'up' then
		activeCrafts.playerCraft.yVelocity = -activeCrafts.playerCraft.speed
	elseif key == 'down' then
		activeCrafts.playerCraft.yVelocity = activeCrafts.playerCraft.speed
	elseif key == 'right' then
		activeCrafts.playerCraft.xVelocity = activeCrafts.playerCraft.speed
	elseif key == 'left' then
		activeCrafts.playerCraft.xVelocity = -activeCrafts.playerCraft.speed
	end
end

function love.keyreleased(key)
	if key == 'up' then
		activeCrafts.playerCraft.yVelocity = 0
	elseif key == 'down' then
		activeCrafts.playerCraft.yVelocity = 0
	elseif key == 'right' then
		activeCrafts.playerCraft.xVelocity = 0
	elseif key == 'left' then
		activeCrafts.playerCraft.xVelocity = 0
	end
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end