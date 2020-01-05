-------------
-- IMPORTS --
-------------
CollisionConstants = require "collisionConstants"


-----------------------
-- ASPECT DEFINITION --
-----------------------

-- Crafts that should only collide with other crafts, but not level boundaries.
PlayerAndEnemyCollisionAspectDefinition = {
	buttonImage = "assets/evasion.png",
	collisionMask = CollisionConstants.MASK_PLAYER_AND_ENEMY
}

return PlayerAndEnemyCollisionAspectDefinition