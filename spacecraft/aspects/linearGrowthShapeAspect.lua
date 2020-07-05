-----------------------
-- ASPECT DEFINITION --
-----------------------

-- An aspect that which causes a craft to grow at a fixed number of units per timestep (linear pace)
-- WARNING: This aspect may cause performance problems if applied to squares
LinearGrowthShapeAspectDefinition = {
	------------
	-- VISUAL --
	------------
	buttonImage = "assets/resize.png",

	scalingTable = {
		sizeX = 0.2,
		sizeY = 0.2,
		speed = 0.8
	},

	-----------------------------
	-- GENERIC CRAFT BEHAVIORS --
	-----------------------------

	onUpdate = function(self, dt)
		-- TODO: Replace manual age check with global Size limit
		if self.finishedSpawn and self.age < 50 then
			self:addShapeSize(dt * 5)
		end
	end
}

return LinearGrowthShapeAspectDefinition