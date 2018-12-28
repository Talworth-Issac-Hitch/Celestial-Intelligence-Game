-- IMPORT --
CollisionConstants = require "collisionConstants"

-- ASPECT DEFINITION --
-- Crafts that temporarily stun, but not kill, the player when crashed into.
StunningCraftAspectDefinition = {
	collisionData = "stun",
	collisionDebugColor = {0.9, 0.9, 0.05},
	scalingFactor = 2,
	-- TODO: Make its' own aspect
	drawFacing = true,

	-- TODO: MAke it's own aspect
	collisionCategory = CollisionConstants.CATEGORY_ENEMY,
	collisionMask = CollisionConstants.MASK_PLAYER_AND_BOUNDARIES,

	onSpawnFinished2 = function(self)
		self.fixture:setDensity(0.5)
		self.body:resetMassData()

		-- TODO: Add masking behavior
	end

	-- TODO: A stun variant that just/also makes you invisible.  It was a bug, but horrifying.
	--       Maybe that'd be a challenging Amp
}

return StunningCraftAspectDefinition