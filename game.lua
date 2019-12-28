-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"

-- Game Components
GameInitialization = require "initialization"
WorldPhysics = require "worldPhysics"
GameOver = require "gameOver"

SpaceCraft = require "spaceCraft"

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
	local mainMenu = {
		worldWidth = 800,
		worldHeight = 600,
		time = 0,
		gameSeed = 0
	}

	setmetatable(mainMenu, MainMenu)

	mainMenu = _.extend(mainMenu, options)

		-- General game initialization
	gameInitialization = GameInitialization:new {
		debug = Debug
	}

	-- A Table defining when and how often enemies space, how many times they spawn, as well as enemy attributes.
	playerConfig = gameInitialization:loadPlayerData()
	EnemySpawnTable = gameInitialization:loadEnemyTable()

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
			aspects = Set{"player"}, 
			world = worldPhysics:getWorld(),
			debug = Debug
		}
	}

	score = 0

	-- NOTE: DEBUG
	gameOver = GameOver:new {
		worldWidth = VIEWPORT_WIDTH,
		worldHeight = VIEWPORT_HEIGHT,
		playerConfig = playerConfig,
		gameSeed = seed
	}

	return mainMenu
end 

function Game:update(dt)

end

function Game:draw()

end

function Game:keypressed()

end

function Game:keyreleased()

end