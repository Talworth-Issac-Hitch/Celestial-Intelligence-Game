-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which move start facing down rather than right, but otherwise have no angluar accelaration of their own.
DownStartingtAspectDefinition = {
	buttonImage = "assets/plain-arrow.png",
	
	-- Hook for any special modifications that need to be initially made to the Craft's Physics Body.
	-- We set a random facing angle, which differs from default, axis-aligned crafts.
	beforeBodySetup = function(self) 
		self.facingAngle =  math.pi / 2
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

return DownStartingtAspectDefinition