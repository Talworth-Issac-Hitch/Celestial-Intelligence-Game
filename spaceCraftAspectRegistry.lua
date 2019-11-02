-------------
-- IMPORTS --
-------------
playerAspectDefinition = require "spacecraftAspects/playerSpecialAspect"
circularAspectDefinition = require "spacecraftAspects/circularShapeAspect"
linearAspectDefinition = require "spacecraftAspects/linearMotionAspect"
playerInputAspectDefinition = require "spacecraftAspects/playerInputMotionAspect"
staticAspectDefinition = require "spacecraftAspects/staticMotionAspect"
noEnemyCollisionAspectDefinition = require "spacecraftAspects/noEnemyCollisionAspect"
playerOnlyCollisionAspectDefinition = require "spacecraftAspects/playerOnlyCollisionAspect"
deadlyAspectDefinition = require "spacecraftAspects/deadlyCollisionAspect"
stunningAspectDefinition = require "spacecraftAspects/stunCollisionAspect"


-- A table of Aspect names to Aspect definitions/modules.
-- TODO: Make multiple nested tables to handle the mutally exclusive aspects
SpaceCraftAspectDefinitions = {
	-- Special Aspects
	player = playerAspectDefinition,

	-- Shape Aspects
	-- Default: Square
	circular = circularAspectDefinition,

	-- Motion Aspects
	-- Default: No velocity, but will move if collided with
	enemyLinear = linearAspectDefinition, -- Moves constant speed, in a line.
	enemyStatic = staticAspectDefinition, -- Will never move.  A Wall
	playerInputMotion = playerInputAspectDefinition,
	-- TODO: Craft with ossilating velocity
	-- TODO: Crafts that accelerate and deccelerate
	-- TODO: Teleporting enemy static.  Use a spining arc/circle that fills out to indicate location and timing.

	-- Collision (detection) Aspects
	-- Default: Collide with everything
	noEnemyCollision = noEnemyCollisionAspectDefinition,
	playerOnlyCollision = playerOnlyCollisionAspectDefinition,

	-- Collision (resolution) Aspects
	-- Default : Physics collision w/o game affect.
	deadly = deadlyAspectDefinition,
	stun = stunningAspectDefinition
	-- TODO: Player-friendly unit that kills other units, to clear out the map
	-- TODO: Enemy that hides other ships it collides with / overlaps
	-- TODO: Enemy that can exert gravity / repulsion.
	-- TODO: An enemy with totally static collisions, but very high initial velocity.
	-- TODO: Enemy that teleports the player to a random(?) location on collision. Not necessarily mutually exclusive with stun :3
	-- TODO: A stun variant that just/also makes you invisible.  It was a bug, but horrifying.
	--       Maybe that'd be a challenging Amp
	-- TODO: Could we have static objects with >1 restitution, aka, accelerator walls?

}

return SpaceCraftAspectDefinitions