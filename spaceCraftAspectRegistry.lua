-- IMPORTS --
playerAspectDefinition = require "spacecraftAspects/playerCraftAspect"
deadlyAspectDefinition = require "spacecraftAspects/deadlyCraftAspect"
linearAspectDefinition = require "spacecraftAspects/linearCraftAspect"
circularAspectDefinition = require "spacecraftAspects/circularCraftAspect"
staticAspectDefinition = require "spacecraftAspects/staticCraftAspect"
stunningAspectDefinition = require "spacecraftAspects/stunningCraftAspect"

-- ASPECT DEFINITIONS --
-- A table of aspect attributes to be applied on initialization
-- TODO: Make multiple nested tables to handle the mutally exclusive aspects
SpaceCraftAspectDefinitions = {
	player = playerAspectDefinition,
	deadly = deadlyAspectDefinition,
	enemyLinear = linearAspectDefinition,
	circular = circularAspectDefinition,
	enemyStatic = staticAspectDefinition,
	stun = stunningAspectDefinition

	-- TODO: Player-friendly unit that does other units, to clear out the map
}

return SpaceCraftAspectDefinitions