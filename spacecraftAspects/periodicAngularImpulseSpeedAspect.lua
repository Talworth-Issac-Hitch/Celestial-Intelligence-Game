-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which will intermittedly have an angular impulse.
PeriodicAngularImpulseSpeedAspectDefinition = {
	buttonImage = "assets/backward-time.png",
	-- A hook for any custom behavior to occur during the Love2D update callback.
	-- Adds rotational to the spacecraft's body each second to create acceleration.
	onUpdate = function(self, dt)
		if self.finishedSpawn then
			local roundedAge = math.ceil(self.age)

			-- If this is whole second, and a third second
			if roundedAge > math.ceil(self.age - dt) and roundedAge % 3 == 0 then
				self.body:applyAngularImpulse(500);
			end
		end
	end
}

return PeriodicAngularImpulseSpeedAspectDefinition