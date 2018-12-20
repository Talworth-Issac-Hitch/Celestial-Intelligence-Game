-- ASPECT DEFINITIONS --
-- A table of aspect attributes to be applied on initialization
SpaceCraftAspectDefinitions = {
	player = {
		imagePath ="assets/pig.png", 
		sizeX = 50, 
		sizeY = 50,
		speed = 400, 

		collisionData = "player",

		collisionDebugColor = {0.05, 0.9, 0.05},

		onKeyPressed = function(self, key)
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
		end,
		onKeyReleased = function(self, key)
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
	},
	enemyStatic = {
		imagePath = "assets/head.png", 
		sizeX = 100, 
		sizeY = 100,
		speed = 0,

		bodyType = "static"
	},
	enemyLinear = {
		imagePath = "assets/metor.jpg",
		sizeX = 25, 
		sizeY = 25,
		speed = 250,
		initializeShape = function(self) 
			return love.physics.newCircleShape(self.sizeX / 2, self.sizeY / 2, self.sizeX / 2)
		end,
		onSpawnFinished = function(self)
			-- NOTE : We could do this in the pre-spawn phase to give the player some indication of the direction
			--         that the enemy will move, we just currently do not.
			local initAngle = love.math.random(0, 2 * math.pi)
		
			self.xVelocity = math.sin(initAngle) * self.speed
			self.yVelocity = math.cos(initAngle) * self.speed

			self.body:setLinearVelocity(self.xVelocity, self.yVelocity)

			-- preserve all linear momentum for now.  Set restitution to 1 since perfect elasticity 
			-- conservers momentum in a head-on collision, and friction to 0 to prevent linear velocity
			-- becoming angular velocity.
			self.fixture:setRestitution(1) 
			self.fixture:setFriction(0) 
		end,
		drawImage = function(self)
			local drawX, drawY = self:getCenterPoint()

			-- Compensate for the fact that circular collision when drawing square images
			-- Unlike square collision shapes that perfectly fit square images, circles on have their center point.
			drawX = drawX - (self.sizeX / 2)
			drawY = drawY - (self.sizeY / 2)

			love.graphics.draw(self.image, drawX, drawY, 0, self.imgSX, self.imgSY)
		end,
		debugDrawCollisionBorder = function(self)
			love.graphics.setColor(self.collisionDebugColor)
			local debugX, debugY = self:getCenterPoint()
			love.graphics.circle("line", debugX, debugY, self.sizeX / 2)
			love.graphics.reset()
		end
	}
}

return SpaceCraftAspectDefinitions