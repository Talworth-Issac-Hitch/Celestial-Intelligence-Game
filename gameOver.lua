-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"


----------------------
-- CLASS DEFINITION -- 
----------------------

-- A wrapper for handling the post-game behavior drawing .  
-- Currently uses Love2D's native Phsyics engine.
GameOver = {}
GameOver.__index = GameOver

-- Constructor.  Builds a new Game Over screen.
-- @param options A table containing any post-game information that needs to be show to the player or serialized to a file.
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
-- TODO: Fadeout from the regular game, before drawing the end game screen.
function GameOver:draw()
	local LINEHEIGHT = 32
	local subHeader = "Final Score : " .. self.score .. "\nGame Seed: " .. self.gameSeed

	love.graphics.print(self.header, self.worldWidth / 3, LINEHEIGHT)
	love.graphics.print(subHeader, self.worldWidth / 3, LINEHEIGHT * 2)
	love.graphics.print(self.footer, self.worldWidth / 3, self.worldHeight - LINEHEIGHT * 2)
end

	-- Love2D callback for when the player presses a key.  End the game if the user is finished looking at the game
	-- over screen.
function GameOver:onKeyReleased(key)
	if key == 'q' then
		love.event.quit( )
	end
end

function GameOver:setScore(score)
	self.score = score
end

return GameOver