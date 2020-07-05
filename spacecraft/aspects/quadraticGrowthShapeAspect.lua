-----------------------
-- ASPECT DEFINITION --
-----------------------

-- An aspect that which causes a craft to grow at rate based on it's current size (exponential pace)
-- WARNING: This aspect may cause performance problems if applied to squares
QuadraticGrowthShapeAspectDefinition = {
	------------
	-- VISUAL --
	------------
	buttonImage = "assets/progression.png",

	scalingTable = {
		sizeX = 0.3,
		sizeY = 0.3,
		speed = 0.4
	},

	-----------------------------
	-- GENERIC CRAFT BEHAVIORS --
	-----------------------------

	onUpdate = function(self, dt)
		-- TODO: Replace manual age check with global Size limit
		if self.finishedSpawn and self.age < 50 then
			self:scaleShape(1 + dt * 0.1)
		end
	end
}

return QuadraticGrowthShapeAspectDefinition