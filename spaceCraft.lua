-- IMPORTS --
_ = require "moses_min"

-- CLASS DEFINITIONS --
SpaceCraft = {}
SpaceCraft.__index = SpaceCraft

-- ASPECT DEFINITIONS --
-- TODO: Make all these aspects their own files with a registry.
-- A table of aspect attributes to be applied on initialization
SpaceCraftAspectDefinitions = {
	player = {
		imagePath ="assets/pig.png", 
		sizeX = 50, 
		sizeY = 50,
		speed = 400, 

		collisionData = "player",

		collisionDebugColor = {0.05, 0.9, 0.05}
	},
	enemyStatic = {
		imagePath = "assets/head.png", 
		sizeX = 100, 
		sizeY = 100,
		speed = 0,

		bodyType = "static"
	},
	enemyLinear = {
		imagePath = "assets/metor.jpg",
		sizeX = 25, 
		sizeY = 25,
		speed = 250,
		initializeShape = function(self) 
			return love.physics.newCircleShape(self.sizeX / 2, self.sizeY / 2, self.sizeX / 2)
		end
	}
}

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
	

	if _.has(spaceCraft.aspects, "enemyLinear") then
		-- TODO: We'll figure you in second...
		local initAngle = love.math.random(0, 2 * math.pi)
		
		spaceCraft.xVelocity = math.sin(initAngle) * spaceCraft.speed
		spaceCraft.yVelocity = math.cos(initAngle) * spaceCraft.speed
	end

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

		-- TODO: Get this outta here and into a specific module implementation.  You playing a dangerous game boi.
		if _.has(self.aspects, "enemyLinear") then
			self.body:setLinearVelocity(self.xVelocity, self.yVelocity)

			-- preserve all linear momentum for now.  Set restitution to 1 since perfect elasticity 
			-- conservers momentum in a head-on collision, and friction to 0 to prevent linear velocity
			-- becoming angular velocity.
			self.fixture:setRestitution(1) 
			self.fixture:setFriction(0) 
		end

		self.finishedSpawn = true
	end
end

function SpaceCraft:draw()
	local blinkInterval = 7

	-- Enemies blink before they are finished spawning
	if self.finishedSpawn or math.ceil(self.age * blinkInterval) % 2 == 0 then
		local drawX, drawY
		if _.has(self.aspects, "enemyLinear") then
			drawX, drawY = self.body:getWorldPoints(self.shape:getPoint())
			-- Compensate for the fact that circular collision when drawing square images
			-- Unlike square collision shapes that perfectly fit square images, circles on have their center point.
			drawX = drawX - (self.sizeX / 2)
			drawY = drawY - (self.sizeY / 2)
		else 
			drawX, drawY = self.body:getWorldPoints(self.shape:getPoints())
		end

		love.graphics.draw(self.image, drawX, drawY, 0, self.imgSX, self.imgSY)
	end

	-- If we're debugging, draw collision board. Color of boarder indicates collsion type.
	if self.debug and self.finishedSpawn then
		love.graphics.setColor(self.collisionDebugColor)

		-- Should be dependent on having speed / velocity, not aspects...
		if _.has(self.aspects, "enemyLinear") then
			local debugX, debugY = self.body:getWorldPoints(self.shape:getPoint())
			love.graphics.circle("line", debugX, debugY, self.sizeX / 2)

			-- Additionally, draw a velocity indicator line
			local velocityX, velocityY = self.body:getLinearVelocity()
			love.graphics.setColor(0.7, 0.7, 0.05)
			love.graphics.line(debugX, debugY, debugX + velocityX / 5, debugY + velocityY / 5)
		else 
			love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
		end

		love.graphics.reset()
	end
end

function SpaceCraft:initializeShape()
	return love.physics.newRectangleShape(self.sizeX, self.sizeY)
end

return SpaceCraft