-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which do not move and cannot be moved themselves.
StaticCraftAspectDefinition = {
	scalingTable = {
		sizeX = 2,
		sizeY = 2,
		speed = 0
	},

	bodyType = "static",

	-- TODO: Bring back rotatable square walls.
	beforeBodySetup = function(self) 
		self.facingAngle = love.math.random(0, 2 * math.pi)
	end
}

return StaticCraftAspectDefinition