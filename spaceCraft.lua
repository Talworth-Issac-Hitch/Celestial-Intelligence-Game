-- IMPORTS --
_ = require "moses_min"
SpaceCraftAspectDefinitions = require "spaceCraftAspectRegistry"

-- CLASS DEFINITIONS --
SpaceCraft = {}
SpaceCraft.__index = SpaceCraft

-- CONSTANTS --
-- TODO: Create a collision Constants files, since these values are used by both worldPhysics and spaceCraft
-- NOTE: Global constants are slower to to access than locals.  Therefore for globals used many times in a 
--        given function, it makes more sense to copy it to a local, for performance reasons.
COLLISION_CATEGORY_DEFAULT = 0x0001
COLLISION_CATEGORY_BOUNDARY = 0x0002
COLLISION_CATEGORY_PLAYER = 0x0004
COLLISION_CATEGORY_ENEMY = 0x008

COLLISION_MASK_ALL = 0xFFFF

COLLISION_GROUP_NONE = 0

function SpaceCraft:new(options)
	-- Initialize our spaceCraft with defaults
	local spaceCraft = {
		imagePath = "assets/unknown.png", 
		imageRotationOffset = 0, -- TODO: Also allow the image's center point to be offset from 'collision' frame center.

		sizeX = 50, 
		sizeY = 50, 
		xPosition = 0, 
		yPosition = 0,
		xVelocity = 0, 
		yVelocity = 0,
		facingAngle = 0,
		angularVelocity = 0,
		angularDampening = 0,
		speed = 0,

		age = 0,
		stunned = false,

		world = nil,
		bodyType = "dynamic",
		collisionData = "non-lethal-enemy",
		collisionCategory = COLLISION_CATEGORY_DEFAULT,
		collisionMask = COLLISION_MASK_ALL,
		collisionGroup = COLLISION_GROUP_NONE,

		debug = false,
		collisionDebugColor = {0.05, 0.05, 0.9}
	}

	setmetatable(spaceCraft, SpaceCraft)

	spaceCraft = _.extend(spaceCraft, options)	

	-- For each aspect the SpaceCraft has, apply that aspect's initial paremters.  Remember here that aspect lists are Sets, not tables
	--  so we need to index by the AspectName, not the value
	_.each(spaceCraft.aspects, function(aspectVal, aspectName) 
		-- For each the parameters that Aspect Definition has 
		_.each(SpaceCraftAspectDefinitions[aspectName], function(aspectPropertyValue, aspectPropertyName)
			-- TODO: Better handling of Aspects that set the same property.  Currently they simply overwrite, last wins..
			spaceCraft[aspectPropertyName] = aspectPropertyValue
		end)
	end)

	-- TODO: Better logic for multiple scaling factors
	if spaceCraft.scalingFactor then
		spaceCraft:applyScaling(spaceCraft.scalingFactor)
	end

	spaceCraft:loadImageAndAttrs()

	spaceCraft:beforeBodySetup()

	-- Set up the space craft's Love2D Physics objects
	spaceCraft.body = love.physics.newBody(spaceCraft.world, spaceCraft.xPosition, spaceCraft.yPosition, spaceCraft.bodyType)
	spaceCraft.body:setAngle(spaceCraft.facingAngle)
	spaceCraft.body:setAngularVelocity(spaceCraft.angularVelocity)
	spaceCraft.body:setAngularDamping(spaceCraft.angularDampening)

	spaceCraft.shape = spaceCraft:initializeShape()

	return spaceCraft 
end 

function SpaceCraft:update(dt)
	self.age = self.age + dt

	-- Enemies should not be collidable until they have spawned, so we wait until then to add their world fixture.
	if not self.finishedSpawn and self.age > 2 then
		self.fixture = love.physics.newFixture(self.body, self.shape)

		-- TODO: Make collision data into Table / Set to enable more info for more different types of collisions.
		self.fixture:setFilterData(self.collisionCategory, self.collisionMask, self.collisionGroup)
		self.fixture:setUserData(self.collisionData)

		-- TODO: OH THIS SHIT WILL NOT STAND.  HANDLE YOUR (aspect-collision) SHIT!
		-- TODO: HANDLE YOUR SHIT
		self:onSpawnFinished()
		self:onSpawnFinished2()

		self.finishedSpawn = true
	end
end

function SpaceCraft:draw()
	local blinkInterval = 7

	-- Enemies blink before they are finished spawning
	if (self.finishedSpawn and not self.stunned) or math.ceil(self.age * blinkInterval) % 2 == 0 then
		self:drawImage()
	end

	-- If we're debugging, draw collision board. Color of boarder indicates collsion type.
	if self.debug and self.finishedSpawn then
		self:debugDrawCenter()

		self:debugDrawFacing()

		self:debugDrawCollisionBorder()

		-- Additionally if the craft currently has a velocity. draw a velocity indicator line
		if self.speed > 0 then
			self:debugDrawVelocityIndicator()
		end
	end
end

-- We can make him better, stronger...
function SpaceCraft:applyScaling(scalingFactor)
	self.sizeX = self.sizeX * scalingFactor
	self.sizeY = self.sizeY * scalingFactor
	self.speed = self.speed * scalingFactor
end

function SpaceCraft:beforeBodySetup()
	-- N0-0P, hook for others to override.
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

	self:setImageOffset()
end

function SpaceCraft:setImageOffset()
	-- Square Images require no offset
	self.imgOX = 0
	self.imgOY = 0
end

-- Initializes the SpaceCrafts shape for the purposes of physics and collisions.
function SpaceCraft:initializeShape()
	return love.physics.newRectangleShape(self.sizeX, self.sizeY)
end

function SpaceCraft:getCenterPoint()
	return self.body:getPosition()
end

function SpaceCraft:getDrawingAnchor()
	return self.body:getWorldPoints(self.shape:getPoints())
end

-- A hook for any SpaceCraft Behavior that should occur on spawn.
function SpaceCraft:onSpawnFinished()
	-- Do nothing by default
end
function SpaceCraft:onSpawnFinished2()
	-- God, damn, it.
end

function SpaceCraft:getImageDrawAngle()
	-- Default, square crafts simply always draw the image as axis aligned.
	return self.body:getAngle()
end

-- Draw the spaceCraft's image, if one exists.
function SpaceCraft:drawImage()
	local drawX, drawY = self:getDrawingAnchor()
	love.graphics.draw(self.image, drawX, drawY, self:getImageDrawAngle(), self.imgSX, self.imgSY, self.imgOX, self.imgOY)
end

-- Draws a dot on what is considered the center of the craft for physics purposes
function SpaceCraft:debugDrawCenter()
	local debugX, debugY = self.body:getPosition()
	love.graphics.setColor(self.collisionDebugColor)
	love.graphics.circle("fill", debugX, debugY, 5)

	love.graphics.reset()
end

-- Draws an arrow in the direction the object is "facing" for physics purposes
function SpaceCraft:debugDrawFacing()
	local centerX, centerY = self:getCenterPoint()
	local facingAngle = self.body:getAngle()

	local facingVectorX = math.cos(facingAngle) * 0.75 * self.sizeX
	local facingVectorY = math.sin(facingAngle) * 0.75 * self.sizeY

	love.graphics.setColor(0.6, 0.05, 0.6)
	love.graphics.line(centerX, centerY, centerX + facingVectorX, centerY + facingVectorY)

	love.graphics.reset()
end

-- Draws the shape that the Spacecraft is considered for collisions
function SpaceCraft:debugDrawCollisionBorder()
	love.graphics.setColor(self.collisionDebugColor)
	love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
	love.graphics.reset()
end

function SpaceCraft:debugDrawVelocityIndicator()
	local centerX, centerY = self:getCenterPoint()

	local velocityX, velocityY = self.body:getLinearVelocity()
	love.graphics.setColor(0.6, 0.6, 0.05)
	love.graphics.line(centerX, centerY, centerX + velocityX / 5 , centerY + velocityY / 5)
	love.graphics.reset()
end

return SpaceCraft