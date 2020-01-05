-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which begins it's life rotating in one direction
InitialRotationAspectDefinition = {
	buttonImage = "assets/clockwise-rotation.png",
	-- A hook for any SpaceCraft Behavior that should occur on spawn.
	-- Set up our initial angular velocity.
	beforeBodySetup = function(self)	
		self.angularVelocity = -5
	end
}

return InitialRotationAspectDefinition