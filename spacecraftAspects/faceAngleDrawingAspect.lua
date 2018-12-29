-- ASPECT DEFINITION --
-- For Craft which should always be drawn to match the angle their physics Body is facing.
DrawFacingAngleAspectDefinition = {
	-- Draw of our physics body's angle
	getImageDrawAngle = function(self)
		return self.body:getAngle() + self.imageRotationOffset
	end
}

return DrawFacingAngleAspectDefinition