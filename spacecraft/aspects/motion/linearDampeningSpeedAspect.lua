-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which naturally slow down their linear motion, but move faster to compensate
LinearDampeningSpeedAspectDefinition = {
	buttonImage = "assets/tornado-discs.png",
	scalingTable = {
		speed = 3
	},

	-- A hook for any SpaceCraft Behavior that should occur on spawn.
	-- Set up our linear dampening
	beforeBodySetup = function(self)	
		self.linearDampening = 2
	end
}

return LinearDampeningSpeedAspectDefinition