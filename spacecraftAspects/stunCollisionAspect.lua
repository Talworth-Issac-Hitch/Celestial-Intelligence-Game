-----------------------
-- ASPECT DEFINITION --
-----------------------

-- Crafts that temporarily stun, but not kill, the player when crashed into.
-- TODO: Change collision sounds?
StunningCraftAspectDefinition = {
	collisionType = "stun",
	collisionDebugColor = {0.9, 0.9, 0.05},
	scalingTable = {
		speed = 1.2
	}
}

return StunningCraftAspectDefinition