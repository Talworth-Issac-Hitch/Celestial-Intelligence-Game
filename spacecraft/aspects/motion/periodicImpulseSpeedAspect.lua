-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which will intermittedly have an impulse applied in the direction it is facing.
PeriodicImpulseSpeedAspectDefinition = {
	buttonImage = "assets/forward-sun.png",
	-- A hook for any custom behavior to occur during the Love2D update callback.
	-- Adds force to the spacecraft's body each second to create acceleration.
	onUpdate = function(self, dt)
		if self.finishedSpawn then
			local roundedAge = math.ceil(self.age)

			-- If this is whole second, and a third second
			if roundedAge > math.ceil(self.age - dt) and roundedAge % 3 == 0 then
				-- Base accelaration off of speed/motion factor
				local xImpluse = math.cos(self.body:getAngle()) * self.speed * 0.25
				local yImpluse = math.sin(self.body:getAngle()) * self.speed * 0.25

				self.body:applyLinearImpulse(xImpluse, yImpluse);
			end
		end
	end
}

return PeriodicImpulseSpeedAspectDefinition