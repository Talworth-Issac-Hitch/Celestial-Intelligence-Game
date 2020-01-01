-------------
-- IMPORTS --
-------------
CustomExceptionHandler = require "customExceptionHandler"

_ = require "libs/moses_min"

GameWrapper = require "gameWrapper"

MainMenu = require "mainMenu"
GameInitialization = require "initialization"
WorldPhysics = require "worldPhysics"
GameOver = require "gameOver"

SpaceCraft = require "spaceCraft"

function getDirectionInRadiansFromVector(vectorXComponet, vectorYComponent)
	return math.atan2(vectorYComponent, vectorXComponet)
end

---------------
-- CONSTANTS --
--------------- 
VIEWPORT_HEIGHT = 800
VIEWPORT_WIDTH = 1200

GAME_NOT_STARTED = 0
GAME_ON = 1
GAME_OVER = 2
-------------
-- GLOBALS --
-------------

gameState = GAME_NOT_STARTED
gameOverTime = 0

Debug = {
	physicsVisual = false,
	physicsLog = false
}

----------------------
-- LOVE2D CALLBACKS --
----------------------

-- The Love2D callback for when the game initially loads.  Here we initialize our game variables.
function love.load()
	-- Set the Window size.
	love.window.setMode(VIEWPORT_WIDTH, VIEWPORT_HEIGHT)

	-- Get and set our random seed.  This can be used to re-create an exact session.
	seed = os.time()
	print("Session initialized with game seed: " .. seed)
	love.math.setRandomSeed(seed)

	-- NOTE: DEBUG
	mainMenu = MainMenu:new {
		worldWidth = VIEWPORT_WIDTH,
		worldHeight = VIEWPORT_HEIGHT
	}
end

function loadGame()
	game = GameWrapper:new {
		worldWidth = VIEWPORT_WIDTH,
		worldHeight = VIEWPORT_HEIGHT,
		gameSeed = seed,
		debug = Debug,
	}
end

-- The Love2D callback for time passing in the game.  Most game components have their individual implementations for
-- that callback, which we blindly call here.  Additional we manage some global counters.
-- @param dt The time interval since the last time love.update was called.
function love.update(dt)
	if gameState == GAME_NOT_STARTED then
		mainMenu:update(dt)
	else
		game:update(dt, gameState)
	end
end

-- Love2D callback for graphics drawing.  Most game components have their individual implementations for that callback,
-- which we blindly call here.
function love.draw()
	if gameState == GAME_NOT_STARTED then
		mainMenu:draw()
	else
		game:draw()
	end
end

-- Love2D callback for when the player presses a key.  Some game components have their individual implementations for that callback,
-- so if one exists, we call it here.
function love.keypressed(key, scancode, isrepeat, isNonPlayerAction)
	-- TODO : Funnel all handlers to whatever is the active phase (ie. 'Main Menu', 'Game', 'GameOver')
	if gameState ~= GAME_NOT_STARTED then
		game:keypressed(key, scancode, isrepeat, isNonPlayerAction, gameState)
	end
end

-- Love2D callback for when the player releases a key.  Some game components have their individual implementations for that callback,
-- so if one exists, we call it here.
function love.keyreleased(key, scancode, isrepeat, isNonPlayerAction)
	if gameState == GAME_NOT_STARTED then
		if key == 'space' then
			loadGame()
			gameState = GAME_ON
		end
	else
		game:keyreleased(key, scancode, isrepeat, isNonPlayerAction)
	end
end

function love.quit()
	game:onQuitHandler()

	return false
end
-------------------
-- CUSTOM EVENTS -- 
-------------------

-- A custom event that occurs when the player dies.
function love.handlers.playerDied(killedBy)
	game:onPlayerDeath(killedBy)
end

-- TODO: Add a timeout where the player wins!