-- ASPECT DEFINITION --
-- For Craft which move in a straight line, in a (somewhat) constant fashion.
LinearCraftAspectDefinition = {
		imagePath = "assets/metor.jpg",
		sizeX = 25, 
		sizeY = 25,
		speed = 250,
		-- Set up our initial speed
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
		end
	}

return LinearCraftAspectDefinition