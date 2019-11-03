-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which begins it's life moving in one direction, and doesn't (of it's own volition) accelarate otherwise.
FixedInitialSpeedAspectDefinition = {
	-- A hook for any SpaceCraft Behavior that should occur on spawn.
	-- Set up our initial velocity, based on our speed and facing angle.
	onSpawnFinished = function(self)	
		self.xVelocity = math.cos(self.body:getAngle()) * self.speed
		self.yVelocity = math.sin(self.body:getAngle()) * self.speed

		self.body:setLinearVelocity(self.xVelocity, self.yVelocity)

		local craftDirection = getDirectionInRadiansFromVector(self.body:getLinearVelocity())
	end
}

return FixedInitialSpeedAspectDefinition