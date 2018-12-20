-- IMPORTS --
_ = require "moses_min"
SpaceCraftAspectDefinitions = require "spaceCraftAspectRegistry"

-- CLASS DEFINITIONS --
SpaceCraft = {}
SpaceCraft.__index = SpaceCraft


function SpaceCraft:new(options)
	-- Initialize our spaceCraft with defaults
	local spaceCraft = {
		imagePath = "assets/unknown.png", 
		sizeX = 50, 
		sizeY = 50, 
		xPosition = 0, 
		yPosition = 0,
		xVelocity = 0, 
		yVelocity = 0, 
		speed = 0,
		age = 0,

		world = nil,
		bodyType = "dynamic",
		collisionData = "enemy",

		debug = false,
		collisionDebugColor = {0.9, 0.05, 0.05}
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

	-- TODO: consider caching a table of images to avoid repeat loading in here
	--       as more spaceCraft (potentially with the same image) are spawned during the game
	spaceCraft.image = love.graphics.newImage(spaceCraft.imagePath)

	-- TODO: Get images that are properly sized to avoid scaling
	-- TODO2: Draw characters procedurally based on parameters rather using images
	spaceCraft.imgSX = spaceCraft.sizeX / spaceCraft.image:getWidth()
	spaceCraft.imgSY = spaceCraft.sizeY / spaceCraft.image:getHeight()

	-- Set up the space craft's Love2D Physics objects
	spaceCraft.body = love.physics.newBody(spaceCraft.world, spaceCraft.xPosition, spaceCraft.yPosition, spaceCraft.bodyType)
	spaceCraft.shape = spaceCraft:initializeShape()

	return spaceCraft 
end 

function SpaceCraft:update(dt)
	self.age = self.age + dt

	-- Enemies should not be collidable until they have spawned, so we wait until then to add their world fixture.
	if not self.finishedSpawn and self.age > 2 then
		self.fixture = love.physics.newFixture(self.body, self.shape)

		-- TODO: Make collision data into Table / Set to enable more info for more different types of collisions.
		self.fixture:setUserData(self.collisionData)

		self:onSpawnFinished()

		self.finishedSpawn = true
	end
end

function SpaceCraft:draw()
	local blinkInterval = 7

	-- Enemies blink before they are finished spawning
	if self.finishedSpawn or math.ceil(self.age * blinkInterval) % 2 == 0 then
		self:drawImage()
	end

	-- If we're debugging, draw collision board. Color of boarder indicates collsion type.
	if self.debug and self.finishedSpawn then
		self:debugDrawCollisionBorder()

		-- Additionally if the craft currently has a velocity. draw a velocity indicator line
		if self.speed > 0 then
			self:debugDrawVelocityIndicator()
		end
	end
end

-- Initializes the SpaceCrafts shape for the purposes of physics and collisions.
function SpaceCraft:initializeShape()
	return love.physics.newRectangleShape(self.sizeX, self.sizeY)
end

function SpaceCraft:getCenterPoint()
	return self.body:getPosition()
end

-- A hook for any SpaceCraft Behavior that should occur on spawn.
function SpaceCraft:onSpawnFinished()
	-- Do nothing by default
end

-- Draw the spaceCraft's image, if one exists.
function SpaceCraft:drawImage()
	local drawX, drawY = self.body:getWorldPoints(self.shape:getPoints())
	love.graphics.draw(self.image, drawX, drawY, 0, self.imgSX, self.imgSY)
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
	love.graphics.setColor(0.7, 0.7, 0.05)
	love.graphics.line(centerX, centerY, centerX + velocityX / 5, centerY + velocityY / 5)
	love.graphics.reset()
end

return SpaceCraft