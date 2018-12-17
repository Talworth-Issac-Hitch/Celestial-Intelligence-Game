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

-- TODO: Probably make these into tables
SPAWN_INTERVAL_ENEMY_1 = 15
SPAWN_INTERVAL_ENEMY_2 = 7

SPAWN_COUNTER_ENEMY_1 = 10
SPAWN_COUNTER_ENEMY_2 = 5

AMP_INTERVAL = 30

AMP_COUNTER = 0

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
			sizeX = 50, 
			sizeY = 50, 
			xPosition = 50, 
			yPosition = 50,
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

	SPAWN_COUNTER_ENEMY_1 = SPAWN_COUNTER_ENEMY_1 + dt
	SPAWN_COUNTER_ENEMY_2 = SPAWN_COUNTER_ENEMY_2 + dt
	AMP_COUNTER = AMP_COUNTER + dt

	if AMP_COUNTER > AMP_INTERVAL then
		-- TODO: Make more ways the game can 'AMP'
		SPAWN_COUNTER_ENEMY_1 = SPAWN_COUNTER_ENEMY_1 + 25
		SPAWN_COUNTER_ENEMY_2 = SPAWN_COUNTER_ENEMY_2 + 25
		AMP_COUNTER = AMP_COUNTER - AMP_INTERVAL
	end 

	-- Spawn an enemy every second on the second
	if SPAWN_COUNTER_ENEMY_1 > SPAWN_INTERVAL_ENEMY_1 then
		table.insert(activeCrafts, SpaceCraft:new {
			imagePath = "assets/head.png", 
			sizeX = 100, 
			sizeY = 100, 
			xPosition = math.random(50, VIEWPORT_WIDTH - 50), 
			yPosition = math.random(50, VIEWPORT_HEIGHT - 50),
			xVelocity = 0, 
			yVelocity = 0, 
			speed = 0, 
			aspects = "enemyStatic", 
			world = worldPhysics:getWorld(), 
			debug = DEBUG
		})

		SPAWN_COUNTER_ENEMY_1 = SPAWN_COUNTER_ENEMY_1 - SPAWN_INTERVAL_ENEMY_1
	end 

	if SPAWN_COUNTER_ENEMY_2 > SPAWN_INTERVAL_ENEMY_2 then
		table.insert(activeCrafts, SpaceCraft:new {
			sizeX = 25, 
			sizeY = 25, 
			xPosition = math.random(50, VIEWPORT_WIDTH - 50), 
			yPosition = math.random(50, VIEWPORT_HEIGHT - 50),
			aspects = "enemyLinear", 
			world = worldPhysics:getWorld(), 
			debug = DEBUG
		})

		SPAWN_COUNTER_ENEMY_2 = SPAWN_COUNTER_ENEMY_2 - SPAWN_INTERVAL_ENEMY_2
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