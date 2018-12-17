-- IMPORTS --
--_ = require "moses_min"

-- CLASS DEFINITIONS --
SpaceCraft = {}
SpaceCraft.__index = SpaceCraft

function SpaceCraft:new(options)
	-- Initialize our spaceCraft with defaults
	local spaceCraft = {
		imagePath = "assets/unknown.png", 
		sizeX = 100, 
		sizeY = 100, 
		xPosition = 0, 
		yPosition = 0,
		xVelocity = 0, 
		yVelocity = 0, 
		speed = 0,
		age = 0,
		aspects ="enemyStatic",
		world = nil,
		debug = false,
		collisionDebugColor = {0.9, 0.05, 0.05}
	}

	setmetatable(spaceCraft, SpaceCraft)

	_.extend(spaceCraft, options)	

	-- TODO: Better "aspect" logic
	bodyType = "dynamic"
	if spaceCraft.aspects == "player" then	
		spaceCraft.collisionDebugColor = {0.05, 0.9, 0.05}
	elseif spaceCraft.aspects == "enemyStatic" then
		bodyType = "static"
	elseif spaceCraft.aspects == "enemyLinear" then
		spaceCraft.imagePath = "assets/metor.jpg"
		spaceCraft.speed = 500
		local initAngle = math.random(0, 2 * math.pi)
		
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
	spaceCraft.body = love.physics.newBody(spaceCraft.world, spaceCraft.xPosition, spaceCraft.yPosition, bodyType)

	if spaceCraft.aspects == "enemyLinear" then
		spaceCraft.shape = love.physics.newCircleShape(spaceCraft.sizeX / 2, spaceCraft.sizeY / 2, spaceCraft.sizeX / 2)
	else 
		spaceCraft.shape = love.physics.newRectangleShape(spaceCraft.sizeX, spaceCraft.sizeY)
	end

	return spaceCraft 
end 

function SpaceCraft:update(dt)
	self.age = self.age + dt

	-- Enemies should not be collidable until they have spawned, so we wait until then to add their world fixture.
	if not self.finishedSpawn and self.age > 2 then
		self.fixture = love.physics.newFixture(self.body, self.shape)
		self.fixture:setUserData(self.aspects)

		-- TODO: Get this outta here and into a specific module implementation.  You playing a dangerous game boi.
		if self.aspects == "enemyLinear" then
			self.body:setLinearVelocity(self.xVelocity, self.yVelocity)
			self.fixture:setRestitution(1) 
		end

		self.finishedSpawn = true
	end
end

function SpaceCraft:draw()
	local blinkInterval = 7

	-- Enemies blink before they are finished spawning
	if self.finishedSpawn or math.ceil(self.age * blinkInterval) % 2 == 0 then
		local drawX, drawY
		if self.aspects == "enemyLinear" then
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

		if self.aspects == "enemyLinear" then
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

return SpaceCraft