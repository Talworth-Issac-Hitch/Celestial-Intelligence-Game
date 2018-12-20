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
-- TODO: Load this from a file / server.  File could either be user made (manually or in an 'admin' interace), or Machine Learning generated.
EnemySpawnTable = {
	{
		interval = 15,
		counter = 10,
		enemyObj = { -- TODO: Create more simple constructor for enemies.  Aspects only?
			imagePath = "assets/head.png", 
			sizeX = 100, 
			sizeY = 100, 
			xVelocity = 0, 
			yVelocity = 0, 
			speed = 0, 
			aspects = "enemyStatic", 
			debug = DEBUG
		}
	},
	{
		interval = 7,
		counter = 5,
		enemyObj = { -- TODO: Create more simple constructor for enemies.  Aspects only?
			sizeX = 25, 
			sizeY = 25, 
			aspects = "enemyLinear", 
			debug = DEBUG
		}
	}
}

-- TODO: Add Amps to the interval table.
-- TODO: Create multiple types of Amps.
-- TODO: Make Amps configurable.
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

	-- Update our Amp counter, and apply a global hazard effect if it is time.
	AMP_COUNTER = AMP_COUNTER + dt

	if AMP_COUNTER > AMP_INTERVAL then
		-- The 'Amp' currently spawns a burst of all types of enemies.
		-- TODO: Make more ways the game can 'AMP'
		_.each(EnemySpawnTable, function(spawnParameters)
			spawnParameters.counter = spawnParameters.counter + 25
		end)

		AMP_COUNTER = AMP_COUNTER - AMP_INTERVAL
	end 

		-- Update each spawn interval, spawning an enemy if it's time
	_.each(EnemySpawnTable, function(spawnParameters)
		spawnParameters.counter = spawnParameters.counter + dt

		if spawnParameters.counter > spawnParameters.interval then
			local newEnemyInstanceParameters = {
				xPosition = math.random(50, VIEWPORT_WIDTH - 50), 
				yPosition = math.random(50, VIEWPORT_HEIGHT - 50),
				world = worldPhysics:getWorld()
			}

			newEnemyInstanceParameters = _.extend(newEnemyInstanceParameters, spawnParameters.enemyObj)

			table.insert(activeCrafts, SpaceCraft:new(newEnemyInstanceParameters) )

			spawnParameters.counter = spawnParameters.counter - spawnParameters.interval
		end
	end)

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
	-- TODO: Refactor key handlders into player spaceCraft
	-- TODO: Make Debug View toggable at a key press
	-- User input affeccting new physics
	local xVelocity, yVelocity = activeCrafts.playerCraft.body:getLinearVelocity()
	
	if key == 'up' or key == 'w' then
		yVelocity = -activeCrafts.playerCraft.speed
	elseif key == 'down' or key == 's' then
		yVelocity = activeCrafts.playerCraft.speed
	elseif key == 'right' or key == 'd' then
		xVelocity = activeCrafts.playerCraft.speed
	elseif key == 'left' or key == 'a' then
		xVelocity = -activeCrafts.playerCraft.speed
	end

	activeCrafts.playerCraft.body:setLinearVelocity(xVelocity, yVelocity)
end

function love.keyreleased(key)
	-- TODO: Refactor key handlders into player spaceCraft
	-- User input affeccting playerCraft's movements
	local xVelocity, yVelocity = activeCrafts.playerCraft.body:getLinearVelocity()

	if key == 'up' or key == 'w' then
		if love.keyboard.isDown('down') then
			yVelocity = activeCrafts.playerCraft.speed
		else 
			yVelocity = 0
		end
	elseif key == 'down' or key == 's' then
		if love.keyboard.isDown('up') then
			yVelocity = -activeCrafts.playerCraft.speed
		else 
			yVelocity = 0
		end
	elseif key == 'right' or key == 'd' then
		if love.keyboard.isDown('left') then
			xVelocity = -activeCrafts.playerCraft.speed
		else 
			xVelocity = 0
		end
	elseif key == 'left' or key == 'a' then
		if love.keyboard.isDown('right') then
			xVelocity = activeCrafts.playerCraft.speed
		else 
			xVelocity = 0
		end
	end

	activeCrafts.playerCraft.body:setLinearVelocity(xVelocity, yVelocity)
end