-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which will a periodically have it's speed relative to it's direction ossilate in a fixed manner.
SinWaveFixedSpeedAspectDefinition = {
	-- A hook for any custom behavior to occur during the Love2D update callback.
	-- Fixes the craft's speed in the direction it's facing
	onUpdate = function(self, dt)
		if self.finishedSpawn then
			local currentSpeed = math.sin(self.age * 2) * self.speed

			self.xVelocity = math.cos(self.body:getAngle()) * currentSpeed
			self.yVelocity = math.sin(self.body:getAngle()) * currentSpeed

			self.body:setLinearVelocity(self.xVelocity, self.yVelocity)
		end
	end
}

return SinWaveFixedSpeedAspectDefinition