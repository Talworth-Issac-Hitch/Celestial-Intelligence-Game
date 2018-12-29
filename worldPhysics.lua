-- IMPORTS --
_ = require "libs/moses_min"
CollisionConstants = require "collisionConstants"

-- CLASS DEFINITION -- 
WorldPhysics = {}
WorldPhysics.__index = WorldPhysics

function WorldPhysics:new(options)
	local worldPhysics = {
		worldWidth = 800,
		worldHeight = 600,
		world = nil,
		debug = false
	}

	setmetatable(worldPhysics, WorldPhysics)

	worldPhysics = _.extend(worldPhysics, options)

	-- Create Physics context 
	-- Set the height of the meter in pixels to 64
	love.physics.setMeter(64)

	-- Create a world, no gravity in either direction, because this is space damnit!
	worldPhysics.world = love.physics.newWorld(0, 0, true)

	-- Set collision callbacks to govern what happens for collisions
	worldPhysics.world:setCallbacks(beginContactHandler, endContactHandler, preSolveHandler, postSolveHandler)
	worldPhysics.collisionDebugText = ""
	worldPhysics.persisting = 0

	-- Create us some boundaries. Bodies are bound by their center point.
	worldPhysics.leftWall = {}
	worldPhysics.leftWall.body = love.physics.newBody(worldPhysics.world, 0, worldPhysics.worldHeight / 2, "static")
	worldPhysics.leftWall.shape = love.physics.newRectangleShape(1, worldPhysics.worldHeight)
	worldPhysics.leftWall.fixture = love.physics.newFixture(worldPhysics.leftWall.body, worldPhysics.leftWall.shape)
	worldPhysics.leftWall.fixture:setFilterData(CollisionConstants.CATEGORY_BOUNDARY, CollisionConstants.MASK_ALL, 0)
	worldPhysics.leftWall.fixture:setUserData("wall")

	worldPhysics.rightWall = {}
	worldPhysics.rightWall.body = love.physics.newBody(worldPhysics.world, worldPhysics.worldWidth, worldPhysics.worldHeight / 2, "static")
	worldPhysics.rightWall.shape = love.physics.newRectangleShape(1, worldPhysics.worldHeight)
	worldPhysics.rightWall.fixture = love.physics.newFixture(worldPhysics.rightWall.body, worldPhysics.rightWall.shape)
	worldPhysics.rightWall.fixture:setFilterData(CollisionConstants.CATEGORY_BOUNDARY, CollisionConstants.MASK_ALL, 0)
	worldPhysics.rightWall.fixture:setUserData("wall")

	worldPhysics.topWall = {}
	worldPhysics.topWall.body = love.physics.newBody(worldPhysics.world, worldPhysics.worldWidth / 2, 0, "static")
	worldPhysics.topWall.shape = love.physics.newRectangleShape(worldPhysics.worldWidth, 1)
	worldPhysics.topWall.fixture = love.physics.newFixture(worldPhysics.topWall.body, worldPhysics.topWall.shape)
	worldPhysics.topWall.fixture:setFilterData(CollisionConstants.CATEGORY_BOUNDARY, CollisionConstants.MASK_ALL, 0)
	worldPhysics.topWall.fixture:setUserData("wall")

	worldPhysics.bottomWall = {}
	worldPhysics.bottomWall.body = love.physics.newBody(worldPhysics.world, worldPhysics.worldWidth / 2, worldPhysics.worldHeight, "static")
	worldPhysics.bottomWall.shape = love.physics.newRectangleShape(worldPhysics.worldWidth, 1)
	worldPhysics.bottomWall.fixture = love.physics.newFixture(worldPhysics.bottomWall.body, worldPhysics.bottomWall.shape)
	worldPhysics.bottomWall.fixture:setFilterData(CollisionConstants.CATEGORY_BOUNDARY, CollisionConstants.MASK_ALL, 0)
	worldPhysics.bottomWall.fixture:setUserData("wall")

	return worldPhysics
end 

function WorldPhysics:update(dt)
	-- New Physics 
	self.world:update(dt)

	-- cleanup when 'text' gets too long
	-- TODO: Add a physics log for each session
	if string.len(self.collisionDebugText) > 768 then
		self.collisionDebugText = "" 
	end
end

function WorldPhysics:draw()
	-- Print debug info on collisions and game boundaries
	if self.debug then
		love.graphics.print(self.collisionDebugText, 10, 10)

		-- TODO: Make a map of collision types to visual colors
		love.graphics.setColor(0.28, 0.05, 0.63)
		love.graphics.polygon("fill", self.leftWall.body:getWorldPoints(self.leftWall.shape:getPoints()))
		love.graphics.polygon("fill", self.rightWall.body:getWorldPoints(self.rightWall.shape:getPoints()))
		love.graphics.polygon("fill", self.topWall.body:getWorldPoints(self.topWall.shape:getPoints()))
		love.graphics.polygon("fill", self.bottomWall.body:getWorldPoints(self.bottomWall.shape:getPoints()))

		love.graphics.reset()
	end 
end

function beginContactHandler(fixtureA, fixtureB, coll)
	if worldPhysics.debug then
		x,y = coll:getNormal()
		worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. "\n"
		worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. fixtureA:getUserData() .. " colliding with "
		worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. fixtureB:getUserData() .. " with a vector normal of : " 
		worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. x .. ", "
		worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. y
	end

	local aType = fixtureA:getUserData()
	local bType = fixtureB:getUserData()

	-- If the play collides, game over
	-- TODO: Separate Game Logic, from the purely physics module?
	if  aType == "player" then 
		handlePlayerCollision(aType, bType)
	elseif bType == "player" then
		handlePlayerCollision(bType, aType)
	end
end

function endContactHandler(fixtureA, fixtureB, coll)
	if worldPhysics.debug then
		worldPhysics.persisting = 0
		worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. "\n" .. fixtureA:getUserData() .. " uncolliding with " .. fixtureB:getUserData()
	end
end

function preSolveHandler(fixtureA, fixtureB, coll)
	if worldPhysics.debug then
		if worldPhysics.persisting == 0 then
			worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. "\n" .. fixtureA:getUserData() .. " touching " .. fixtureB:getUserData()
		elseif worldPhysics.persisting < 20 then
			worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. " " .. worldPhysics.persisting
		end

		worldPhysics.persisting = worldPhysics.persisting + 1
	end
end

function postSolveHandler(fixtureA, fixtureB, coll, normalImpluse, tangentImpulse)
	-- Unused 
end

function handlePlayerCollision(playerData, otherData)
	if otherData == "deadly" then
		love.event.quit( )
	elseif otherData == "stun" then
		StunCounter = StunCounter + 1
		print("incrementing stun counter, now is : " .. StunCounter)
	end
end

function WorldPhysics:getWorld()
	return self.world
end

return WorldPhysics