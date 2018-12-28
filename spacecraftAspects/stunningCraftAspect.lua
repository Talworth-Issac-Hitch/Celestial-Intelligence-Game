-- ASPECT DEFINITION --
-- Crafts that temporarily stun, but not kill, the player when crashed into.

-- Constants --
-- TODO: Create a collision Constants files, since these values are used by both worldPhysics and spaceCraft
-- NOTE: Global constants are slower to to access than locals.  Therefore for globals used many times in a 
--        given function, it makes more sense to copy it to a local, for performance reasons.
COLLISION_CATEGORY_DEFAULT = 0x0001
COLLISION_CATEGORY_BOUNDARY = 0x0002
COLLISION_CATEGORY_PLAYER = 0x0004
COLLISION_CATEGORY_ENEMY = 0x008

COLLISION_MASK_ALL = 0xFFFF
COLLISION_MASK_PLAYER_AND_BOUNDARIES = 0x0006

COLLISION_GROUP_NONE = 0

StunningCraftAspectDefinition = {
	collisionData = "stun",
	collisionDebugColor = {0.9, 0.9, 0.05},
	scalingFactor = 2,
	-- TODO: Make its' own aspect
	drawFacing = true,

	-- TODO: MAke it's own aspect
	collisionCategory = COLLISION_CATEGORY_ENEMY,
	collisionMask = COLLISION_MASK_PLAYER_AND_BOUNDARIES,

	onSpawnFinished2 = function(self)
		self.fixture:setDensity(0.5)
		self.body:resetMassData()

		-- TODO: Add masking behavior
	end

	-- TODO: A stun variant that just/also makes you invisible.  It was a bug, but horrifying.
	--       Maybe that'd be a challenging Amp
}

return StunningCraftAspectDefinition