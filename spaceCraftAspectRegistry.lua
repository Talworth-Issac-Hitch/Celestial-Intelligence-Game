-------------
-- IMPORTS --
-------------
playerAspectDefinition = require "spacecraftAspects/playerSpecialAspect"

waveFadingVisualAspectDefinition = require "spacecraftAspects/waveFadingVisualAspect"

circularAspectDefinition = require "spacecraftAspects/circularShapeAspect"

periodicRandomTeleportMotionAspectDefinition = require "spacecraftAspects/periodicRandomTeleportMotionAspect"

fixedInitialSpeedAspectDefinition = require "spacecraftAspects/fixedInitialSpeedAspect"
sinWaveFixedSpeedAspectDefinition = require "spacecraftAspects/sinWaveFixedSpeedAspect"
acceleratingSpeedAspectDefinition = require "spacecraftAspects/acceleratingSpeedAspect"
periodicImpulseSpeedAspectDefinition = require "spacecraftAspects/periodicImpulseSpeedAspect"
linearDampeningSpeedAspectDefinition = require "spacecraftAspects/linearDampeningSpeedAspect"

randomStartingDirectionAspectDefinition = require "spacecraftAspects/randomStartingDirectionAspect"
downStartingDirectionAspectDefinition = require "spacecraftAspects/downStartingDirectionAspect"
initialRotationAspectDefinition = require "spacecraftAspects/initialRotationAspect"

periodicAngularImpulseSpeedAspectDefinition = require "spacecraftAspects/periodicAngularImpulseSpeedAspect"

lowDensityAspectDefinition = require "spacecraftAspects/lowDensityAspect"

playerInputAspectDefinition = require "spacecraftAspects/playerInputMotionAspect"
staticAspectDefinition = require "spacecraftAspects/staticMotionAspect"

playerBorderCollisionAspectDefinition = require "spacecraftAspects/playerBorderCollisionAspect"
playerOnlyCollisionAspectDefinition = require "spacecraftAspects/playerOnlyCollisionAspect"
playerAndEnemyCollisionAspectDefinition = require "spacecraftAspects/playerEnemyCollisionAspect"

deadlyAspectDefinition = require "spacecraftAspects/deadlyCollisionAspect"
stunningAspectDefinition = require "spacecraftAspects/stunCollisionAspect"


-- A table of Aspect names to Aspect definitions/modules.
-- TODO: Make multiple nested tables to handle the mutally exclusive aspects
SpaceCraftAspectDefinitions = {
	-- Special Aspects
	player = playerAspectDefinition,
	-- TODO: Enemies that die with age

	-- Visual Aspects
	waveFadingVisibility = waveFadingVisualAspectDefinition,

	-- Shape Aspects
	-- Default: Square
	circular = circularAspectDefinition,

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