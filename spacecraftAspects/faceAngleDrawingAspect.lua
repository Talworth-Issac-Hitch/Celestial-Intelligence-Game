-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which should always be drawn to match the angle their physics Body is facing.
DrawFacingAngleAspectDefinition = {

	-- Gets the angle (in terms of Graphics) that the drawn image be rotated.  Applied through a transformation.
	-- Our drawing angle always matches our Love2D Phyiscs Body's 'facing' angle.
	getImageDrawAngle = function(self)
		return self.body:getAngle()
	end
}

return DrawFacingAngleAspectDefinition