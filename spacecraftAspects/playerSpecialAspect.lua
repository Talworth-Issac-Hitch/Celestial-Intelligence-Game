-- ASPECT DEFINITION --

COLLISION_CATEGORY_PLAYER = 0x0004

-- For the player's craft
PlayerCraftAspectDefinition = {
	imagePath ="assets/totem-head.png", 
	sizeX = 50, 
	sizeY = 50,
	speed = 400,
	angularDampening = 0.65,

	collisionData = "player",
	collisionCategory = COLLISION_CATEGORY_PLAYER,

	collisionDebugColor = {0.05, 0.9, 0.05},

	onKeyPressed = function(self, key)
		if StunCounter <= 0 then
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
	onKeyReleased = function(self, key)
		if StunCounter <= 0 then
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