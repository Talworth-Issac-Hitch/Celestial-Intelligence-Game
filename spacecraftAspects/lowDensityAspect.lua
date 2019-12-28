-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Crafts which should be less dense
LowDensityAspectDefinition = {
	-- A hook for any SpaceCraft Behavior that should occur on spawn.
	-- Set up our density.
	beforeBodySetup = function(self)	
		self.density = 0.1
	end
}

return LowDensityAspectDefinition