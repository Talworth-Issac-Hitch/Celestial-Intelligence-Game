-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which move in a straight line, in a (somewhat) constant fashion.
LinearCraftAspectDefinition = {
	-- Hook for any special modifications that need to be initially made to the Craft's Physics Body.
	-- We set a random facing angle, which differs from default, axis-aligned crafts.
	beforeBodySetup = function(self) 
		self.facingAngle = love.math.random(0, 2 * math.pi)
	end,

	-- A hook for any SpaceCraft Behavior that should occur on spawn.
	-- Set up our initial velocity, based on our speed and facing angle.
	onSpawnFinished = function(self)	
		self.xVelocity = math.cos(self.facingAngle) * self.speed
		self.yVelocity = math.sin(self.facingAngle) * self.speed

		self.body:setLinearVelocity(self.xVelocity, self.yVelocity)

		local craftDirection = getDirectionInRadiansFromVector(self.body:getLinearVelocity())
		
		-- preserve all linear momentum for now.  Set restitution to 1 since perfect elasticity 
		-- conservers momentum in a head-on collision, and friction to 0 to prevent linear velocity
		-- becoming angular velocity.
		self.fixture:setRestitution(1) 
		self.fixture:setFriction(0) 
	end

	-- Gets the angle (in terms of Graphics) that the drawn image be rotated.  Applied through a transformation.
	-- Our draw facing the current direction of our craft's velocity.
	-- MAYBE Needed to avoid confusion for facing direction
	-- getImageDrawAngle = function(self)
	-- 	-- If we've spawned then face the direction that we're traveling, otherwise, simply face our
	-- 	-- 'facing' direction, since don't have velocity till they are finished spawning.
	-- 	if self.finishedSpawn then 
	-- 		local craftDirection = getDirectionInRadiansFromVector(self.body:getLinearVelocity())
	-- 		return craftDirection
	-- 	else
	-- 		return self.body:getAngle()
	-- 	end
	-- end
}

return LinearCraftAspectDefinition