-- IMPORTS --
playerAspectDefinition = require "spacecraftAspects/playerSpecialAspect"
faceAngleAspectDefinition = require "spacecraftAspects/faceAngleDrawingAspect"
faceMotionAspectDefinition = require "spacecraftAspects/faceMotionDrawingAspect"
deadlyAspectDefinition = require "spacecraftAspects/deadlyCollisionAspect"
linearAspectDefinition = require "spacecraftAspects/linearMotionAspect"
circularAspectDefinition = require "spacecraftAspects/circularShapeAspect"
staticAspectDefinition = require "spacecraftAspects/staticMotionAspect"
stunningAspectDefinition = require "spacecraftAspects/stunCollisionAspect"


-- ASPECT DEFINITIONS --
-- A table of aspect attributes to be applied on initialization
-- TODO: Make multiple nested tables to handle the mutally exclusive aspects
SpaceCraftAspectDefinitions = {
	-- Special Aspects
	player = playerAspectDefinition,

	-- Drawing Aspects
	-- Default facing is axis-aligned
	faceAngle = faceAngleAspectDefinition,
	faceMotion = faceMotionAspectDefinition,

	-- Shape Aspects
	circular = circularAspectDefinition,

	-- Motion Aspects
	enemyLinear = linearAspectDefinition,
	enemyStatic = staticAspectDefinition,
	-- TODO: An enemy that reacts to player key presses too.
	-- TODO: Craft with ossilating velocity
	-- TODO: Crafts that accelerate and deccelerate
	-- TODO: Teleporting enemy static.  Use a spining arc/circle that fills out to indicate location and timing.

	-- Collision (resolution) Aspects 
	deadly = deadlyAspectDefinition,
	stun = stunningAspectDefinition
	-- TODO: Player-friendly unit that does other units, to clear out the map
	-- TODO: Enemy that hides other ships it collides with / overlaps
	-- TODO: Enemy that can exert gravity / repulsion.
	-- TODO: An enemy with totally static collisions, but very high initial velocity.
	-- TODO: Enemy that teleports the player to a random(?) location on collision. Not necessarily mutually exclusive with stun :3

}

return SpaceCraftAspectDefinitions