-- IMPORTS --
_ = require "moses_min"
WorldPhysics = require "worldPhysics"
SpaceCraft = require "spaceCraft"

-- CONSTANTS -- 
VIEWPORT_HEIGHT = 800
VIEWPORT_WIDTH = 1200

-- TODO: Actually use this, to differentiate between playable and screenspace.
PLAYABLE_AREA_HEIGHT = 600
PLAYABLE_AREA_WIDTH = 800

DEBUG = true

-- LOVE CALLBACKS -- 

function love.load()
	-- Set background to blue
	love.window.setMode(VIEWPORT_WIDTH, VIEWPORT_HEIGHT)

	worldPhysics = WorldPhysics:new {
		worldWidth=VIEWPORT_WIDTH,
		worldHeight=VIEWPORT_HEIGHT,
		debug=DEBUG
	}

	-- TODO : Convert to physics objects
	activeCrafts = {
		playerCraft = SpaceCraft:new {
			imagePath ="assets/pig.png", 
			sizeX = 100, 
			sizeY = 100, 
			xPosition = 75, 
			yPosition = 75,
			xVelocity = 10, 
			yVelocity = 0, 
			speed = 400, 
			age = 2, 
			aspects = "player", 
			world = worldPhysics:getWorld(),
			debug = DEBUG
		}
	}

	score = 0
end


function love.update(dt)
	worldPhysics:update(dt)

	_.each(activeCrafts, function(craft)
		craft:update(dt)
	end)

	-- Spawn an enemy every second on the second
	if(math.floor(score) < math.floor(score + dt)) then
		table.insert(activeCrafts, SpaceCraft:new {
			imagePath = "assets/head.png", 
			sizeX = 100, 
			sizeY = 100, 
			xPosition = math.random(50, VIEWPORT_WIDTH - 50), 
			yPosition = math.random(50, VIEWPORT_HEIGHT - 50),
			xVelocity = 0, 
			yVelocity = 0, 
			speed = 0, 
			aspects = "enemy", 
			world = worldPhysics:getWorld(), 
			debug = DEBUG
		})
	end

	score = score + dt
end

function love.draw()
	worldPhysics:draw()

	-- Draw our custom spacecraft objects
	_.each(activeCrafts, function(craft)
		craft:draw()
	end)

	-- Draw the score
	love.graphics.print("Score : " .. math.ceil(score), VIEWPORT_WIDTH / 2, 50)
end

function love.keypressed(key)
	-- TODO: Refactor in player spaceCraft
	-- TODO: Make Debug View toggable at a key press
	-- User input affeccting new physics
	local xVelocity, yVelocity = activeCrafts.playerCraft.body:getLinearVelocity()
	
	if key == 'up' then
		yVelocity = -activeCrafts.playerCraft.speed
	elseif key == 'down' then
		yVelocity = activeCrafts.playerCraft.speed
	elseif key == 'right' then
		xVelocity = activeCrafts.playerCraft.speed
	elseif key == 'left' then
		xVelocity = -activeCrafts.playerCraft.speed
	end

	activeCrafts.playerCraft.body:setLinearVelocity(xVelocity, yVelocity)
end

function love.keyreleased(key)
	-- User input affeccting playerCraft's movements
	local xVelocity, yVelocity = activeCrafts.playerCraft.body:getLinearVelocity()

	if key == 'up' then
		if love.keyboard.isDown('down') then
			yVelocity = activeCrafts.playerCraft.speed
		else 
			yVelocity = 0
		end
	elseif key == 'down' then
		if love.keyboard.isDown('up') then
			yVelocity = -activeCrafts.playerCraft.speed
		else 
			yVelocity = 0
		end
	elseif key == 'right' then
		if love.keyboard.isDown('left') then
			xVelocity = -activeCrafts.playerCraft.speed
		else 
			xVelocity = 0
		end
	elseif key == 'left' then
		if love.keyboard.isDown('right') then
			xVelocity = activeCrafts.playerCraft.speed
		else 
			xVelocity = 0
		end
	end

	activeCrafts.playerCraft.body:setLinearVelocity(xVelocity, yVelocity)
end