-------------
-- IMPORTS --
-------------
CollisionConstants = require "collisionConstants"


-----------------------
-- ASPECT DEFINITION --
-----------------------

-- Crafts that should only collide with other crafts, but not level boundaries.
PlayerAndEnemyCollisionAspectDefinition = {
	collisionMask = CollisionConstants.MASK_PLAYER_AND_ENEMY
}

return PlayerAndEnemyCollisionAspectDefinition