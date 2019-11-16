-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which will continuously accelate in the direction it is facing.
AcceleratingSpeedAspectDefinition = {
	-- A hook for any custom behavior to occur during the Love2D update callback.
	-- Adds force to the spacecraft's body each second to create acceleration.
	onUpdate = function(self, dt)
		if self.finishedSpawn then
			-- Base accelaration off of speed/motion factor
			local xForce = math.cos(self.body:getAngle()) * self.speed * 25 * dt
			local yForce = math.sin(self.body:getAngle()) * self.speed * 25 * dt

			self.body:applyForce(xForce, yForce);
		end
	end
}

return AcceleratingSpeedAspectDefinition