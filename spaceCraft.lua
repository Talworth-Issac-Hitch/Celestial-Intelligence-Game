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
		age=0
	}

	setmetatable(spaceCraft,SpaceCraft)

	_.extend(spaceCraft, options)	

	-- TODO: consider caching a table of images to avoid repeat loading in here
	--       as more spaceCraft (potentially with the same image) are spawned during the game
	spaceCraft.image = love.graphics.newImage(spaceCraft.imagePath)

	-- TODO: Get images that are properly sized to avoid scaling
	-- TODO2: Draw characters procedurally based on parameters rather using images
	spaceCraft.imgSX = spaceCraft.sizeX / spaceCraft.image:getWidth()
	spaceCraft.imgSY = spaceCraft.sizeY / spaceCraft.image:getHeight()

	return spaceCraft 
end 

-- TODO : Make bounds a bbox, rather than assuming 0,0 as p1
function SpaceCraft:update(dt, bounds)
	self.xPosition = self.xPosition + (self.xVelocity * dt)
	self.yPosition = self.yPosition + (self.yVelocity * dt)

	-- Ensure creature or player remains in the bounds of the level.

	if self.xPosition + self.sizeX > bounds.width then 
		self.xPosition = bounds.width - self.sizeX
		self.xVelocity = 0
	-- NOTE : With this statement as an elseifwe are currently assuming craftSize will always be less than the bounds size.
	elseif self.xPosition < 0 then 
		self.xPosition = 0
		self.xVelocity = 0
	end

	if self.yPosition + self.sizeY > bounds.height then 
		self.yPosition =  bounds.height - self.sizeY
		self.yVelocity = 0
	-- NOTE : With this statement as an elseifwe are currently assuming craftSize will always be less than the bounds size.
	elseif self.yPosition < 0 then 
		self.yPosition = 0
		self.yVelocity = 0
	end

	-- TODO: Colliding with the edge results in a hard, inelastic stop.

	self.age = self.age + dt
end

function SpaceCraft:draw()
	local blinkInterval = 7

	if self.age > 2 or math.ceil(self.age * blinkInterval) % 2 == 0 then
		love.graphics.draw(self.image, self.xPosition, self.yPosition, 0, self.imgSX, self.imgSY)
	end
end

return SpaceCraft