-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"
CollisionConstants = require "collisionConstants"
SpaceCraftAspectDefinitions = require "spaceCraftAspectRegistry"


----------------------
-- CLASS DEFINITION --
----------------------

-- SpaceCrafts are (so far) the basic units for game entities.  Currently everything except the level bounds are SpaceCraft.
-- SpaceCrafts are built using a composition model, on top of this base.  
SpaceCraft = {}
SpaceCraft.__index = SpaceCraft

-- Constructor.  Applies our options and aspects to construct a new craft.  Then creates the physics entity, but does
--   does not yet fully add it to the world.
-- @return A newly constructed instance of a SpaceCraft.
function SpaceCraft:new(options)
	-- Initialize our spaceCraft with defaults
	local spaceCraft = {
		name = "Chaotic Entity",
		imagePath = "assets/unknown.png", 
		imageRotationOffset = 0, -- TODO: Also allow the image's center point to be offset from 'collision' frame center.

		sizeX = 64, 
		sizeY = 64,
		xPosition = 0, 
		yPosition = 0,
		xVelocity = 0, 
		yVelocity = 0,
		facingAngle = 0,
		angularVelocity = 0,
		angularDampening = 0,
		speed = 400,

		age = 0,
		stunned = false,

		world = nil,
		bodyType = "dynamic",
		collisionType = "non-lethal-enemy",
		collisionCategory = CollisionConstants.CATEGORY_DEFAULT,
		collisionMask = CollisionConstants.MASK_ALL,
		collisionGroup = CollisionConstants.GROUP_NONE,

		debug = nil,
		collisionDebugColor = {0.05, 0.05, 0.9}
	}

	setmetatable(spaceCraft, SpaceCraft)

	-- Layer in passed-in options.  These should typically be used for things not covered by aspects, generally things
	-- that are manually tweaked, like imagePath
	spaceCraft = _.extend(spaceCraft, options)

	local allAspectsScalingTable = {
		sizeX = 1,
		sizeY = 1,
		speed = 1
	}	

	-- For each aspect the SpaceCraft has, apply that aspect's initial paremters.  Remember here that aspect lists are Sets, not tables
	--  so we need to index by the AspectName, not the value
	_.each(spaceCraft.aspects, function(aspectVal, aspectName) 
		-- For each the parameters that Aspect Definition has 
		_.each(SpaceCraftAspectDefinitions[aspectName], function(aspectPropertyValue, aspectPropertyName)
			-- For the scaling factors, combine them all into one table.  For other properties and functions, simply
			-- overwrite or add.
			-- TODO: Better handling of Aspects that set the same property.  Currently they simply overwrite, last wins..
			if aspectPropertyName == "scalingTable" then
				_.each(aspectPropertyValue, function(scalingFactor, scalingFieldName) 
					allAspectsScalingTable[scalingFieldName] = allAspectsScalingTable[scalingFieldName] * scalingFactor
				end)
			else 
				spaceCraft[aspectPropertyName] = aspectPropertyValue
			end
		end)
	end)

	spaceCraft:applyScaling(allAspectsScalingTable)

	-- Set up our craft's image
	spaceCraft:loadImageAndAttrs()

	-- Set up the space craft's Love2D Physics objects
	spaceCraft.body = spaceCraft:initializeBody()
	spaceCraft.shape = spaceCraft:initializeShape()

	return spaceCraft 
end 


----------------------
-- LOVE2D CALLBACKS --
----------------------

-- The Love2D callback for time passing in the game. Handle general behavior related to age here.  
-- @param dt The time interval since the last time love.update was called.
function SpaceCraft:update(dt)
	-- The amount of lag time between when a craft appears, and when it is an active participant in the world.
	local SPAWN_WAIT_DURATION = 2

	self.age = self.age + dt

	-- Enemies should not be collidable until they have spawned, so we wait until then to add their world fixture.
	if not self.finishedSpawn and self.age > SPAWN_WAIT_DURATION then
		self:spawn()
	end

	self:onUpdate(dt)
end

-- The Love2D callback for each drawing frame. Draw our craft's image, and potentially debugging frames.
function SpaceCraft:draw(alpha)
	local blinkInterval = 7

	-- Enemies blink before they are finished spawning, to indicator that they cannot be interacted with.
	if (self.finishedSpawn and not self.stunned) or math.ceil(self.age * blinkInterval) % 2 == 0 then
		self:drawImage(alpha)
	end

	-- If we're debugging, draw collision board. Color of boarder indicates collsion type.
	if self.debug.physicsVisual and self.finishedSpawn then
		self:debugDrawCenter(alpha)

		self:debugDrawFacing(alpha)

		self:debugDrawCollisionBorder(alpha)

		-- Additionally if the craft currently has a velocity. draw a velocity indicator line
		if self.speed > 0 then
			self:debugDrawVelocityIndicator(alpha)
		end
	end
end


-----------------------------
-- GENERIC CRAFT BEHAVIORS --
-----------------------------

-- Applies scaling factor(s) that can come in from aspects to a spaceCraft's base attributes.
function SpaceCraft:applyScaling(scalingTable)
	-- For each entry in the scaling table, apply that scaling factor to the corresponding attribute.
	_.each(scalingTable, function(scalingFactor, attributeName)
		self[attributeName] = self[attributeName] * scalingFactor
	end)
end

-- Loads the SpaceCraft's image, and sets related properties
function SpaceCraft:loadImageAndAttrs()
	-- TODO: consider caching a table of images to avoid repeat loading in here
	--       as more spaceCraft (potentially with the same image) are spawned during the game
	self.image = love.graphics.newImage(self.imagePath)

	-- TODO: Get images that are properly sized to avoid scaling
	-- TODO2: Draw characters procedurally based on parameters rather using images
	self.imgSX = self.sizeX / self.image:getWidth()
	self.imgSY = self.sizeY / self.image:getHeight()

	self.imgOX, self.imgOY = self:setImageOffset()
end

-- Sets the anchor point for graphical transformations (like rotation) when drawing the Craft's image.
-- Since Crafts by default are square, and axis-aligned, images require no offset and just use top-left the corner.
-- @return [number, number] The x-axis and y-axis offsets respectively.
function SpaceCraft:setImageOffset()
	return 0, 0
end

-- Initializes the SpaceCrafts Body, which describes the Craft's motion (position, velocity, etc.) for the purposes of 
-- Ephysics and collisions.
-- @return Body A new Love2D physics body @see https://love2d.org/wiki/Body
function SpaceCraft:initializeBody()
	self:beforeBodySetup()

	-- Set up the space craft's Love2D Physics objects
	local body = love.physics.newBody(self.world, self.xPosition, self.yPosition, self.bodyType)
	body:setAngle(self.facingAngle)
	body:setAngularVelocity(self.angularVelocity)
	body:setAngularDamping(self.angularDampening)

	return body
end

-- Initializes the SpaceCrafts Shape for the purposes of physics and collisions.
-- By default Crafts are simply axis-aligned boxes.
function SpaceCraft:initializeShape()
	return love.physics.newRectangleShape(self.sizeX, self.sizeY)
end

-- Adds the (already-initialized) Craft to the World.  
-- We do this in Love2D by creating a new fixture.
function SpaceCraft:spawn()
	self.fixture = love.physics.newFixture(self.body, self.shape)

	-- Setup collision-related attributes.
	self.fixture:setFilterData(self.collisionCategory, self.collisionMask, self.collisionGroup)
	self.fixture:setUserData({
		type = self.collisionType,
		craft = self
	})

	self:onSpawnFinished()

	self.finishedSpawn = true
end


-------------
-- DRAWING --
-------------

-- Render the SpaceCraft's image to the screen, if one exists.
function SpaceCraft:drawImage(alpha)
	local drawX, drawY = self:getDrawingAnchor()
	love.graphics.setColor(1, 1, 1, alpha)
	love.graphics.draw(self.image, drawX, drawY, self:getImageDrawAngle() + self.imageRotationOffset, self.imgSX, self.imgSY, self.imgOX, self.imgOY)

	love.graphics.reset()
end

-------------------
-- DEBUG DRAWING --
-------------------

-- Draws a dot on what is considered the center of the Craft for physics purposes.
function SpaceCraft:debugDrawCenter(alpha)
	local debugX, debugY = self.body:getPosition()

	--TODO: Find a way to slot in alpha that doesn't permanently change self.collisionDebugColor.
	self.collisionDebugColor[4] = alpha
	love.graphics.setColor(self.collisionDebugColor)
	love.graphics.circle("fill", debugX, debugY, 5)

	love.graphics.reset()
end

-- Draws a line in the direction the object is "facing" for physics purposes.
function SpaceCraft:debugDrawFacing(alpha)
	local centerX, centerY = self:getCenterPoint()
	local facingAngle = self.body:getAngle()

	-- The line should extend just outside of the Craft's bounds.
	local facingVectorX = math.cos(facingAngle) * 0.75 * self.sizeX
	local facingVectorY = math.sin(facingAngle) * 0.75 * self.sizeY

	-- TODO: Make a debug color constants tab
	love.graphics.setColor(0.6, 0.05, 0.6, alpha)
	love.graphics.line(centerX, centerY, centerX + facingVectorX, centerY + facingVectorY)

	love.graphics.reset()
end

-- Draws the shape that the Spacecraft is considered for collisions.
-- By default, Crafts are squares, so we simple draw the same 4 points of our square Shape object.
function SpaceCraft:debugDrawCollisionBorder(alpha)
	--TODO: Find a way to slot in alpha that doesn't permanently change self.collisionDebugColor.
	self.collisionDebugColor[4] = alpha
	love.graphics.setColor(self.collisionDebugColor)
	love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
	love.graphics.reset()
end

-- Draws a line to indicat direct and speed of an object.  Speed is represented by length of the line.
-- TODO: Speed being represented by line-length, likely can't keep scaling well.  Perhaps increase thickness, or add more lines?
function SpaceCraft:debugDrawVelocityIndicator(alpha)
	local INDICATOR_LENGTH_FACTOR = 0.2
	local centerX, centerY = self:getCenterPoint()

	local velocityX, velocityY = self.body:getLinearVelocity()

	-- TODO: Make a debug color constants tab
	love.graphics.setColor(0.6, 0.6, 0.05, alpha)
	love.graphics.line(centerX, centerY, centerX + velocityX * INDICATOR_LENGTH_FACTOR, centerY + velocityY * INDICATOR_LENGTH_FACTOR)
	love.graphics.reset()
end


--------------------------
-- SpaceCraft Callbacks --
--------------------------

-- A hook for any custom behavior to occur during the Love2D update callback.
function SpaceCraft:onUpdate()
	-- Do nothing by default
end

-- Hook for any special modifications that need to be initially made to the Craft's Physics Body.
function SpaceCraft:beforeBodySetup()
	-- N0-0P, hook for aspects to override.
end

-- A hook for any SpaceCraft Behavior that should occur on spawn.
function SpaceCraft:onSpawnFinished()
	-- Do nothing by default
end


-------------
-- Getters --
-------------

-- Gets the center of the Craft, in terms of Physics.
function SpaceCraft:getCenterPoint()
	return self.body:getPosition()
end

-- Gets the point from which the Craft should be drawn (in terms of Graphics)
function SpaceCraft:getDrawingAnchor()
	return self.body:getWorldPoints(self.shape:getPoints())
end

-- Gets the angle (in terms of Graphics) that the drawn image be rotated.  Applied through a transformation.
-- By default, Crafts simply always draw the image as axis aligned.
function SpaceCraft:getImageDrawAngle()
	return 0
end

return SpaceCraft