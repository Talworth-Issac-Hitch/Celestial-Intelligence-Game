-- ASPECT DEFINITION --
-- For Craft which have a circular collision area.
CircularCraftAspectDefinition = {
	imagePath = "assets/evil-moon.png", 
	initializeShape = function(self) 
		return love.physics.newCircleShape(self.sizeX / 2)
	end,
	drawImage = function(self)
		local drawX, drawY = self:getCenterPoint()

		-- Compensate for the fact that circular collision when drawing square images
		-- Unlike square collision shapes that perfectly fit square images, circles on have their center point.
		drawX = drawX - (self.sizeX / 2)
		drawY = drawY - (self.sizeY / 2)

		love.graphics.draw(self.image, drawX, drawY, 0, self.imgSX, self.imgSY)
	end,
	debugDrawCollisionBorder = function(self)
		love.graphics.setColor(self.collisionDebugColor)
		local debugX, debugY = self:getCenterPoint()
		love.graphics.circle("line", debugX, debugY, self.sizeX / 2)
		love.graphics.reset()
	end
}

return CircularCraftAspectDefinition