-- IMPORTS --
_ = require "moses_min"
SpaceCraft = require "spaceCraft"


-- CONSTANTS -- 
VIEWPORT_HEIGHT = 800
VIEWPORT_WIDTH = 1200

-- TODO: Actually use this, to differentiate between playable and screenspace.
PLAYABLE_AREA_HEIGHT = 600
PLAYABLE_AREA_WIDTH = 800

-- LOVE CALLBACKS -- 

function love.load()
	-- Set background to blue
	love.window.setMode(VIEWPORT_WIDTH, VIEWPORT_HEIGHT)

	-- Create Physics context 
	-- Set the height of the meter in pixels to 64
	love.physics.setMeter(64)

	-- Create a world, no gravity in either direction, because this is space damnit!
	physicsWorld = love.physics.newWorld(0, 0, true)

	-- Set collision callbacks to govern what happens for collisions
	physicsWorld:setCallbacks(beginContactHandler, endContactHandler, preSolveHandler, postSolveHandler)
	collisionDebugText = ""
	persisting = 0

	-- TODO : Convert to physics objects
	activeCrafts = {
		playerCraft = SpaceCraft:new {
			imagePath="assets/pig.png", sizeX=100, sizeY=100, xPosition=50, yPosition=50,
			xVelocity=10, yVelocity=0, speed=100, age=2, aspects="player", world=physicsWorld
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

	-- If the play collides, game over 
	if fixtureA:getUserData() == "player" or fixtureB:getUserData() == "player" then
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

	if string.len(collisionDebugText) > 768 then    -- cleanup when 'text' gets too long
        collisionDebugText = "" 
    end

    _.each(activeCrafts, function(craft)
		craft:update(dt)
	end)

	-- User input affeccting new physocs
	if love.keyboard.isDown("a") then
		activeCrafts.playerCraft.body:applyForce(-400, 0)
	end

	if love.keyboard.isDown("d") then
		activeCrafts.playerCraft.body:applyForce(400, 0)
	end

	if love.keyboard.isDown("w") then
		activeCrafts.playerCraft.body:applyForce(0, -400)
	end

	if love.keyboard.isDown("s") then
		activeCrafts.playerCraft.body:applyForce(0, 400)
	end

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
	-- Print debug info on collisions 
 	love.graphics.print(collisionDebugText, 10, 10)

	-- Draw our custom spacecraft objects
	_.each(activeCrafts, function(craft)
		craft:draw()
	end)

	-- Draw the score
	love.graphics.print("Score : " .. math.ceil(score), 400, 50)
end
