-- IMPORTS --
playerAspectDefinition = require "spacecraftAspects/playerCraftAspect"
staticAspectDefinition = require "spacecraftAspects/staticCraftAspect"
linearAspectDefinition = require "spacecraftAspects/linearCraftAspect"

-- ASPECT DEFINITIONS --
-- A table of aspect attributes to be applied on initialization
SpaceCraftAspectDefinitions = {
	player = playerAspectDefinition,
	enemyStatic = staticAspectDefinition,
	enemyLinear = linearAspectDefinition
}

return SpaceCraftAspectDefinitions