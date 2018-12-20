-- IMPORTS --
playerAspectDefinition = require "spacecraftAspects/playerCraftAspect"
circularAspectDefinition = require "spacecraftAspects/circularCraftAspect"
staticAspectDefinition = require "spacecraftAspects/staticCraftAspect"
linearAspectDefinition = require "spacecraftAspects/linearCraftAspect"

-- ASPECT DEFINITIONS --
-- A table of aspect attributes to be applied on initialization
-- TODO: 
SpaceCraftAspectDefinitions = {
	player = playerAspectDefinition,
	enemyLinear = linearAspectDefinition,
	circular = circularAspectDefinition,
	enemyStatic = staticAspectDefinition
}

return SpaceCraftAspectDefinitions