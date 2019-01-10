-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"
JSON = require "libs/json"


----------------------
-- CLASS DEFINITION -- 
----------------------

-- A wrapper for handling the post-game behavior drawing .  
-- Currently uses Love2D's native Phsyics engine.
GameOver = {}
GameOver.__index = GameOver

-- Constructor.  Builds a new Game Over screen.
-- @param {Table} options A table containing any post-game information that needs to be show to the player or serialized to a file.
function GameOver:new(options)
	local gameOver = {
		worldWidth = 800,
		worldHeight = 600,
		score = 0,
		gameSeed = 1999
	}

	setmetatable(gameOver, GameOver)

	gameOver = _.extend(gameOver, options)

	-- TODO: Look into localization!
	gameOver.header = "Game Over!"
	gameOver.footer = "Press 'q' to quit."
	return gameOver
end 

-- The Love2D callback for each drawing frame. Draw our end game text
-- @param {number} gameOverTime - How much time (in seconds) has ellapsed since gameOver
-- @param {number} alpha - How much alpha to draw the gameover screen with
function GameOver:draw(gameOverTime, alpha)
	local LINEHEIGHT = 32
	local subHeader = "Final Score : " .. self.score .. "\nGame Seed: " .. self.gameSeed

	

	-- Make game over flash, to emphasize that you suck for losing.
	local headerAlpha = math.cos(gameOverTime * 2.5 - math.pi * 0.25) + 1
	if alpha and headerAlpha > alpha then
		headerAlpha = alpha
	end

	love.graphics.setColor(1, 1, 1, headerAlpha)
	love.graphics.print(self.header, self.worldWidth / 3, LINEHEIGHT)

	love.graphics.setColor(1, 1, 1, alpha)
	love.graphics.print(subHeader, self.worldWidth / 3, LINEHEIGHT * 2)
	love.graphics.print(self.footer, self.worldWidth / 3, self.worldHeight - LINEHEIGHT * 2)
	love.graphics.reset()
end

	-- Love2D callback for when the player presses a key.  End the game if the user is finished looking at the game
	-- over screen.
function GameOver:onKeyReleased(key)
	if key == 'q' then
		self:appExit()
	end
end

function GameOver:appExit() 
	-- TODO: Create a more specific GUID for game data hash.  This one will currently cause probs if two players submit
	--       data at the same instant, which is a legitmate issue at scale.
	local gameHash = os.time()

	-- Build a table to serialize to a data file summarizing the play through for the ML.
	local playDataTable = {
		score = self.score,
		-- TODO: Do this... Better...
		-- TODO: BOO GLOBALS BOO.
		e1Aspects = _.keys(EnemySpawnTable[1].enemyObj.aspects),
		e2Aspects = _.keys(EnemySpawnTable[2].enemyObj.aspects),
		e3Aspects = _.keys(EnemySpawnTable[3].enemyObj.aspects),
		e4Aspects = _.keys(EnemySpawnTable[4].enemyObj.aspects)
	}

	-- TODO: Make game data output no matter what.  Currently only logs data if player hits 'Q' at the end.  
	--       Maybe can hook into an event?
	love.filesystem.write("playData-" .. gameHash .. ".json", JSON.encode(playDataTable), all)
	love.event.quit( )
end

return GameOver