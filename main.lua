-- IMPORTS --
_ = require "moses_min"
SpaceCraft = require "spaceCraft"


-- CONSTANTS -- 
VIEWPORT_HEIGHT = 800
VIEWPORT_WIDTH = 1200

-- TODO: Actually use this, to differentiate between playable and screenspace.
PLAYABLE_AREA_HEIGHT = 600
PLAYABLE_AREA_WIDTH = 800

DEBUG = true

-- LOVE CALLBACKS -- 

function love.load()
	-- Set background to blue
	love.window.setMode(VIEWPORT_WIDTH, VIEWPORT_HEIGHT)

	-- Create Physics context 
	-- TODO - Make this its own module / file
	-- Set the height of the meter in pixels to 64
	love.physics.setMeter(64)

	-- Create a world, no gravity in either direction, because this is space damnit!
	physicsWorld = love.physics.newWorld(0, 0, true)

	-- Set collision callbacks to govern what happens for collisions
	physicsWorld:setCallbacks(beginContactHandler, endContactHandler, preSolveHandler, postSolveHandler)
	collisionDebugText = ""
	persisting = 0

	-- Create us some boundaries

	-- Bodies are bound by their center point.  Our floor has a height of 50
	leftWall = {}
	leftWall.body = love.physics.newBody(physicsWorld, 0, VIEWPORT_HEIGHT / 2, "static")
	leftWall.shape = love.physics.newRectangleShape(1, VIEWPORT_HEIGHT)
	leftWall.fixture = love.physics.newFixture(leftWall.body, leftWall.shape)
	leftWall.fixture:setUserData("wall")

	rightWall = {}
	rightWall.body = love.physics.newBody(physicsWorld, VIEWPORT_WIDTH, VIEWPORT_HEIGHT / 2, "static")
	rightWall.shape = love.physics.newRectangleShape(1, VIEWPORT_HEIGHT)
	rightWall.fixture = love.physics.newFixture(rightWall.body, rightWall.shape)
	rightWall.fixture:setUserData("wall")

	topWall = {}
	topWall.body = love.physics.newBody(physicsWorld, VIEWPORT_WIDTH / 2, 0, "static")
	topWall.shape = love.physics.newRectangleShape(VIEWPORT_WIDTH, 1)
	topWall.fixture = love.physics.newFixture(topWall.body, topWall.shape)
	topWall.fixture:setUserData("wall")

	bottomWall = {}
	bottomWall.body = love.physics.newBody(physicsWorld, VIEWPORT_WIDTH / 2, VIEWPORT_HEIGHT, "static")
	bottomWall.shape = love.physics.newRectangleShape(VIEWPORT_WIDTH, 1)
	bottomWall.fixture = love.physics.newFixture(bottomWall.body, bottomWall.shape)
	bottomWall.fixture:setUserData("wall")

	-- TODO : Convert to physics objects
	activeCrafts = {
		playerCraft = SpaceCraft:new {
			imagePath="assets/pig.png", sizeX=100, sizeY=100, xPosition=75, yPosition=75,
			xVelocity=10, yVelocity=0, speed=400, age=2, aspects="player", world=physicsWorld
		}
	}

	score = 0
end

function beginContactHandler(fixtureA, fixtureB, coll)
	x,y = coll:getNormal()
	collisionDebugText = collisionDebugText .. "\n"
	collisionDebugText = collisionDebugText .. fixtureA:getUserData() .. " colliding with "
	collisionDebugText = collisionDebugText .. fixtureB:getUserData() .. " with a vector normal of : " 
	collisionDebugText = collisionDebugText .. x .. ", "
	collisionDebugText = collisionDebugText .. y

	local aType = fixtureA:getUserData()
	local bType = fixtureB:getUserData()

	-- If the play collides, game over 
	if  (aType == "player" and bType ~= "wall") or (bType == "player" and aType ~= "wall") then 
		love.event.quit( )
	end
end

function endContactHandler(fixtureA, fixtureB, coll)
	persisting = 0
	collisionDebugText = collisionDebugText .. "\n" .. fixtureA:getUserData() .. " uncolliding with " .. fixtureB:getUserData()
end

function preSolveHandler(fixtureA, fixtureB, coll)
	if persisting == 0 then
		collisionDebugText = collisionDebugText .. "\n" .. fixtureA:getUserData() .. " touching " .. fixtureB:getUserData()
	elseif persisting < 20 then
		collisionDebugText = collisionDebugText .. " " .. persisting
	end

	persisting = persisting + 1
end

function postSolveHandler(fixtureA, fixtureB, coll, normalImpluse, tangentImpulse)
	-- Unused 
end


function love.update(dt)
	-- New Physics 
	physicsWorld:update(dt)

	if string.len(collisionDebugText) > 768 then	-- cleanup when 'text' gets too long
		collisionDebugText = "" 
	end

	_.each(activeCrafts, function(craft)
		craft:update(dt)
	end)

	-- Spawn an enemy every second on the second
	if(math.floor(score) < math.floor(score + dt)) then
		table.insert(activeCrafts, SpaceCraft:new {
			imagePath="assets/head.png", sizeX=100, sizeY=100, xPosition=math.random(50, VIEWPORT_WIDTH - 50), yPosition=math.random(50, VIEWPORT_HEIGHT - 50),
			xVelocity=0, yVelocity=0, speed=0, aspects="enemy", world=physicsWorld
		})
	end

	score = score + dt
end

function love.draw()
	-- Print debug info on collisions and game boundaries
	if DEBUG == true then
		love.graphics.print(collisionDebugText, 10, 10)

		love.graphics.setColor(0.28, 0.63, 0.05)
		love.graphics.polygon("fill", leftWall.body:getWorldPoints(leftWall.shape:getPoints()))

		love.graphics.setColor(0.28, 0.05, 0.63)
		love.graphics.polygon("fill", rightWall.body:getWorldPoints(rightWall.shape:getPoints()))

		love.graphics.setColor(0.63, 0.05, 0.28)
		love.graphics.polygon("fill", topWall.body:getWorldPoints(topWall.shape:getPoints()))

		love.graphics.setColor(0.63, 0.63, 0.28)
		love.graphics.polygon("fill", bottomWall.body:getWorldPoints(bottomWall.shape:getPoints()))

		love.graphics.reset()
	end 

	-- Draw our custom spacecraft objects
	_.each(activeCrafts, function(craft)
		craft:draw()
	end)

	-- Draw the score
	love.graphics.print("Score : " .. math.ceil(score), VIEWPORT_WIDTH / 2, 50)
end

function love.keypressed(key)
	-- TODO: Refactor in spaceCraft
	-- User input affeccting new physics
	local xVelocity, yVelocity = activeCrafts.playerCraft.body:getLinearVelocity()
	
	if key == 'up' then
		yVelocity = -activeCrafts.playerCraft.speed
	elseif key == 'down' then
		yVelocity = activeCrafts.playerCraft.speed
	elseif key == 'right' then
		xVelocity = activeCrafts.playerCraft.speed
	elseif key == 'left' then
		xVelocity = -activeCrafts.playerCraft.speed
	end

	activeCrafts.playerCraft.body:setLinearVelocity(xVelocity, yVelocity)
end

function love.keyreleased(key)
	-- User input affeccting playerCraft's movements
	local xVelocity, yVelocity = activeCrafts.playerCraft.body:getLinearVelocity()

	if key == 'up' then
		if love.keyboard.isDown('down') then
			yVelocity = activeCrafts.playerCraft.speed
		else 
			yVelocity = 0
		end
	elseif key == 'down' then
		if love.keyboard.isDown('up') then
			yVelocity = -activeCrafts.playerCraft.speed
		else 
			yVelocity = 0
		end
	elseif key == 'right' then
		if love.keyboard.isDown('left') then
			xVelocity = -activeCrafts.playerCraft.speed
		else 
			xVelocity = 0
		end
	elseif key == 'left' then
		if love.keyboard.isDown('right') then
			xVelocity = activeCrafts.playerCraft.speed
		else 
			xVelocity = 0
		end
	end

	activeCrafts.playerCraft.body:setLinearVelocity(xVelocity, yVelocity)
end