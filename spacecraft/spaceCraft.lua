-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"
CollisionConstants = require "physics/collisionConstants"
SpaceCraftAspectDefinitions = require "spacecraft/spaceCraftAspectRegistry"


----------------------
-- CLASS DEFINITION --
----------------------

-- SpaceCrafts are (so far) the basic units for game entities.  Currently everything except the level bounds are SpaceCraft.
-- SpaceCrafts are built using a composition model, on top of this base.  
SpaceCraft = {}
SpaceCraft.__index = SpaceCraft

-- Constructor.  Applies our options and aspects to construct a new craft.  Then creates the physics entity, but does
--   does not yet fully add it to the world.
-- @return A newly constructed instance of a SpaceCraft.
function SpaceCraft:new(options)
	-- Initialize our spaceCraft with defaults
	local spaceCraft = {
		name = "Chaotic Entity",

		imagePath = "assets/head.png", 
		imageRotationOffset = 0,
		currentAlpha = 1,

		sizeX = 64, 
		sizeY = 64,
		xPosition = 0, 
		yPosition = 0,
		xVelocity = 0, 
		yVelocity = 0,
		linearDampening = 0,
		facingAngle = 0,
		angularVelocity = 0,
		angularDampening = 0,
		speed = 400,
		density = 1,

		age = 0,
		stunned = false,

		world = nil,
		bodyType = "dynamic",
		collisionType = "non-lethal-enemy",
		collisionCategory = CollisionConstants.CATEGORY_ENEMY,
		collisionMask = CollisionConstants.MASK_ALL,
		collisionGroup = CollisionConstants.GROUP_NONE,

		-- TODO: Travel and collision sounds?

		beforeBodySetupFuncs = {},
		onUpdateFuncs = {},
		onSpawnFinishedFuncs = {},
		onDrawImageFuncs = {},

		debug = nil,
		craftColor = nil,
		collisionDebugColor = {0.05, 0.05, 0.9}
	}

	setmetatable(spaceCraft, SpaceCraft)

	-- Layer in passed-in options.  These should typically be used for things not covered by aspects, generally things
	-- that are manually tweaked, like imagePath
	spaceCraft = _.extend(spaceCraft, options)

	local allAspectsScalingTable = {
		sizeX = 1,
		sizeY = 1,
		speed = 1
	}	

	-- For each aspect the SpaceCraft has, apply that aspect's initial paremters.  Remember here that aspect lists are Sets, not tables
	--  so we need to index by the AspectName, not the value
	_.each(spaceCraft.aspects, function(aspectVal, aspectName)
		if aspectVal then
			-- For each the parameters that Aspect Definition has
			_.each(SpaceCraftAspectDefinitions[aspectName], function(aspectPropertyValue, aspectPropertyName)
				-- For the scaling factors, combine them all into one table.  
				-- For properties  simply add or overwrite.
				-- For select functions, add to a list of layered functions so all fire.
				if aspectPropertyName == "scalingTable" then
					_.each(aspectPropertyValue, function(scalingFactor, scalingFieldName)
						allAspectsScalingTable[scalingFieldName] = allAspectsScalingTable[scalingFieldName] * scalingFactor
					end)
				elseif aspectPropertyName == "beforeBodySetup" or aspectPropertyName == "onUpdate" or aspectPropertyName == "onSpawnFinished" or aspectPropertyName == "onDrawImage" then
					-- TODO: Make above check more generic... ...within reason.
					table.insert(spaceCraft[aspectPropertyName .. "Funcs"], aspectPropertyValue)
				else
					spaceCraft[aspectPropertyName] = aspectPropertyValue
				end
			end)
		end
	end)

	spaceCraft:applyScaling(allAspectsScalingTable)

	-- Set up our craft's image
	spaceCraft:loadImageAndAttrs()

	-- Set up the space craft's Love2D Physics objects
	spaceCraft.body = spaceCraft:initializeBody()
	spaceCraft.shape = spaceCraft:initializeShape()

	return spaceCraft 
end 


----------------------
-- LOVE2D CALLBACKS --
----------------------

-- The Love2D callback for time passing in the game. Handle general behavior related to age here.  
-- @param dt The time interval since the last time love.update was called.
function SpaceCraft:update(dt)
	-- The amount of lag time between when a craft appears, and when it is an active participant in the world.
	local SPAWN_WAIT_DURATION = 2

	self.age = self.age + dt

	-- Enemies should not be collidable until they have spawned, so we wait until then to add their world fixture.
	if not self.finishedSpawn and self.age > SPAWN_WAIT_DURATION then
		self:spawn()
	end

	self:onUpdate(dt)
end

-- The Love2D callback for each drawing frame. Draw our craft's image, and potentially debugging frames.
function SpaceCraft:draw(globalAlpha)
	local blinkInterval = 7

	-- Enemies blink before they are finished spawning, to indicator that they cannot be interacted with.
	if (self.finishedSpawn and not self.stunned) or math.ceil(self.age * blinkInterval) % 2 == 0 then
		self:drawImage(globalAlpha)
		self:onDrawImage(globalAlpha)
	end

	-- If we're debugging, draw collision board. Color of boarder indicates collsion type.
	if self.debug.physicsVisual and self.finishedSpawn then
		self:debugDrawCenter(globalAlpha)

		self:debugDrawFacing(globalAlpha)

		self:debugDrawCollisionBorder(globalAlpha)

		-- Additionally if the craft currently has a velocity. draw a velocity indicator line
		if self.speed > 0 then
			self:debugDrawVelocityIndicator(globalAlpha)
		end
	end
end


-----------------------------
-- GENERIC CRAFT BEHAVIORS --
-----------------------------

-- Applies scaling factor(s) that can come in from aspects to a spaceCraft's base attributes.
function SpaceCraft:applyScaling(scalingTable)
	-- For each entry in the scaling table, apply that scaling factor to the corresponding attribute.
	_.each(scalingTable, function(scalingFactor, attributeName)
		self[attributeName] = self[attributeName] * scalingFactor
	end)
end

-- Loads the SpaceCraft's image, and sets related properties
function SpaceCraft:loadImageAndAttrs()
	-- TODO: consider caching a table of images to avoid repeat loading in here
	--	   as more spaceCraft (potentially with the same image) are spawned during the game
	self.image = love.graphics.newImage(self.imagePath)

	-- TODO: Get images that are properly sized to avoid scaling
	-- TODO2: Draw characters procedurally based on parameters rather using images
	self.imgSX = self.sizeX / self.image:getWidth()
	self.imgSY = self.sizeY / self.image:getHeight()

	self.imgOX, self.imgOY = self:setImageOffset()
end

-- Sets the anchor point for graphical transformations (like rotation) when drawing the Craft's image.
-- Since Crafts by default are square, and axis-aligned, images require no offset and just use top-left the corner.
-- @return [number, number] The x-axis and y-axis offsets respectively.
function SpaceCraft:setImageOffset()
	return 0, 0
end

-- Initializes the SpaceCrafts Body, which describes the Craft's motion (position, velocity, etc.) for the purposes of 
-- Ephysics and collisions.
-- @return Body A new Love2D physics body @see https://love2d.org/wiki/Body
function SpaceCraft:initializeBody()
	self:beforeBodySetup()

	-- Set up the space craft's Love2D Physics objects
	local body = love.physics.newBody(self.world:getWorld(), self.xPosition, self.yPosition, self.bodyType)
	body:setAngle(self.facingAngle)
	body:setAngularVelocity(self.angularVelocity)
	body:setAngularDamping(self.angularDampening)
	body:setLinearDamping(self.linearDampening)

	return body
end

-- Initializes the SpaceCrafts Shape for the purposes of physics and collisions.
-- By default Crafts are simply axis-aligned boxes.
function SpaceCraft:initializeShape()
	return love.physics.newRectangleShape(self.sizeX, self.sizeY)
end

-- Adds the (already-initialized) Craft to the World.  
-- We do this in Love2D by creating a new fixture.
function SpaceCraft:spawn()
	self.fixture = love.physics.newFixture(self.body, self.shape, self.density)

	-- Setup collision-related attributes.
	self.fixture:setFilterData(self.collisionCategory, self.collisionMask, self.collisionGroup)
	self.fixture:setUserData({
		type = self.collisionType,
		craft = self
	})

	-- preserve all linear momentum for now.  Set restitution to 1 since perfect elasticity 
	-- conservers momentum in a head-on collision, and friction to 0 to prevent linear velocity
	-- becoming angular velocity.
	self.fixture:setRestitution(1) 
	self.fixture:setFriction(0) 

	self:onSpawnFinished()

	self.finishedSpawn = true
end

function SpaceCraft:destroy()
	self.body:destroy()

	-- TODO: Have an onDestroy hook, for things like decrementing the enemyTable's count.
end

-------------
-- DRAWING --
-------------

-- Render the SpaceCraft's image to the screen, if one exists.
function SpaceCraft:drawImage(globalAlpha, fromPoints)
	if not globalAlpha then
		globalAlpha = 1
	end

	-- Make a copy of our color table so we don't permanently modify it with our passed-in ALpha.
	local drawColor = self.craftColor
	if not drawColor then
		drawColor = self.collisionDebugColor
	end

	local colorCopy = {}
	for origColorKey, origColorValue in pairs(drawColor) do
		colorCopy[origColorKey] = origColorValue
	end
	table.insert(colorCopy, self.currentAlpha * globalAlpha)

	local drawX, drawY = self:getDrawingAnchor(fromPoints)
	love.graphics.setColor(colorCopy)
	love.graphics.draw(self.image, drawX, drawY, self:getImageDrawAngle() + self.imageRotationOffset, self.imgSX, self.imgSY, self.imgOX, self.imgOY)

	love.graphics.reset()
end

-------------------
-- DEBUG DRAWING --
-------------------

-- Draws a dot on what is considered the center of the Craft for physics purposes.
function SpaceCraft:debugDrawCenter(alpha)
	local debugX, debugY = self.body:getPosition()

	self.collisionDebugColor[4] = alpha
	love.graphics.setColor(self.collisionDebugColor)
	love.graphics.circle("fill", debugX, debugY, 5)

	love.graphics.reset()
end

-- Draws a line in the direction the object is "facing" for physics purposes.
function SpaceCraft:debugDrawFacing(alpha)
	local centerX, centerY = self:getCenterPoint()
	local facingAngle = self.body:getAngle()

	-- The line should extend just outside of the Craft's bounds.
	local facingVectorX = math.cos(facingAngle) * 0.75 * self.sizeX
	local facingVectorY = math.sin(facingAngle) * 0.75 * self.sizeY

	-- TODO: Make a debug color constants table
	love.graphics.setColor(0.6, 0.05, 0.6, alpha)
	love.graphics.line(centerX, centerY, centerX + facingVectorX, centerY + facingVectorY)

	love.graphics.reset()
end

-- Draws the shape that the Spacecraft is considered for collisions.
-- By default, Crafts are squares, so we simple draw the same 4 points of our square Shape object.
function SpaceCraft:debugDrawCollisionBorder(alpha)
	self.collisionDebugColor[4] = alpha
	love.graphics.setColor(self.collisionDebugColor)
	love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
	love.graphics.reset()
end

-- Draws a line to indicat direct and speed of an object.  Speed is represented by length of the line.
-- TODO: Speed being represented by line-length, likely can't keep scaling well.  Perhaps increase thickness, or add more lines?
--        Will need experiement after adding Global Speed limit.
function SpaceCraft:debugDrawVelocityIndicator(alpha)
	local INDICATOR_LENGTH_FACTOR = 0.2
	local centerX, centerY = self:getCenterPoint()

	local velocityX, velocityY = self.body:getLinearVelocity()

	-- TODO: Make a debug color constants tab
	love.graphics.setColor(0.6, 0.6, 0.05, alpha)
	love.graphics.line(centerX, centerY, centerX + velocityX * INDICATOR_LENGTH_FACTOR, centerY + velocityY * INDICATOR_LENGTH_FACTOR)
	love.graphics.reset()
end


--------------------------
-- SpaceCraft Hooks --
--------------------------

-- Hooks for any custom behavior to occur during the Love2D update callback.
function SpaceCraft:onUpdate(dt)
	_.each(self.onUpdateFuncs, function(onUpdateFunc)
		onUpdateFunc(self, dt)
	end)
end

-- Hooks for any special modifications that need to be initially made to the Craft's Physics Body.
function SpaceCraft:beforeBodySetup()
	_.each(self.beforeBodySetupFuncs, function(beforeBodySetupFunc)
		beforeBodySetupFunc(self)
	end)
end

-- Hooks for any SpaceCraft Behavior that should occur on spawn.
function SpaceCraft:onSpawnFinished()
	_.each(self.onSpawnFinishedFuncs, function(onSpawnFinishedFunc)
		onSpawnFinishedFunc(self)
	end)
end

-- Hook for any SpaceCraft Behavior that should occur onDraw
function SpaceCraft:onDrawImage()
	_.each(self.onDrawImageFuncs, function(onDrawImageFunc)
		onDrawImageFunc(self)
	end)
end

-- TODO: An onDestroy hook!

-------------
-- Getters --
-------------

-- Gets the center of the Craft, in terms of Physics.
function SpaceCraft:getCenterPoint()
	return self.body:getPosition()
end

-- Gets the point from which the Craft should be drawn (in terms of Graphics)
function SpaceCraft:getDrawingAnchor(fromPoints)
	if fromPoints then
		local origAnchorX, origAnchorY = self.body:getWorldPoints(self.shape:getPoints())
		local origCenterX = self.body:getX()
		local origCenterY = self.body:getY()

		-- Compute a vector between old center and anchor point.
		local centerAnchorTranslationVectorX = origAnchorX - origCenterX
		local centerAnchorTranslationVectorY = origAnchorY - origCenterY

		-- Apply the vector to our new center to compute the new achor point.
		return centerAnchorTranslationVectorX + fromPoints.x, centerAnchorTranslationVectorY + fromPoints.y
	else
		return self.body:getWorldPoints(self.shape:getPoints())
	end
end

-- Gets the angle (in terms of Graphics) that the drawn image be rotated.  Applied through a transformation.
-- Our drawing angle always matches our Love2D Phyiscs Body's 'facing' angle.
function SpaceCraft:getImageDrawAngle()
	return self.body:getAngle()
end

return SpaceCraft