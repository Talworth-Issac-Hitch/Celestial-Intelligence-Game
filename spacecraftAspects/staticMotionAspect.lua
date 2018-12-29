-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which do not move and cannot be moved themselves.
StaticCraftAspectDefinition = {
	sizeX = 100, -- TODO: Replace hard-coding attributes with scaling factor.
	sizeY = 100, -- TODO: Replace hard-coding attributes with scaling factor.
	speed = 0, -- TODO: Replace hard-coding attributes with scaling factor.

	bodyType = "static",

	-- TODO: Bring back rotatable square walls.
	beforeBodySetup = function(self) 
		self.facingAngle = love.math.random(0, 2 * math.pi)
	end
}

return StaticCraftAspectDefinition