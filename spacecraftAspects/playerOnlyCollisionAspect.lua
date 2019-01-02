-------------
-- IMPORTS --
-------------
CollisionConstants = require "collisionConstants"


-----------------------
-- ASPECT DEFINITION --
-----------------------

-- Crafts that should only collide with the player and level boundaries, NOT other enemies.
-- TODO: Create a behavior where these craft remove themselves from the global list of enemies when exiting screenbounds by a certain threshold.
PlayerOnlyCollisionAspectDefinition = {
	scalingTable = {
		speed = 4 -- Generous scaling since these will be killing themselves by flying off the screen.  Even if we add a
		           --  bommerang flight path, this will still mean they spend some time off screen?
	},
	collisionMask = CollisionConstants.MASK_PLAYER_ONLY
}

return PlayerOnlyCollisionAspectDefinition