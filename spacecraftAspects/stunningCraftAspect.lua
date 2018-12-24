-- ASPECT DEFINITION --
-- Crafts that temporarily stun, but not kill, the player when crashed into.
StunningCraftAspectDefinition = {
	collisionData = "stun",
	collisionDebugColor = {0.9, 0.9, 0.05},
	scalingFactor = 2

	-- TODO: A stun variant that just/also makes you invisible.  It was a bug, but horrifying.
	--       Maybe that'd be a challenging Amp
}

return StunningCraftAspectDefinition