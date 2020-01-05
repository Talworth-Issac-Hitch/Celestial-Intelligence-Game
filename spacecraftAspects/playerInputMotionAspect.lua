-----------------------
-- ASPECT DEFINITION --
-----------------------

-- An aspect that makes a craft move according to when the player hits the WASD, or Arrow keys.
-- TODO: Maybe make these enemies movable with separate keys from the player motion, to work on Michael skills?
PlayerInputMotionAspectDefinition = {
	buttonImage = "assets/telepathy.png",

	scalingTable = {
		sizeX = 1.2,
		sizeY = 1.2,
		speed = 0.5
	},

	-- Love2D callback for when the player presses a key.  This is how the player moves.
	onKeyPressed = function(self, key)
		if self.finishedSpawn then
			-- User input affeccting playerCraft's movements
			local xVelocity, yVelocity = self.body:getLinearVelocity()
			
			if key == 'up' or key == 'w' then
				yVelocity = -self.speed
			elseif key == 'down' or key == 's' then
				yVelocity = self.speed
			elseif key == 'right' or key == 'd' then
				xVelocity = self.speed
			elseif key == 'left' or key == 'a' then
				xVelocity = -self.speed
			end

			self.body:setLinearVelocity(xVelocity, yVelocity)
		end
	end,

	-- Love2D callback for when the player presses a key.  This is how the player stops moving.
	onKeyReleased = function(self, key)
		if self.finishedSpawn then
			-- User input affeccting playerCraft's movements
			local xVelocity, yVelocity = self.body:getLinearVelocity()

			if key == 'up' or key == 'w' then
				if love.keyboard.isDown('down') then
					yVelocity = self.speed
				else 
					yVelocity = 0
				end
			elseif key == 'down' or key == 's' then
				if love.keyboard.isDown('up') then
					yVelocity = -self.speed
				else 
					yVelocity = 0
				end
			elseif key == 'right' or key == 'd' then
				if love.keyboard.isDown('left') then
					xVelocity = -self.speed
				else 
					xVelocity = 0
				end
			elseif key == 'left' or key == 'a' then
				if love.keyboard.isDown('right') then
					xVelocity = self.speed
				else 
					xVelocity = 0
				end
			end

			self.body:setLinearVelocity(xVelocity, yVelocity)
		end
	end
}

return PlayerInputMotionAspectDefinition