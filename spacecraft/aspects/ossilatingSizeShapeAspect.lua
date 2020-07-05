-----------------------
-- ASPECT DEFINITION --
-----------------------

-- A Craft that has a circular Shape/collision area.
-- WARNING: This aspect may cause performance problems if applied to squares
OssilationSizeShapeAspectDefinition = {
	------------
	-- VISUAL --
	------------
	buttonImage = "assets/radial-balance.png",


	-----------------------------
	-- GENERIC CRAFT BEHAVIORS --
	-----------------------------

	onUpdate = function(self, dt)
		if self.finishedSpawn then
			self:addShapeSize((math.sin(self.age * 1.25) * 2))
			--self:scaleShape(1 + (math.sin(self.age * 1.5) * 0.01))
		end
	end
}

return OssilationSizeShapeAspectDefinition