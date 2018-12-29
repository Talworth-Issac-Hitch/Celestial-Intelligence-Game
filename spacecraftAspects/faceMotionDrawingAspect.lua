-- ASPECT DEFINITION --
-- For Craft which always face their exact direction of motion.
DrawFacingMotionAspectDefinition = {
	-- Draw facing the current direction of our craft's velocity
	getImageDrawAngle = function(self)
		-- If we've spawned then face the direction that we're traveling, otherwise, simply face our
		-- 'facing' direction, since don't have velocity till they are finished spawning.
		if self.finishedSpawn then 
			local craftDirection = getDirectionInRadiansFromVector(self.body:getLinearVelocity())
			return craftDirection
		else
			return self.body:getAngle()
		end
	end
}

return DrawFacingMotionAspectDefinition