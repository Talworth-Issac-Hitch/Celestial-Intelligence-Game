-------------
-- IMPORTS --
-------------
CollisionConstants = require "collisionConstants"


-----------------------
-- ASPECT DEFINITION --
-----------------------

-- Crafts that should only collide with the player and level boundaries, NOT other enemies.
PlayerAndBoundaryCollisionAspectDefinition = {
	buttonImage = "assets/ghost-ally.png",
	collisionMask = CollisionConstants.MASK_PLAYER_AND_BOUNDARIES
}

return PlayerAndBoundaryCollisionAspectDefinition