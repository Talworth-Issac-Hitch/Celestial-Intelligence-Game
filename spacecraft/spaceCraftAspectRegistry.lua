-------------
-- IMPORTS --
-------------
playerAspectDefinition = require "spacecraft/aspects/playerSpecialAspect"

waveFadingVisualAspectDefinition = require "spacecraft/aspects/waveFadingVisualAspect"

circularAspectDefinition = require "spacecraft/aspects/circularShapeAspect"

periodicRandomTeleportMotionAspectDefinition = require "spacecraft/aspects/motion/periodicRandomTeleportMotionAspect"

fixedInitialSpeedAspectDefinition = require "spacecraft/aspects/motion/fixedInitialSpeedAspect"
sinWaveFixedSpeedAspectDefinition = require "spacecraft/aspects/motion/sinWaveFixedSpeedAspect"
acceleratingSpeedAspectDefinition = require "spacecraft/aspects/motion/acceleratingSpeedAspect"
periodicImpulseSpeedAspectDefinition = require "spacecraft/aspects/motion/periodicImpulseSpeedAspect"
linearDampeningSpeedAspectDefinition = require "spacecraft/aspects/motion/linearDampeningSpeedAspect"

randomStartingDirectionAspectDefinition = require "spacecraft/aspects/randomStartingDirectionAspect"
downStartingDirectionAspectDefinition = require "spacecraft/aspects/downStartingDirectionAspect"
initialRotationAspectDefinition = require "spacecraft/aspects/motion/initialRotationAspect"

periodicAngularImpulseSpeedAspectDefinition = require "spacecraft/aspects/motion/periodicAngularImpulseSpeedAspect"

lowDensityAspectDefinition = require "spacecraft/aspects/lowDensityAspect"

playerInputAspectDefinition = require "spacecraft/aspects/motion/playerInputMotionAspect"
staticAspectDefinition = require "spacecraft/aspects/motion/staticMotionAspect"

playerBorderCollisionAspectDefinition = require "spacecraft/aspects/collision/playerBorderCollisionAspect"
playerOnlyCollisionAspectDefinition = require "spacecraft/aspects/collision/playerOnlyCollisionAspect"
playerAndEnemyCollisionAspectDefinition = require "spacecraft/aspects/collision/playerEnemyCollisionAspect"

deadlyAspectDefinition = require "spacecraft/aspects/collision/deadlyCollisionAspect"
stunningAspectDefinition = require "spacecraft/aspects/collision/stunCollisionAspect"


-- A table of Aspect names to Aspect definitions/modules.
SpaceCraftAspectDefinitions = {
	-- Special Aspects
	player = playerAspectDefinition,
	-- TODO: Enemies that die with age
	-- TODO: Enemies that die with a certain number of collisions
	-- TODO: Win object enemy?

	-- Visual Aspects
	waveFadingVisibility = waveFadingVisualAspectDefinition,
	-- TODO: Also allow the image's center point to be offset from 'collision' frame center.

	-- Shape Aspects
	-- Default: Square
	circular = circularAspectDefinition,
	-- TODO: Growing or shrinking

	-- TODO: Swap places with the player.

	-- Motion Aspects

	-- Motion - Positional Aspects:
	randomTeleport = periodicRandomTeleportMotionAspectDefinition,

	-- Motion - Directional Aspects:
	--	Aspects that govern the craft's direction of motion, and change in direction.
	-- Default: Faces right
	randomInitDir = randomStartingDirectionAspectDefinition,
	downInitDir = downStartingDirectionAspectDefinition,
	initRotation = initialRotationAspectDefinition,
	periodicAngularImpulse = periodicAngularImpulseSpeedAspectDefinition,

	lowDensity = lowDensityAspectDefinition,
	
	-- Motion - Speed Aspects:
	--	Aspects that govern a craft's speed or change of speed in it's direction.  
	-- Default : No motion, but will move if collided with.
	fixedInitialSpeed = fixedInitialSpeedAspectDefinition, -- Moves constant speed, in a line.
	waveFixedSpeed = sinWaveFixedSpeedAspectDefinition,
	acceleratingSpeed = acceleratingSpeedAspectDefinition, -- Unendingly accelerates toward it's facing direction.
	periodicImpulseSpeed = periodicImpulseSpeedAspectDefinition,
	linearDampening = linearDampeningSpeedAspectDefinition,
	-- TODO: Craft with ossilating velocity
	-- TODO: Crafts that accelerate and deccelerate

	-- Motion - Special: 
	--	Special Motion aspects that are override aspects of other motion aspects.
	enemyStatic = staticAspectDefinition, -- Will never move.  A Wall
	playerInputMotion = playerInputAspectDefinition, -- Currently Governs speed and direction.
	-- TODO: Seperate WASD motion and arrow keys motion into separate aspects.  Because reasons :3
	-- TODO: Add a secondary player motion aspect, for rotate & accelerate facing motion. 

	-- Motion - Misc: 
	--	Miscellaneous aspects that do not interfere with other motion aspects.
	-- TODO: Teleporting enemy static.  Use a spining arc/circle that fills out to indicate location and timing.

	-- Game Visual Aspects:
	-- TODO: Fading an enemy's alpha value ossilates between visible and totally invisible.

	-- Collision (detection) Aspects
	-- Default: Collide with everything
	playerBorderCollision = playerBorderCollisionAspectDefinition,
	playerOnlyCollision = playerOnlyCollisionAspectDefinition,
	playerAndEnemyCollision = playerAndEnemyCollisionAspectDefinition,
	-- TODO: Enemies that only collide sometimes.

	-- Collision (resolution) Aspects
	-- Default : Physics collision w/o game affect.
	deadly = deadlyAspectDefinition,
	stun = stunningAspectDefinition
	-- TODO: Player-friendly unit that kills other units, to clear out the map
	-- TODO: Enemy that hides other ships it collides with / overlaps
	-- TODO: Enemy that can exert gravity / repulsion.
	-- TODO: An enemy with totally static collisions, but very high initial velocity.
	-- TODO: Enemy that teleports the player to a random(?) location on collision. Not necessarily mutually exclusive with stun :3
	-- TODO: A collision variant that just/also makes you invisible.  It was a bug, but horrifying.
	--       Maybe that'd be a challenging Amp
	-- TODO: Mutator Collision type that adds a random aspect on collsions.  Fun for both players and enemies.
	-- TODO: Simplifier Collision type - Removes a random aspect on impact. 
	-- TODO: Could we have static objects with >1 restitution, aka, accelerator walls?

}

return SpaceCraftAspectDefinitions