-- IMPORTS --
--_ = require "moses_min"

-- CLASS DEFINITIONS --
SpaceCraft = {}
SpaceCraft.__index = SpaceCraft

function SpaceCraft:new(options)
	-- Initialize our spaceCraft with defaults
	local spaceCraft = {
		imagePath="assets/unknown.png", 
		sizeX=100, 
		sizeY=100, 
		xPosition=0, 
		yPosition=0,
		xVelocity=0, 
		yVelocity=0, 
		speed=0,
		age=0,
		aspects="enemy",
		world=nil
	}

	setmetatable(spaceCraft, SpaceCraft)

	_.extend(spaceCraft, options)	

	-- TODO: consider caching a table of images to avoid repeat loading in here
	--       as more spaceCraft (potentially with the same image) are spawned during the game
	spaceCraft.image = love.graphics.newImage(spaceCraft.imagePath)

	-- TODO: Get images that are properly sized to avoid scaling
	-- TODO2: Draw characters procedurally based on parameters rather using images
	spaceCraft.imgSX = spaceCraft.sizeX / spaceCraft.image:getWidth()
	spaceCraft.imgSY = spaceCraft.sizeY / spaceCraft.image:getHeight()

	-- TODO: Better "aspect" logic
	bodyType = "static"
	if spaceCraft.aspects == "player" then
		bodyType = "dynamic"
	end

	-- Set up the space craft's Love2D Physics objects
	spaceCraft.body = love.physics.newBody(spaceCraft.world, spaceCraft.xPosition, spaceCraft.yPosition, bodyType)
	spaceCraft.shape = love.physics.newRectangleShape(spaceCraft.sizeX, spaceCraft.sizeY)

	return spaceCraft 
end 

function SpaceCraft:update(dt)
	self.age = self.age + dt

	-- Enemies should not be collidable until they have spawned, so we wait until then to add their world fixture.
	if not self.finishedSpawn and self.age > 2 then
		self.fixture = love.physics.newFixture(self.body, self.shape)
		self.fixture:setUserData(self.aspects)
		self.finishedSpawn = true
	end
end

function SpaceCraft:draw()
	local blinkInterval = 7

	-- Enemies blink before they are finished spawning
	if self.finishedSpawn or math.ceil(self.age * blinkInterval) % 2 == 0 then
		local drawX, drawY = self.body:getWorldPoints(self.shape:getPoints())
		love.graphics.draw(self.image, drawX, drawY, 0, self.imgSX, self.imgSY)
	end
end

return SpaceCraft