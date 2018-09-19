-- IMPORTS --
_ = require "moses_min"
SpaceCraft = require "spaceCraft"


-- LOVE CALLBACKS -- 

function love.load()
	playerCraft = SpaceCraft:new {
		imagePath="assets/pig.png", sizeX=100, sizeY=100, xPosition=0, yPosition=100,
		xVelocity=10, yVelocity=0, speed=100
	}

	enemyCraft = SpaceCraft:new {
		imagePath="assets/head.png", sizeX=100, sizeY=100, xPosition=300, yPosition=300,
		xVelocity=0, yVelocity=0, speed=0
	}
end

function love.update(dt)
	playerCraft.xPosition = playerCraft.xPosition + (playerCraft.xVelocity * dt)
	playerCraft.yPosition = playerCraft.yPosition + (playerCraft.yVelocity * dt)

	-- collision detection
	if CheckCollision(playerCraft.xPosition, playerCraft.yPosition, playerCraft.sizeX, playerCraft.sizeY, enemyCraft.xPosition, enemyCraft.yPosition, enemyCraft.sizeX, enemyCraft.sizeY) then
		love.event.quit( )
	end 
end

function love.draw()
	love.graphics.draw(playerCraft.image, playerCraft.xPosition, playerCraft.yPosition, 0, playerCraft.imgSX, playerCraft.imgSY)
	love.graphics.draw(enemyCraft.image, enemyCraft.xPosition, enemyCraft.yPosition, 0, enemyCraft.imgSX, enemyCraft.imgSY)
end

function love.mousepressed(x, y, button, istouch)
	playerCraft.xPosition = x
	playerCraft.yPosition = y
end

function love.mousereleased(x, y, button, istouch)
	playerCraft.xPosition = x
	playerCraft.yPosition = y
end

function love.keypressed(key)
	if key == 'up' then
		playerCraft.yVelocity = -playerCraft.speed
	elseif key == 'down' then
		playerCraft.yVelocity = playerCraft.speed
	elseif key == 'right' then
		playerCraft.xVelocity = playerCraft.speed
	elseif key == 'left' then
		playerCraft.xVelocity = -playerCraft.speed
	end
end

function love.keyreleased(key)
	if key == 'up' then
		playerCraft.yVelocity = 0
	elseif key == 'down' then
		playerCraft.yVelocity = 0
	elseif key == 'right' then
		playerCraft.xVelocity = 0
	elseif key == 'left' then
		playerCraft.xVelocity = 0
	end
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end