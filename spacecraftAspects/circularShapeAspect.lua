-- ASPECT DEFINITION --
-- For Craft which have a circular collision area.
CircularCraftAspectDefinition = {
	setImageOffset = function(self)
		self.imgOX = self.image:getWidth() / 2
		self.imgOY = self.image:getHeight() / 2
	end,
	initializeShape = function(self) 
		return love.physics.newCircleShape(self.sizeX / 2)
	end,
	getDrawingAnchor = function(self)
		-- We no longer need to do anything special, because we properly set the image offset when drawing, simply return center
		return self:getCenterPoint()
	end,
	debugDrawCollisionBorder = function(self)
		love.graphics.setColor(self.collisionDebugColor)
		local debugX, debugY = self:getCenterPoint()
		love.graphics.circle("line", debugX, debugY, self.sizeX / 2)
		love.graphics.reset()
	end
}

return CircularCraftAspectDefinition