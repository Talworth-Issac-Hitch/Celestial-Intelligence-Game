-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"
CollisionConstants = require "collisionConstants"

----------------------
-- CLASS DEFINITION -- 
----------------------

-- A wrapper for handling the game's physics.  
-- Currently uses Love2D's native Phsyics engine.
WorldPhysics = {}
WorldPhysics.__index = WorldPhysics

-- Constructor.  Builds a new Love2D World, and adds the game's level boundaries.
-- @return A newly constructed instance of WorldPhyiscs.
function WorldPhysics:new(options)
	local worldPhysics = {
		worldWidth = 800,
		worldHeight = 600,
		world = nil,
		debug = nil
	}

	setmetatable(worldPhysics, WorldPhysics)

	worldPhysics = _.extend(worldPhysics, options)

	-- Create Physics context 
	-- Set the height of the meter in pixels to 64
	love.physics.setMeter(64)

	-- Create a world, no gravity in either direction, because this is space damnit!
	worldPhysics.world = love.physics.newWorld(0, 0, true)

	-- Set collision callbacks to govern what happens for collisions
	worldPhysics.world:setCallbacks(
		_.bind(beginContactHandler, worldPhysics),
		_.bind(endContactHandler, worldPhysics),
		_.bind(preSolveHandler, worldPhysics),
		_.bind(postSolveHandler, worldPhysics)
	)
	worldPhysics.collisionDebugText = ""
	worldPhysics.persisting = 0

	worldPhysics:setupLevelBoundaries()

	return worldPhysics
end 


--------------------
-- LOVE CALLBACKS --
--------------------

-- The Love2D callback for time passing in the game.  Here we call Love2D' Physics' update, and log debug info about
--  the world physics.
-- @param dt The time interval since the last time love.update was called.
function WorldPhysics:update(dt)
	-- New Physics 
	self.world:update(dt)

	-- cleanup when 'text' gets too long
	-- TODO: Add a physics log for each session that we flush removed to text to.
	if string.len(self.collisionDebugText) > 768 then
		self.collisionDebugText = "" 
	end
end

-- The Love2D callback for each drawing frame. Draws our level boundaries
-- @param {number} alpha - How much alpha to draw the gameover screen with.
function WorldPhysics:draw(alpha)
	-- Print debug info on collisions and game boundaries
	if self.debug.physicsLog then
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.print(self.collisionDebugText, 10, 10)
	end

	if self.debug.physicsVisual then
		-- TODO: Make a map of collision types to visual colors
		love.graphics.setColor(0.28, 0.05, 0.63, alpha)
		love.graphics.polygon("fill", self.leftWall.body:getWorldPoints(self.leftWall.shape:getPoints()))
		love.graphics.polygon("fill", self.rightWall.body:getWorldPoints(self.rightWall.shape:getPoints()))
		love.graphics.polygon("fill", self.topWall.body:getWorldPoints(self.topWall.shape:getPoints()))
		love.graphics.polygon("fill", self.bottomWall.body:getWorldPoints(self.bottomWall.shape:getPoints()))

		love.graphics.reset()
	end 
end

-- Creates the boundaries of the level.  By default, the level is a simple square/
function WorldPhysics:setupLevelBoundaries()
	local wallCollisionData = {
		type = "wall",
		craft = nil
	}

	-- Create 4 walls for our box world
	self.leftWall = {}
	self.leftWall.body = love.physics.newBody(self.world, 0, self.worldHeight / 2, "static")
	self.leftWall.shape = love.physics.newRectangleShape(1, self.worldHeight)
	self.leftWall.fixture = love.physics.newFixture(self.leftWall.body, self.leftWall.shape)
	self.leftWall.fixture:setFilterData(CollisionConstants.CATEGORY_BOUNDARY, CollisionConstants.MASK_ALL, 0)
	self.leftWall.fixture:setUserData(wallCollisionData)

	self.rightWall = {}
	self.rightWall.body = love.physics.newBody(self.world, self.worldWidth, self.worldHeight / 2, "static")
	self.rightWall.shape = love.physics.newRectangleShape(1, self.worldHeight)
	self.rightWall.fixture = love.physics.newFixture(self.rightWall.body, self.rightWall.shape)
	self.rightWall.fixture:setFilterData(CollisionConstants.CATEGORY_BOUNDARY, CollisionConstants.MASK_ALL, 0)
	self.rightWall.fixture:setUserData(wallCollisionData)

	self.topWall = {}
	self.topWall.body = love.physics.newBody(self.world, self.worldWidth / 2, 0, "static")
	self.topWall.shape = love.physics.newRectangleShape(self.worldWidth, 1)
	self.topWall.fixture = love.physics.newFixture(self.topWall.body, self.topWall.shape)
	self.topWall.fixture:setFilterData(CollisionConstants.CATEGORY_BOUNDARY, CollisionConstants.MASK_ALL, 0)
	self.topWall.fixture:setUserData(wallCollisionData)

	self.bottomWall = {}
	self.bottomWall.body = love.physics.newBody(self.world, self.worldWidth / 2, self.worldHeight, "static")
	self.bottomWall.shape = love.physics.newRectangleShape(self.worldWidth, 1)
	self.bottomWall.fixture = love.physics.newFixture(self.bottomWall.body, self.bottomWall.shape)
	self.bottomWall.fixture:setFilterData(CollisionConstants.CATEGORY_BOUNDARY, CollisionConstants.MASK_ALL, 0)
	self.bottomWall.fixture:setUserData(wallCollisionData)
end

----------------------------
-- LOVE PHYSICS CALLBACKS --
----------------------------

-- Callback for anytime 2 Fixtures initially come into contact with one another.
-- Here we evaluate game logic involving player collisons.
function beginContactHandler(worldPhysics, fixtureA, fixtureB, coll)
	-- Log out information about the collision.
	if worldPhysics.debug.physicsLog then
		x,y = coll:getNormal()
		worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. "\n"
		worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. fixtureA:getUserData().type .. " colliding with "
		worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. fixtureB:getUserData().type .. " with a vector normal of : " 
		worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. x .. ", "
		worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. y
	end

	local aData = fixtureA:getUserData()
	local bData = fixtureB:getUserData()

	-- Currently we only have game-logic that gets tripped when the plyer is involved in a collision.
	-- TODO: Separate Game Logic, from the purely physics module?
	if  aData.type == "player" then 
		handlePlayerCollision(aData, bData)
	elseif bData.type == "player" then
		handlePlayerCollision(bData, aData)
	end
end

-- Callback for anytime 2 Fixtures initially come into contact with one another.  Currently we only log some information.
function endContactHandler(worldPhysics, fixtureA, fixtureB, coll)
	if worldPhysics.debug.physicsLog then
		worldPhysics.persisting = 0
		worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. "\n" .. fixtureA:getUserData().type .. " uncolliding with " .. fixtureB:getUserData().type
	end
end

-- Callback for before the resulting forces from the collision for each Fixture have been calculated.
-- Currently we just log out debug info, but I'm guessing here is where we could have game-logic / game-data, overule / impact physics.
function preSolveHandler(worldPhysics, fixtureA, fixtureB, coll)
	if worldPhysics.debug.physicsLog then
		if worldPhysics.persisting == 0 then
			worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. "\n" .. fixtureA:getUserData().type .. " touching " .. fixtureB:getUserData().type
		elseif worldPhysics.persisting < 20 then
			worldPhysics.collisionDebugText = worldPhysics.collisionDebugText .. " " .. worldPhysics.persisting
		end

		worldPhysics.persisting = worldPhysics.persisting + 1
	end
end

-- Callback for after the resulting forces from the collision for each Fixture have been calculated.
-- Currently we do nothing, but could add or remove force / impulse here I'm guessing?
function postSolveHandler(worldPhysics, fixtureA, fixtureB, coll, normalImpluse, tangentImpulse)
	-- Unused 
end


-----------
-- UTILS --
-----------

-- Handle the game-logic of what needs to happen when a player is involved in a crash.
function handlePlayerCollision(playerData, otherData)
	if otherData.type == "deadly" then
		playerData.craft:onDeath()
		love.event.push('playerDied', otherData.craft.name)
	elseif otherData.type == "stun" then
		playerData.craft.stunned = true
		playerData.craft.stunCounter = playerData.craft.stunCounter + 1
	end
end


-------------
-- GETTERS --
-------------

function WorldPhysics:getWorld()
	return self.world
end

return WorldPhysics