-- ASPECT DEFINITION --
-- For Craft which do not move and cannot be moved themselves.
StaticCraftAspectDefinition = {
	sizeX = 100, 
	sizeY = 100,
	speed = 0,

	bodyType = "static",
	beforeBodySetup = function(self) 
		self.facingAngle = love.math.random(0, 2 * math.pi)
	end

	-- TODO: Could we have static objects with >1 restitution, aka, accelerator walls?
}

return StaticCraftAspectDefinition