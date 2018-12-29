-- ASPECT DEFINITION --

-- UTILS -- 
function getDirectionInRadiansFromVector(vectorXComponet, vectorYComponent)
	return math.atan2(vectorYComponent, vectorXComponet)
end

-- For Craft which move in a straight line, in a (somewhat) constant fashion.
LinearCraftAspectDefinition = {
	sizeX = 32, 
	sizeY = 32,
	speed = 250,
	beforeBodySetup = function(self) 
		self.facingAngle = love.math.random(0, 2 * math.pi)
	end,
	-- Set up our initial speed
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
}

return LinearCraftAspectDefinition