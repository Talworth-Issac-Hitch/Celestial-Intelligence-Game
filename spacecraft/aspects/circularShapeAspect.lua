-----------------------
-- ASPECT DEFINITION --
-----------------------

-- A Craft that has a circular Shape/collision area.
CircularCraftAspectDefinition = {
	------------
	-- VISUAL --
	------------
	imagePath = "assets/cyber-eye.png",
	buttonImage = "assets/cyber-eye.png",

	-----------------------------
	-- GENERIC CRAFT BEHAVIORS --
	-----------------------------

	-- Sets the anchor point for graphical transformations (like rotation) when drawing the Craft's image.
	-- Circular Shapes need to rotate around their center point, not top-left.
	-- @return [number, number] The x-axis and y-axis offsets respectively.
	setImageOffset = function(self)
		return self.image:getWidth() / 2, self.image:getHeight() / 2
	end,

	-- Initializes the SpaceCrafts Shape to be a circle, for the purposes of physics and collisions.
	initializeShape = function(self) 
		return love.physics.newCircleShape(self.sizeX / 2)
	end,

	-- Grows or shrinks the shape based on scaling factor
	-- By default scales the rectangle shape in all directions.
	scaleShape = function(self, scalingFactor)
		if self:isSizeValid((self.sizeX * scalingFactor) * (self.sizeX * scalingFactor) * math.pi) then
			local fixtureShape = self.fixture:getShape()
			local scaledRadius = fixtureShape:getRadius() * scalingFactor
			fixtureShape:setRadius(scaledRadius)

			self.sizeX = self.sizeX * scalingFactor
			self.imgSX = self.imgSX * scalingFactor
			self.imgSY = self.imgSY * scalingFactor
		end
	end,

	-- Grows or shrinks the shape by a fixed amount
	-- By default change the circle shape's radius.
	addShapeSize = function(self, sizeToAdd)
		if self:isSizeValid((self.sizeX + sizeToAdd / 2) * (self.sizeX + sizeToAdd / 2) * math.pi) then
			local fixtureShape = self.fixture:getShape()
			local originalRadius = fixtureShape:getRadius()
			local newRadius = originalRadius + (sizeToAdd / 2)
			fixtureShape:setRadius(newRadius)

			self.sizeX = self.sizeX + sizeToAdd

			local scalingFactor = newRadius / originalRadius

			self.imgSX = self.imgSX * scalingFactor
			self.imgSY = self.imgSY * scalingFactor
		end
	end,

	-------------------
	-- DEBUG DRAWING --
	-------------------

	-- Draws the shape that the Spacecraft is considered for collisions, a circle.
	debugDrawCollisionBorder = function(self)
		love.graphics.setColor(self.collisionDebugColor)
		local debugX, debugY = self:getCenterPoint()
		love.graphics.circle("line", debugX, debugY, self.sizeX / 2)
		love.graphics.reset()
	end,


	-------------
	-- GETTERS --
	-------------

	-- Gets the point from which the Craft should be drawn (in terms of Graphics).  We draw from the center of our circle.
	getDrawingAnchor = function(self, fromPoints)
		if fromPoints then
			return fromPoints.x, fromPoints.y
		else
			return self:getCenterPoint()
		end
	end
}

return CircularCraftAspectDefinition