-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"
JSON = require "libs/json"

----------------------
-- CLASS DEFINITION -- 
----------------------

-- A wrapper for handling the post-game behavior drawing .  
GameOver = {}
GameOver.__index = GameOver

---------------
-- CONSTANTS --
--------------- 
HIGH_SCORE_LIST_LENGTH = 5

-- Constructor.  Builds a new Game Over screen.
-- @param {Table} options A table containing any post-game information that needs to be show to the player or serialized to a file.
function GameOver:new(options)
	local gameOver = {
		worldWidth = 800,
		worldHeight = 600,
		score = 0,
		gameSeed = 1999,
		gameOverTime = 0,
		playerConfig = { playerType = 0 },
		enemySpawnTable = {},
		highScores = {}
	}

	setmetatable(gameOver, GameOver)

	gameOver = _.extend(gameOver, options)

	-- TODO: Look into localization!
	local playerName = "N00B"

	-- Currently only humans get to pick their names.  Sorry AI friends!
	if gameOver.playerConfig.playerType == 0 and gameOver.playerConfig.playerName then
		self.playerName = gameOver.playerConfig.playerName
	elseif playerConfig.playerType ~= 0 then
	    self.playerName = playerName .. " Bot " .. gameOver.playerConfig.playerType
	end

	gameOver.footer = "Press 'q' to quit."
	return gameOver
end 

-- The Love2D callback for each drawing frame. Draw our end game text
-- @param {number} gameOverTime - How much time (in seconds) has ellapsed since gameOver
-- @param {number} alpha - How much alpha to draw the gameover screen with
function GameOver:draw(gameOverTime, alpha)
	local LINEHEIGHT = 32

	-- Make game over flash, to emphasize that you suck for losing.
	local headerAlpha = math.cos(gameOverTime * 2.5 - math.pi * 0.25) + 1
	if alpha and headerAlpha > alpha then
		headerAlpha = alpha
	end

	love.graphics.setFont(self.font)

	love.graphics.setColor(1, 1, 1, headerAlpha)
	love.graphics.print(self.header, self.worldWidth / 3, LINEHEIGHT)

	love.graphics.setColor(1, 1, 1, alpha)
	love.graphics.print(self.subHeader, self.worldWidth / 3, LINEHEIGHT * 2)

	love.graphics.print(self.body, self.worldWidth / 3, LINEHEIGHT * 8)

	love.graphics.print(self.footer, self.worldWidth / 3, self.worldHeight - LINEHEIGHT * 2)
	love.graphics.reset()
end

-- Handler to be called when the game finishes
function GameOver:onGameEnd(finalScore)
	self.highScores = self:getHighscores()

	local isNewHighscore = self:resolveHighScores(finalScore)

	if isNewHighscore then
		self:updateHighscoresFile(self.highScores)
	end

	self:resolveEndScreenText(isNewHighscore)
end

-- Retrieves existing highscores, currently from a local file.
function GameOver:getHighscores()
	-- TODO: Separate highscores out by enemy config.
	local HIGHSCORES_FILE_PATH = "community/highscores.json"

	-- Check if the parent directories exist, and create them if not.
	if love.filesystem.getInfo("community", "directory") == nil then
		love.filesystem.createDirectory("community")
	end

	local highscoresFileInfo = love.filesystem.getInfo(HIGHSCORES_FILE_PATH)

	local highscoresTable = {}

	-- Fetch the highscores table, or create a blank one if it doesn't exist yet.
	if highscoresFileInfo and highscoresFileInfo.type == "file" then
		-- NOTE: Currently configs should only be a single line, but we iterate here for good measure.
		for line in love.filesystem.lines(HIGHSCORES_FILE_PATH) do
			highscoresTable = JSON.decode(line)
		end
	end

	return highscoresTable
end

-- Resolves the player's current score with the highscore list.
-- @returns - true if the player has achieved a new highscore, false otherwise.
function GameOver:resolveHighScores(currentPlayerScore)
	self.score = currentPlayerScore

	local currentPlayerHighscoreObj = {name = self.playerName, score = self.score}

	-- Potentially add player's score to the highscore list
	table.insert(self.highScores, currentPlayerHighscoreObj)

	self.highScores = _.sort(self.highScores, function(a, b)
		return a.score > b.score
	end)

	self.highScores = _.first(self.highScores, HIGH_SCORE_LIST_LENGTH)

	-- Return whether or not our highscore made the cut!
	return (not _.all(self.highScores, function (highScoreObj)
		return (highScoreObj ~= currentPlayerHighscoreObj)
	end))
end

-- Persists new highscore list, currently to a local file.
function GameOver:updateHighscoresFile(newHighscores)
	-- TODO: Separate highscores out by enemy config.
	local HIGHSCORES_FILE_PATH = "community/highscores.json"

	love.filesystem.write(HIGHSCORES_FILE_PATH, JSON.encode(newHighscores), all)
end

-- Finalizes the end screen text to display to the player.  Currently displays highscores.
function GameOver:resolveEndScreenText(isNewHighscore)
	if isNewHighscore then
		self.header = "Game Over!  New Highscore!!! You rock " .. self.playerName
	else
		self.header = "Game Over!  You suck " .. self.playerName
	end

	self.subHeader = "Final Score : " .. self.score .. "\nGame Seed: " .. self.gameSeed
	-- String pad for uniform display
	self.body = "High Scores:\n"
	_.eachi(self.highScores, function(highScoreObj, highScorePlace)
		self.body = self.body ..
		string.format("%d. %-15s %4s\n", highScorePlace, highScoreObj.name, highScoreObj.score)
	end)

	self.font = love.graphics.newFont("assets/font/cour.ttf", 14)
end

-- Love2D callback for when the player presses a key.  End the game if the user is finished looking at the game
-- over screen.
function GameOver:onKeyReleased(key)
	if key == 'q' then
		love.event.quit( )
	end
end

-- End of life clean up handler.  Currently writes out a stats file for the game run.
function GameOver:onQuitHandler()
	local DATA_DIRECTORY_NAME = "playData/"

	-- TODO: Create a more specific GUID for game data hash.  This one will currently cause probs if two players submit
	--       data at the same instant, which is a legitmate issue at scale.
	local gameHash = os.time()

	print("" .. self.playerConfig.playerType)

	-- Build a table to serialize to a data file summarizing the play through for the ML.
	local playDataTable = {
		playerType = self.playerConfig.playerType,
		score = score
	}

	-- Add all the enemy spawns
	_.eachi(self.enemySpawnTable, function(spawnTableEntry, index)
		local aspectList = spawnTableEntry.enemyObj.aspects
		playDataTable["e" .. index .. "Aspects"] = _.keys(aspectList)
	end)

	-- Ensure the data/ folder exists.
	local dataFolder = love.filesystem.getInfo(DATA_DIRECTORY_NAME)

	if not dataFolder or dataFolder.type ~= "directory"  then
		love.filesystem.createDirectory(DATA_DIRECTORY_NAME)
	end

	love.filesystem.write(DATA_DIRECTORY_NAME .. "playData-" .. gameHash .. ".json", JSON.encode(playDataTable), all)
end

return GameOver