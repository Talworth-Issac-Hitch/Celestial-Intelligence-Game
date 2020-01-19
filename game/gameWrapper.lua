-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"

-- Game Components
GameInitialization = require "game/initialization"
WorldPhysics = require "physics/worldPhysics"
GameOver = require "game/gameOver"

SpaceCraft = require "spacecraft/spaceCraft"

----------------------
-- CLASS DEFINITION -- 
----------------------

-- A top-level wrapper for the game and all game-logic  
Game = {}
Game.__index = Game

---------------
-- CONSTANTS --
--------------- 

-- Constructor.  Builds a new Game.
-- @param {Table} options A table containing basic window information.
function Game:new(options)
	local game = {
		worldWidth = 800,
		worldHeight = 600,
		time = 0,
		gameSeed = 0,
		gameState = GAME_ON,
		score = 0,
		playerConfig = {},
		activeCrafts = {},
		worldPhysics = {},
		enemySpawnTable = {},
		gameOver = {},
		gameOverTime = 0,
		ampCounter = {
			-- TODO: Add Amps to the interval table.
			-- TODO: Create multiple types of Amps.
			-- TODO: Make Amps configurable.
			-- Variables for 'Amps' or periodic added challenges / difficulty spikes to keep things interesting.
			interval = 60,
			count = 0
		},
		debug = {
			physicsVisual = false,
			physicsLog = false
		}
	}

	setmetatable(game, Game)

	game = _.extend(game, options)

		-- General game initialization
	local gameInitialization = GameInitialization:new {
		debug = game.debug
	}

	-- A Table defining when and how often enemies space, how many times they spawn, as well as enemy attributes.
	game.playerConfig = gameInitialization:loadPlayerData()
	game.enemySpawnTable = gameInitialization:loadEnemyTable()

	-- Initialize our physics
	game.worldPhysics = WorldPhysics:new {
		worldWidth = game.worldWidth,
		worldHeight = game.worldHeight,
		debug = game.debug
	}

	-- Create our player
	game.activeCrafts = {
		playerCraft = SpaceCraft:new { 
			xPosition = 50, 
			yPosition = 50, 
			age = 2, 
			aspects = Set{"player"}, 
			craftColor = {1, 1, 1},
			world = game.worldPhysics,
			debug = game.debug
		}
	}

	-- NOTE: DEBUG
	game.gameOver = GameOver:new {
		worldWidth = game.worldWidth,
		worldHeight = game.worldHeight,
		playerConfig = game.playerConfig,
		enemySpawnTable = game.enemySpawnTable,
		gameSeed = game.gameSeed
	}

	return game
end 

-- The Love2D callback for time passing in the game.
-- @param dt - The time interval since the last time love.update was called.
-- @param gameState - The current game state.  Should be either GameOn or GameOver 
function Game:update(dt)
	if self.gameState == GAME_OVER then
		self.gameOverTime = self.gameOverTime + dt
	else
		self.worldPhysics:update(dt)

		_.each(self.activeCrafts, function(craft)
			craft:update(dt)
		end)

		-- Update our Amp counter, and apply a global hazard effect if it is time.
		self.ampCounter.count = self.ampCounter.count + dt

		if self.ampCounter.count > self.ampCounter.interval then
			-- The 'Amp' currently spawns a burst of all types of enemies.
			-- TODO: Make more ways the game can 'AMP'
			_.each(self.enemySpawnTable, function(spawnParameters)
				spawnParameters.spawnCounter = spawnParameters.spawnCounter + 25
			end)

			self.ampCounter.count = self.ampCounter.count - self.ampCounter.interval
		end 

		local SPAWN_BUFFER_DISTANCE = 50

		-- Update each spawn interval, spawning an enemy if it's time
		_.each(self.enemySpawnTable, function(spawnParameters)
			-- TOOD: May need tweaking when enemies can die..
			if spawnParameters.currentEnemyCount < spawnParameters.spawnLimit then
				spawnParameters.spawnCounter = spawnParameters.spawnCounter + dt

				if spawnParameters.spawnCounter > spawnParameters.spawnInterval then
					local newEnemyInstanceParameters = {
						-- New enemies are randomly places in valid bounds in the world
						xPosition = love.math.random(SPAWN_BUFFER_DISTANCE, self.worldWidth - SPAWN_BUFFER_DISTANCE), 
						yPosition = love.math.random(SPAWN_BUFFER_DISTANCE, self.worldHeight - SPAWN_BUFFER_DISTANCE),
						world = self.worldPhysics
					}

					newEnemyInstanceParameters = _.extend(newEnemyInstanceParameters, spawnParameters.enemyObj)

					table.insert(self.activeCrafts, SpaceCraft:new(newEnemyInstanceParameters) )

					spawnParameters.currentEnemyCount = spawnParameters.currentEnemyCount + 1
					spawnParameters.spawnCounter = spawnParameters.spawnCounter - spawnParameters.spawnInterval
				end
			end
		end)

		-- Finally increment the score, which currently is just equal to time. 
		self.score = self.score + dt
	end
end

-- Love2D callback for graphics drawing.  Most game components have their individual implementations for that callback,
-- which we blindly call here.
function Game:draw()
	if self.gameState == GAME_OVER then
		local fadeTime = 2

		if self.gameOverTime < fadeTime then 
			local waxingAlpha = self.gameOverTime / fadeTime
			local waningAlpha = 1 - waxingAlpha

			self.gameOver:draw(self.gameOverTime, waxingAlpha)
			self.worldPhysics:draw(waningAlpha)

			-- Draw our custom spacecraft objects
			_.each(self.activeCrafts, function(craft)
				craft:draw(waningAlpha)
			end)
		else
			self.gameOver:draw(self.gameOverTime)
		end 
	else
		self.worldPhysics:draw()

		-- Draw our custom spacecraft objects
		_.each(self.activeCrafts, function(craft)
			craft:draw()
		end)

		-- Draw the score
		love.graphics.print("Score : " .. math.ceil(self.score), self.worldWidth / 2, 50)
	end
end

-- Love2D callback for when the player presses a key.  Some game components have their individual implementations for that callback,
-- so if one exists, we call it here.
function Game:keypressed(key, scancode, isrepeat, isNonPlayerAction)
		-- Toggle Debug View
		if key == 'o' then
			self.debug.physicsVisual = not self.debug.physicsVisual
		elseif key == 'l' then
			self.debug.physicsLog = not self.debug.physicsLog
		end

		-- Call any keypresses that the player presses
		if self.playerConfig.playerType == 0 or isNonPlayerAction then
			_.each(self.activeCrafts, function(craft)
				if _.has(craft, "onKeyPressed") then
					craft:onKeyPressed(key)
				end
			end)
		end
end

-- Love2D callback for when the player releases a key.  Some game components have their individual implementations for that callback,
-- so if one exists, we call it here.
function Game:keyreleased(key, scancode, isrepeat, isNonPlayerAction)
	if self.gameState == GAME_OVER then
		self.gameOver:onKeyReleased(key)
	else
		if self.playerConfig.playerType == 0 or isNonPlayerAction then
			_.each(self.activeCrafts, function(craft)
				if _.has(craft, "onKeyReleased") then
					craft:onKeyReleased(key)
				end
			end)
		end
	end
end

-- A custom event that occurs when the player dies.
function Game:onPlayerDeath(killedBy)
	print("Player killed by: " .. killedBy)

	self.gameState = GAME_OVER
	self.gameOver:onGameEnd(math.ceil(self.score))
end

-- A handler for when the game (application) ends.
function Game:onQuitHandler()
	-- Only output playData if the game was actually over.
	if self.gameState == GAME_OVER then
		self.gameOver:onQuitHandler()
	end
end

return Game