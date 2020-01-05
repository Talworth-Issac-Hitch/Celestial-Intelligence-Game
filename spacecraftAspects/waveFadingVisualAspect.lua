-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which will continuously ossilate it's opacity, from fully visible to fully invisible.
WaveFadingVisualAspectDefinition = {
	buttonImage = "assets/cloak-dagger.png",
	scalingTable = {
		sizeX = 1.2,
		sizeY = 1.2,
		speed = 0.75
	},

	-- A hook for any custom behavior to occur during the Love2D update callback.
	-- Update the craft's alpha to change it's visiblity 
	onUpdate = function(self, dt)
		if self.finishedSpawn then
			self.currentAlpha = (math.sin(self.age * 2) / 2) + 0.5
		end
	end
}

return WaveFadingVisualAspectDefinition