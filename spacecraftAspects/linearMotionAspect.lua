-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which move in a straight line, in a (somewhat) constant fashion.
LinearCraftAspectDefinition = {
	sizeX = 32, -- TODO: Replace hard-coding attributes with scaling factor.
	sizeY = 32, -- TODO: Replace hard-coding attributes with scaling factor.
	speed = 250, -- TODO: Replace hard-coding attributes with scaling factor.

	-- Hook for any special modifications that need to be initially made to the Craft's Physics Body.
	-- We set a random facing angle, which differs from default, axis-aligned crafts.
	beforeBodySetup = function(self) 
		self.facingAngle = love.math.random(0, 2 * math.pi)
	end,

	-- A hook for any SpaceCraft Behavior that should occur on spawn.
	-- Set up our initial velocity, based on our speed and facing angle.
	onSpawnFinished = function(self)	
		self.xVelocity = math.cos(self.facingAngle) * self.speed
		self.yVelocity = math.sin(self.facingAngle) * self.speed

		self.body:setLinearVelocity(self.xVelocity, self.yVelocity)

		local craftDirection = getDirectionInRadiansFromVector(self.body:getLinearVelocity())
		
		-- preserve all linear momentum for now.  Set restitution to 1 since perfect elasticity 
		-- conservers momentum in a head-on collision, and friction to 0 to prevent linear velocity
		-- becoming angular velocity.
		self.fixture:setRestitution(1) 
		self.fixture:setFriction(0) 
	end
}

return LinearCraftAspectDefinition