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
		speed=0
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

return SpaceCraft