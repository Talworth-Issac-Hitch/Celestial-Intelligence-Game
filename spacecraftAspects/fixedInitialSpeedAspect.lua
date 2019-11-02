-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which begins it's life moving in one direction, and doesn't (of it's own volition) accelarate otherwise.
FixedInitialSpeedAspectDefinition = {
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

return FixedInitialSpeedAspectDefinition