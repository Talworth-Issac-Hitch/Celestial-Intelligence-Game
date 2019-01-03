-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"
WorldPhysics = require "worldPhysics"
GameOver = require "gameOver"

SpaceCraft = require "spaceCraft"

-----------
-- UTILS --
-----------
-- TODO: Move global Utils to their own file.

-- Creates a set, aka a table where the identifiers are keys
function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

function getDirectionInRadiansFromVector(vectorXComponet, vectorYComponent)
	return math.atan2(vectorYComponent, vectorXComponet)
end

---------------
-- CONSTANTS --
--------------- 
VIEWPORT_HEIGHT = 800
VIEWPORT_WIDTH = 1200

-- TODO: Actually use this, to differentiate between playable and screenspace.
PLAYABLE_AREA_HEIGHT = 600
PLAYABLE_AREA_WIDTH = 800


-------------
-- GLOBALS --
-------------

isGameOver = false

Debug = {
	physicsVisual = false,
	physicsLog = false
}

-- TODO: Load this from a file / server.	File could either be user made (manually or in an 'admin' interace), or Machine Learning generated.
-- A Table defining when and how often enemies space, how many times they spawn, as well as enemy attributes.
EnemySpawnTable = {
	{ -- Slot 1, The Base Layer: spawns quickly but with a low limit.  Forms the initial challenge / interaction with the player 
		spawnInterval = 5,
		spawnCounter = 5,
		currentEnemyCount = 0,
		spawnLimit = 7,
		enemyObj = {
			name = "Comet",
			imagePath = "assets/comet-spark.png",
			imageRotationOffset = -math.pi / 4,
			aspects = Set{"enemyLinear", "faceMotion", "circular", "deadly"}, 
			debug = Debug
		}
	},
	{ -- Slot 2, The Consistent Threat: spawns slowly, but with a high limit
		spawnInterval = 12,
		spawnCounter = -2,
		currentEnemyCount = 0,
		spawnLimit = 25,
		-- [[ Mad Moons 
		enemyObj = {
			name = "Mad Moon",
			imagePath = "assets/evil-moon.png",
			aspects = Set{"circular", "enemyStatic"}, 
			debug = Debug
		} --]]

	},
	{ -- Slot 3, The Wrench: After a long wait and the first amp, spawns quickly
		spawnInterval = 3,
		spawnCounter = -60,
		currentEnemyCount = 0,
		spawnLimit = 10,
		-- [[ Mimes 
		enemyObj = {
			name = "Mime",
			imagePath = "assets/mime.png",
			aspects = Set{"circular", "playerInputMotion", "playerOnlyCollision", "deadly"}, 
			debug = Debug
		} --]]
		--[[ Gamma Ray
		enemyObj = {
			name = "Gamma Ray",
			imagePath = "assets/lightning-frequency.png",
			imageRotationOffset = -math.pi / 4,
			aspects = Set{"enemyLinear", "faceMotion", "playerOnlyCollision", "circular", "deadly"}, 
			debug = Debug
		} --]]
		--[[ Stun-Nado
		enemyObj = {
			name = "Stun-Nado",
			imagePath = "assets/wind-hole.png",
			angularVelocity = -5,
			aspects = Set{"enemyLinear", "faceAngle", "noEnemyCollision", "circular", "stun"}, 
			debug = Debug
		} --]]
	},
	{ -- Slot 4, Ragnarok: If the player isn't dead yet, reward them with swift death
		spawnInterval = 2,
		spawnCounter = -120,
		currentEnemyCount = 0,
		spawnLimit = 100,
		enemyObj = { 
			name = "Thwomp",
			imagePath = "assets/head.png", 
			aspects = Set{"enemyStatic", "faceAngle", "deadly"}, 
			debug = Debug
		}
	},
}

-- TODO: Add Amps to the interval table.
-- TODO: Create multiple types of Amps.
-- TODO: Make Amps configurable.
-- Variables for 'Amps' or periodic added challenges / difficulty spikes to keep things interesting.
AMP_INTERVAL = 30
AMP_COUNTER = 0

----------------------
-- LOVE2D CALLBACKS --
----------------------

-- The Love2D callback for when the game initially loads.  Here we initialize our game variables.
function love.load()
	-- Set the Window size.
	love.window.setMode(VIEWPORT_WIDTH, VIEWPORT_HEIGHT)

	-- Initialize our physics
	worldPhysics = WorldPhysics:new {
		worldWidth = VIEWPORT_WIDTH,
		worldHeight = VIEWPORT_HEIGHT,
		debug = Debug
	}

	-- Create our player
	activeCrafts = {
		playerCraft = SpaceCraft:new { 
			xPosition = 50, 
			yPosition = 50, 
			age = 2, 
			aspects = Set{"player", "faceAngle"}, 
			world = worldPhysics:getWorld(),
			debug = Debug
		}
	}

	score = 0

	-- Get and set our random seed.  This can be used to re-create an exact session.
	local seed = os.time()
	print("Session initialized with game seed: " .. seed)
	love.math.setRandomSeed(seed)

	-- NOTE: DEBUG
	gameOver = GameOver:new {
		worldWidth = VIEWPORT_WIDTH,
		worldHeight = VIEWPORT_HEIGHT,
		gameSeed = seed
	}
end

-- The Love2D callback for time passing in the game.  Most game components have their individual implementations for
-- that callback, which we blindly call here.  Additional we manage some global counters.
-- @param dt The time interval since the last time love.update was called.
function love.update(dt)
	if not isGameOver then
		worldPhysics:update(dt)

		_.each(activeCrafts, function(craft)
			craft:update(dt)
		end)

		-- TODO: Break the following counters and logic into a general "gameLogic" module.
		-- Update our Amp counter, and apply a global hazard effect if it is time.
		AMP_COUNTER = AMP_COUNTER + dt

		if AMP_COUNTER > AMP_INTERVAL then
			-- The 'Amp' currently spawns a burst of all types of enemies.
			-- TODO: Make more ways the game can 'AMP'
			_.each(EnemySpawnTable, function(spawnParameters)
				spawnParameters.spawnCounter = spawnParameters.spawnCounter + 25
			end)

			AMP_COUNTER = AMP_COUNTER - AMP_INTERVAL
		end 

		-- Update each spawn interval, spawning an enemy if it's time
		_.each(EnemySpawnTable, function(spawnParameters)
			-- TOOD: May need tweaking when enemies can die..
			if spawnParameters.currentEnemyCount < spawnParameters.spawnLimit then
				spawnParameters.spawnCounter = spawnParameters.spawnCounter + dt

				if spawnParameters.spawnCounter > spawnParameters.spawnInterval then
					local newEnemyInstanceParameters = {
						-- New enemies are randomly places in valid bounds in the world
						xPosition = love.math.random(50, VIEWPORT_WIDTH - 50), 
						yPosition = love.math.random(50, VIEWPORT_HEIGHT - 50),
						world = worldPhysics:getWorld()
					}

					newEnemyInstanceParameters = _.extend(newEnemyInstanceParameters, spawnParameters.enemyObj)

					table.insert(activeCrafts, SpaceCraft:new(newEnemyInstanceParameters) )

					spawnParameters.currentEnemyCount = spawnParameters.currentEnemyCount + 1
					spawnParameters.spawnCounter = spawnParameters.spawnCounter - spawnParameters.spawnInterval
				end
			end
		end)

		-- Finally increment the score, which currently is just equal to time. 
		score = score + dt
	end
end

-- Love2D callback for graphics drawing.  Most game components have their individual implementations for that callback,
-- which we blindly call here.
function love.draw()
	if isGameOver then 
		gameOver:draw()
	else
		worldPhysics:draw()

		-- Draw our custom spacecraft objects
		_.each(activeCrafts, function(craft)
			craft:draw()
		end)

		-- Draw the score
		love.graphics.print("Score : " .. math.ceil(score), VIEWPORT_WIDTH / 2, 50)
	end
end

-- Love2D callback for when the player presses a key.  Some game components have their individual implementations for that callback,
-- so if one exists, we call it here.
function love.keypressed(key)
	-- Toggle Debug View
		if key == 'o' then
			print(Debug.physicsVisual)
			Debug.physicsVisual = not Debug.physicsVisual
		elseif key == 'l' then
			Debug.physicsLog = not Debug.physicsLog
		end

	-- Call any keypresses that the 
	_.each(activeCrafts, function(craft)
		if _.has(craft, "onKeyPressed") then
			craft:onKeyPressed(key)
		end
	end)
end

-- Love2D callback for when the player releases a key.  Some game components have their individual implementations for that callback,
-- so if one exists, we call it here.
function love.keyreleased(key)
	if isGameOver then 
		gameOver:onKeyReleased(key)
	else
		_.each(activeCrafts, function(craft)
			if _.has(craft, "onKeyReleased") then
				craft:onKeyReleased(key)
			end
		end)
	end
end


-------------------
-- CUSTOM EVENTS -- 
-------------------

-- A custom event that occurs when the player dies.
function love.handlers.playerDied(killedBy)
	print("Player killed by: " .. killedBy)
	print(score)
	-- TODO : Print out what enemy killed the player.
	isGameOver = true
	gameOver:setScore(math.ceil(score))
end