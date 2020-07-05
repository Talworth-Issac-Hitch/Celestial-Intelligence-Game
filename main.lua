-------------
-- IMPORTS --
-------------
CustomExceptionHandler = require "customExceptionHandler"

_ = require "libs/moses_min"

MainMenu = require "mainMenu"
GameWrapper = require "game/gameWrapper"
Editor = require "editor/editor"

function getDirectionInRadiansFromVector(vectorXComponet, vectorYComponent)
	return math.atan2(vectorYComponent, vectorXComponet)
end

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

-- Returns an array of the values of a set.  Any key set as 'false' is omitted.
function SetToArray(set)
	local keys = {}
	for key, exists in pairs(set) do
		if exists then
			keys[#keys+1] = key
		end
	end
	return keys
end

function TableToStr(table)
	local tableStr = "{"
	for key, value in pairs(table) do
		tableStr = tableStr .. key .. ":" .. value .. ", "
	end
	tableStr = tableStr:sub(1, -2) .. "}"
	return tableStr
end

---------------
-- CONSTANTS --
--------------- 
VIEWPORT_HEIGHT = 800
VIEWPORT_WIDTH = 1200

GAME_NOT_STARTED = 0
GAME_ON = 1
GAME_OVER = 2

VIEW_MAIN_MENU = 0
VIEW_GAME = 1
VIEW_EDITOR = 2

-------------
-- GLOBALS --
-------------

activeView = VIEW_MAIN_MENU

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
	love.window.setTitle("Celestial Intelligence")

	music = love.audio.newSource("assets/audio/Ahornberg-ligh appears out of the darkness-Clip.mp3", "stream")
	music:play()

	-- Get and set our random seed.  This can be used to re-create an exact session.
	seed = os.time()
	print("Session initialized with game seed: " .. seed)
	love.math.setRandomSeed(seed)

	-- NOTE: DEBUG
	mainMenu = MainMenu:new {
		worldWidth = VIEWPORT_WIDTH,
		worldHeight = VIEWPORT_HEIGHT,
		gameStartHandler = loadGame,
		editorStartHandler = loadEditor

	}
end

-- Initializes and switches to the Game view.
function loadGame()
	game = GameWrapper:new {
		worldWidth = VIEWPORT_WIDTH,
		worldHeight = VIEWPORT_HEIGHT,
		gameSeed = seed,
		debug = Debug,
	}
	activeView = VIEW_GAME

	music:stop()
end

-- -- Initializes and switches to the Editor view.
function loadEditor()
	editor = Editor:new {
		worldWidth = VIEWPORT_WIDTH,
		worldHeight = VIEWPORT_HEIGHT,
		debug = Debug,
	}
	activeView = VIEW_EDITOR
end

-- The Love2D callback for time passing in the game.  Most game components have their individual implementations for
-- that callback, which we blindly call here.  Additional we manage some global counters.
-- @param dt The time interval since the last time love.update was called.
function love.update(dt)
	if activeView == VIEW_MAIN_MENU then
		mainMenu:update(dt)
	elseif activeView == VIEW_EDITOR then
		editor:update(dt)
	else
		game:update(dt)
	end
end

-- Love2D callback for graphics drawing.  Most game components have their individual implementations for that callback,
-- which we blindly call here.
function love.draw()
	if activeView == VIEW_MAIN_MENU then
		mainMenu:draw()
	elseif activeView == VIEW_EDITOR then
		editor:draw()
	else
		game:draw()
	end
end

-- Love2D callback for when the player presses a key.  Some game components have their individual implementations for that callback,
-- so if one exists, we call it here.
function love.keypressed(key, scancode, isrepeat, isNonPlayerAction)
	-- TODO : Funnel all handlers to whatever is the active view (ie. 'Main Menu', 'Game', 'GameOver')
	if activeView == VIEW_GAME then
		game:keypressed(key, scancode, isrepeat, isNonPlayerAction)
	elseif activeView == VIEW_EDITOR then
		editor:keypressed(key, scancode, isrepeat)
	end
end

-- Love2D callback for when the player releases a key.  Some game components have their individual implementations for that callback,
-- so if one exists, we call it here.
function love.keyreleased(key, scancode, isrepeat, isNonPlayerAction)
	if activeView == VIEW_MAIN_MENU then
		mainMenu:onKeyReleased(key, scancode, isrepeat, isNonPlayerAction)
	elseif activeView == VIEW_GAME then
		game:keyreleased(key, scancode, isrepeat, isNonPlayerAction)
	elseif activeView == VIEW_EDITOR then
		editor:keyreleased(key, scancode, isrepeat)
	end
end

-- Love2D callback for when the player clicks the mouse.  Some game components have their individual implementations for that callback,
-- so if one exists, we call it here.
function love.mousepressed(x, y, button, istouch, presses)
	if activeView == VIEW_EDITOR then
		editor:mousepressed(x, y, button, istouch, presses)
	end
end

-- Love2D callback for when the game closes
function love.quit()
	if game then
		game:onQuitHandler()
	end

	return false
end
-------------------
-- CUSTOM EVENTS -- 
-------------------

-- A custom event that occurs when the player dies.
function love.handlers.playerDied(killedBy)
	game:onPlayerDeath(killedBy)
end