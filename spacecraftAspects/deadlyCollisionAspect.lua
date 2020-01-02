-----------------------
-- ASPECT DEFINITION --
-----------------------

-- Crafts that kill the player if they touch them
-- TODO: Change collision sounds?
DeadlyCraftAspectDefinition = {
	scalingTable = {
		sizeX = 0.5,
		sizeY = 0.5,
		speed = 0.6
	},

	collisionType = "deadly",
	collisionDebugColor = {0.9, 0.05, 0.05},
}

return DeadlyCraftAspectDefinition