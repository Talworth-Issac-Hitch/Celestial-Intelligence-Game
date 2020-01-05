-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"

WorldPhysics = require "worldPhysics"
SpaceCraft = require "spaceCraft"

Button = require "button"
SpaceCraftAspectDefinitions = require "spaceCraftAspectRegistry"


----------------------
-- CLASS DEFINITION -- 
----------------------

-- A class for the main menu  
Editor = {}
Editor.__index = Editor

-- Constructor.  Builds a new Main Menu screen.
-- @param {Table} options A table containing basic window information.
function Editor:new(options)
	local editor = {
		worldWidth = 800,
		worldHeight = 600,
		time = 0,
		activeCrafts = {},
		buttons = {},
		draftCraftAspects = Set{},
		worldPhysics = {},
		debug = {
			physicsVisual = false,
			physicsLog = false
		}
	}

	setmetatable(editor, Editor)

	editor = _.extend(editor, options)

	editor.font = love.graphics.newFont("assets/font/cour.ttf", 24)
	editor.title = "Editor"

	-- Initialize our physics
	editor.worldPhysics = WorldPhysics:new {
		worldWidth = editor.worldWidth,
		worldHeight = editor.worldHeight,
		debug = editor.debug
	}

	-- Create our test craft
	editor.activeCrafts = {
		draftCraft = SpaceCraft:new { 
			xPosition = editor.worldWidth / 2, 
			yPosition = editor.worldHeight / 2, 
			age = 0, 
			aspects = editor.draftCraftAspects, 
			world = editor.worldPhysics,
			debug = editor.debug
		}
	}

	editor:initializeButtons()

	return editor
end 

function Editor:initializeButtons()
	local buttonNumber = 1
	_.each(SpaceCraftAspectDefinitions, function(definition, defName)
		if(defMame ~= "player") then
			self.buttons[buttonNumber] = Button:new {
				x = -20 + (buttonNumber * 40),
				y = self.worldHeight - 100,
				width = 32,
				height = 32,
				active = false,
				onClick = function(active)
					self.draftCraftAspects[defName] = not self.draftCraftAspects[defName]
					self:respawnDraftCraft()
				end
			}

			buttonNumber = buttonNumber + 1
		end
	end)
end

-- The Love2D callback for each time interval
function Editor:update(dt)
	self.worldPhysics:update(dt)

	_.each(self.activeCrafts, function(craft)
		craft:update(dt)
	end)
end

-- The Love2D callback for each drawing frame. Draw our menu text
-- @param {number} MainMenuTime - How much time (in seconds) has ellapsed since the menu was shown
function Editor:draw()
	local LINEHEIGHT = 32 
	local FONT_SIZE = 24

	love.graphics.setFont(self.font)

	love.graphics.setColor(1, 1, 1)
	love.graphics.print(self.title, (self.worldWidth / 2) - (string.len(self.title) * FONT_SIZE * 0.5), LINEHEIGHT)

	self.worldPhysics:draw()

	-- Draw our custom spacecraft objects
	_.each(self.activeCrafts, function(craft)
		craft:draw()
	end)

	_.each(self.buttons, function(button)
		button:draw()
	end)
end

-- Love2D callback for when the player presses a key.  Some game components have their individual implementations for that callback,
-- so if one exists, we call it here.
function Editor:keypressed(key, scancode, isrepeat)
	-- TODO: Gotta be a better, more growth-tolerant way
	-- TODO: SHould be able to toggle
	if key == '0' then
		self.draftCraftAspects["fixedInitialSpeed"] = not self.draftCraftAspects["fixedInitialSpeed"]
		self:respawnDraftCraft()
	elseif key == '1' then
		self.draftCraftAspects["downInitDir"] = not self.draftCraftAspects["downInitDir"]
		self:respawnDraftCraft()
	elseif key == '2' then
		self.draftCraftAspects["randomInitDir"] = not self.draftCraftAspects["randomInitDir"]
		self:respawnDraftCraft()
	elseif key == '3' then
		self.draftCraftAspects["acceleratingSpeed"] = not self.draftCraftAspects["acceleratingSpeed"]
		self:respawnDraftCraft()
	elseif key == '4' then
		self.draftCraftAspects["linearDampening"] = not self.draftCraftAspects["linearDampening"]
		self:respawnDraftCraft()
	elseif key == '5' then
		self.draftCraftAspects["waveFixedSpeed"] = not self.draftCraftAspects["waveFixedSpeed"]
		self:respawnDraftCraft()
	elseif key == '6' then
		self.draftCraftAspects["deadly"] = not self.draftCraftAspects["deadly"]
		self:respawnDraftCraft()
	elseif key == '7' then
		self.draftCraftAspects["initRotation"] = not self.draftCraftAspects["initRotation"]
		self:respawnDraftCraft()
	elseif key == '8' then
		self.draftCraftAspects["periodicImpulseSpeed"] = not self.draftCraftAspects["periodicImpulseSpeed"]
		self:respawnDraftCraft()
	elseif key == '9' then
		self.draftCraftAspects["playerInputMotion"] = not self.draftCraftAspects["playerInputMotion"]
		self:respawnDraftCraft()
	elseif key == '-' then
		self.draftCraftAspects["periodicAngularImpulse"] = not self.draftCraftAspects["periodicAngularImpulse"]
		self:respawnDraftCraft()
	elseif key == 'r' then
		self:respawnDraftCraft()
	elseif key == 'o' then
		self.debug.physicsVisual = not self.debug.physicsVisual
	elseif key == 'l' then
		self.debug.physicsLog = not self.debug.physicsLog
	end

	_.each(self.activeCrafts, function(craft)
		if _.has(craft, "onKeyPressed") then
			craft:onKeyPressed(key)
		end
	end)
end

-- Love2D callback for when the player releases a key.  Some game components have their individual implementations for that callback,
-- so if one exists, we call it here.
function Editor:keyreleased(key, scancode, isrepeat)
	_.each(self.activeCrafts, function(craft)
		if _.has(craft, "onKeyReleased") then
			craft:onKeyReleased(key)
		end
	end)
end

-- Love2D callback for when the player clicks the mouse.  Some game components have their individual implementations for that callback,
-- so if one exists, we call it here.
function Editor:mousepressed(x, y, button, istouch, presses)
	_.each(self.buttons, function(button)
		button:checkClick(x, y, button, istouch, presses)
	end)
end


-- Respawns the draft craft.
function Editor:respawnDraftCraft()
	-- Destroy and remove all current crafts from the physical world
	_.each(self.activeCrafts, function(craft)
		craft:destroy()
	end)

	-- Create our test craft
	self.activeCrafts = {
		draftCraft = SpaceCraft:new { 
			xPosition = self.worldWidth / 2, 
			yPosition = self.worldHeight / 2, 
			age = 0, 
			aspects = self.draftCraftAspects, 
			world = self.worldPhysics,
			debug = self.debug
		}
	}
end

return Editor