-------------
-- IMPORTS --
-------------
CollisionConstants = require "collisionConstants"

-----------------------
-- ASPECT DEFINITION --
-----------------------

-- Special Aspect for the player's craft
PlayerCraftAspectDefinition = {
	imagePath ="assets/totem-head.png",

	scalingTable = {
		sizeX = 0.8,
		sizeY = 0.8
	},
	angularDampening = 0.65,

	collisionType = "player",
	collisionCategory = CollisionConstants.CATEGORY_PLAYER,

	collisionDebugColor = {0.05, 0.9, 0.05},

	stunCounter = 0,

	-- A hook for any custom behavior to occur during the Love2D update callback. 
	-- If we're stunned, run down our timer, otherwise, we're not stunned!
	onUpdate = function(self, dt) 
		if self.stunCounter > 0 then
			self.stunCounter = self.stunCounter - dt
		else
			self.stunned = false
			self.stunCounter = 0
		end
	end,

	-- Love2D callback for when the player presses a key.  This is how the player moves.
	onKeyPressed = function(self, key)
		if self.stunCounter <= 0 then
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
		if self.stunCounter <= 0 then
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

return PlayerCraftAspectDefinition