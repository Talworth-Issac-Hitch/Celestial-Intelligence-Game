-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which will intermittedly teleport to a random position.
PeriodicRandomTeleportMotionAspectDefinition = {
	buttonImage = "assets/teleport.png",
	scalingTable = {
		speed = 0.6
	},

	-- A hook for any custom behavior to occur during the Love2D update callback.
	-- Teleports the craft
	onUpdate = function(self, dt)
		if self.finishedSpawn then
			local roundedAge = math.ceil(self.age)

			-- If this is whole second, and a third second
			if roundedAge > math.ceil(self.age - dt) and roundedAge % 6 == 0 then
				self.currentAlpha = 1 --TODO: Chain alpha like scaling table?
				self.body:setX(self.nextX) 
				self.body:setY(self.nextY)
				self.nextX, self.nextY = nil
			elseif roundedAge > math.ceil(self.age - dt) and roundedAge % 6 == 5 then
				-- Change alpha as a warning of teleport
				self.currentAlpha = 0.5
				self.nextX = love.math.random(0, self.world.worldWidth)
				self.nextY = love.math.random(0, self.world.worldHeight)
			end
		end
	end,

	-- Show a 'ghost' at the teleport destination
	onDrawImage = function(self, globalAlpha)
		-- TODO: Global table of blink intervals for visual distinct-ness and consistency ?
		local blinkInterval = 13
		if(self.nextX and self.nextY and math.ceil(self.age * blinkInterval) % 2 == 0 ) then
			self:drawImage(global, {x = self.nextX, y = self.nextY})
		end
	end
}

return PeriodicRandomTeleportMotionAspectDefinition