-- IMPORTS --
_ = require "moses_min"
SpaceCraft = require "spaceCraft"


-- LOVE CALLBACKS -- 

function love.load()
	activeCrafts = {
		playerCraft = SpaceCraft:new {
			imagePath="assets/pig.png", sizeX=100, sizeY=100, xPosition=0, yPosition=100,
			xVelocity=10, yVelocity=0, speed=100
		},
		SpaceCraft:new {
			imagePath="assets/head.png", sizeX=100, sizeY=100, xPosition=300, yPosition=300,
			xVelocity=0, yVelocity=0, speed=0
		}
	}

	score = 0
end

function love.update(dt)
	_.each(activeCrafts, function(craft)
		craft:update(dt)
	end)

	-- collision detection all enemies against the play craft
	_.eachi(activeCrafts, function(enemyCraft)
		if CheckCollision(activeCrafts.playerCraft.xPosition, activeCrafts.playerCraft.yPosition, activeCrafts.playerCraft.sizeX, activeCrafts.playerCraft.sizeY, 
			enemyCraft.xPosition, enemyCraft.yPosition, enemyCraft.sizeX, enemyCraft.sizeY) then
			
			love.event.quit( )
		end 
	end)

	-- Spawn an enemy every second on the second
	if(math.floor(score) < math.floor(score + dt)) then
		table.insert(activeCrafts, SpaceCraft:new {
			imagePath="assets/head.png", sizeX=100, sizeY=100, xPosition=score*50 + 100, yPosition=score*50,
			xVelocity=0, yVelocity=0, speed=0
		})
	end

	score = score + dt
end

function love.draw()
	_.each(activeCrafts, function(craft)
		craft:draw()
	end)
end

function love.mousepressed(x, y, button, istouch)
	activeCrafts.playerCraft.xPosition = x
	activeCrafts.playerCraft.yPosition = y
end

function love.mousereleased(x, y, button, istouch)
	playerCraft.xPosition = x
	playerCraft.yPosition = y
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