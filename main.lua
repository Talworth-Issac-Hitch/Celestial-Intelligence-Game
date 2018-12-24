-- IMPORTS --
_ = require "moses_min"
WorldPhysics = require "worldPhysics"
SpaceCraft = require "spaceCraft"

-- UTILS --
-- Creates a set, aka a table where the identifiers are keys
-- TODO: Move to a Utils type file.
function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

-- CONSTANTS -- 
VIEWPORT_HEIGHT = 800
VIEWPORT_WIDTH = 1200

-- TODO: Actually use this, to differentiate between playable and screenspace.
PLAYABLE_AREA_HEIGHT = 600
PLAYABLE_AREA_WIDTH = 800

DEBUG = true

-- TODO: Load this from a file / server.	File could either be user made (manually or in an 'admin' interace), or Machine Learning generated.
EnemySpawnTable = {
	{
		interval = 15,
		counter = 10,
		enemyObj = { 
			imagePath = "assets/head.png", 
			aspects = Set{"enemyStatic"}, 
			debug = DEBUG
		}
	},
	{
		interval = 5,
		counter = 5,
		enemyObj = {
			imagePath = "assets/comet-spark.png",
			imageRotationOffset = -math.pi / 4,
			aspects = Set{"enemyLinear", "circular"}, 
			debug = DEBUG
		}
	},
	{
		interval = 15,
		counter = 5,
		enemyObj = {
			imagePath = "assets/evil-moon.png",
			aspects = Set{"circular", "enemyStatic"}, 
			debug = DEBUG
		}
	},
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
		worldWidth = VIEWPORT_WIDTH,
		worldHeight = VIEWPORT_HEIGHT,
		debug = DEBUG
	}

	activeCrafts = {
		playerCraft = SpaceCraft:new { 
			xPosition = 50, 
			yPosition = 50, 
			age = 2, 
			aspects = Set{"player"}, 
			world = worldPhysics:getWorld(),
			debug = DEBUG
		}
	}

	score = 0

	seed = os.time()
	love.math.setRandomSeed(seed)
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
				-- New enemies are randomly places in valid bounds in the world
				xPosition = love.math.random(50, VIEWPORT_WIDTH - 50), 
				yPosition = love.math.random(50, VIEWPORT_HEIGHT - 50),
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
	love.graphics.print("Game Seed : " .. seed .. "\nScore : " .. math.ceil(score), VIEWPORT_WIDTH / 2, 50)
end

-- TODO : Make an enemy that reacts to your key presses :3
function love.keypressed(key)
	_.each(activeCrafts, function(craft)
		if _.has(craft, "onKeyPressed") then
			craft:onKeyPressed(key)
		end
	end)
end

function love.keyreleased(key)
	_.each(activeCrafts, function(craft)
		if _.has(craft, "onKeyReleased") then
			craft:onKeyReleased(key)
		end
	end)
end