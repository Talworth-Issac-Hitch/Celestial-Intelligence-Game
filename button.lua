-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"


----------------------
-- CLASS DEFINITION --
----------------------

-- SpaceCrafts are (so far) the basic units for game entities.  Currently everything except the level bounds are SpaceCraft.
-- SpaceCrafts are built using a composition model, on top of this base.  
Button = {}
Button.__index = Button

-- Constructor.  Loads our button's image.
-- @return A newly constructed instance of a SpaceCraft.
function Button:new(options)
	-- Initialize our button with defaults
	local button = {
		name = "Chaotic Entity",
		imagePath = "assets/head.png", 

		xPosition = 0, 
		yPosition = 0,
		width = 64, 
		height = 64,

		active = false,
		onClick = nil
	}

	setmetatable(button, Button)

	-- Layer in passed-in options.  
	button = _.extend(button, options)

	-- Set up our craft's image
	button:loadImageAndAttrs()

	return button 
end 


----------------------
-- LOVE2D CALLBACKS --
----------------------

-- The Love2D callback for each drawing frame. Draw our craft's image, and potentially debugging frames.
function Button:draw()
	if self.active then
		love.graphics.setColor(0.2, 0.2, 0.8)
	else
		love.graphics.setColor(1, 1, 1)
	end

	love.graphics.draw(self.image, self.x, self.y, 0, self.imgSX, self.imgSY, self.imgOX, self.imgOY)

	love.graphics.reset()
end

-- Checks if the button was clicked and perform action if it was clicked.
function Button:checkClick(x, y, button, istouch, presses)
	local x2 = self.x + self.width
	local y2 = self.y + self.height
	if x >= self.x and x <= x2 and y >= self.y and y <= y2 then
		self.active = not self.active
		self.onClick(self.active)
		-- TODO: Actually perform the button's assigned task
	end
end

-- Loads the button's image, and sets related properties
function Button:loadImageAndAttrs()
	-- TODO: consider caching a table of images to avoid repeat loading in here
	--       as more spaceCraft (potentially with the same image) are spawned during the game
	self.image = love.graphics.newImage(self.imagePath)

	-- TODO: Get images that are properly sized to avoid scaling
	-- TODO2: Draw characters procedurally based on parameters rather using images
	self.imgSX = self.width / self.image:getWidth()
	self.imgSY = self.height / self.image:getHeight()

	self.imgOX, self.imgOY = 0
end



return Button