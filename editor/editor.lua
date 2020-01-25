-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"

WorldPhysics = require "physics/worldPhysics"

SpaceCraft = require "spacecraft/spaceCraft"
SpaceCraftAspectDefinitions = require "spacecraft/spaceCraftAspectRegistry"

Button = require "editor/button"



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
		draftCraftNumber = 1,
		draftCraftAspects = {
			Set{},
			Set{},
			Set{},
			Set{},
		},
		savingCounter = 0,
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

	editor.subTitleFont = love.graphics.newFont("assets/font/cour.ttf", 16)
	editor.subTitle = ""

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
			aspects = editor.draftCraftAspects[editor.draftCraftNumber],
			world = editor.worldPhysics,
			debug = editor.debug
		}
	}

	editor:initializeButtons()

	return editor
end 

-- Creates a tray of config buttons for the Editor
function Editor:initializeButtons()
	-- Add Aspect Buttons
	local buttonNumber = 1
	_.each(SpaceCraftAspectDefinitions, function(definition, defName)
		if(defMame ~= "player") then
			local buttonImagePath = nil

			if definition.buttonImage then
				buttonImagePath = definition.buttonImage
			end

			self.buttons[defName] = Button:new {
				imagePath = buttonImagePath,
				x = -20 + (buttonNumber * 40),
				y = self.worldHeight - 100,
				width = 32,
				height = 32,
				active = false,
				onClick = function(active)
					self.draftCraftAspects[self.draftCraftNumber][defName] = not self.draftCraftAspects[self.draftCraftNumber][defName]
					self:respawnDraftCraft()
				end
			}

			buttonNumber = buttonNumber + 1
		end
	end)

	-- Add enemy number buttons
	for i=1,4 do
		self.buttons[i] = Button:new {
			imagePath = "assets/dice-" .. i .. ".png",
			x = -20 + (i * 40),
			y = self.worldHeight - 60,
			width = 32,
			height = 32,
			active = i == 1,
			onClick = function(active)
				self.draftCraftNumber = i

				-- Reset all buttons
				_.each(self.buttons, function(button)
					button.active = false
				end)

				-- Reset the active Aspects to be the one's for this # draftCraft
				_.each(self.draftCraftAspects[self.draftCraftNumber], function(isAspectApplied, aspectName)
					if isAspectApplied then
						self.buttons[aspectName].active = true
					end
				end)

				-- Fianlly, re-active this button, and spawn the associated craft.
				self.buttons[i].active = true

				self:respawnDraftCraft()
			end
		}
	end

	-- Create a button 
	self.buttons["add"] = Button:new {
		imagePath = "assets/heart-plus.png",
		x = -20 + (5 * 40),
		y = self.worldHeight - 60,
		width = 32,
		height = 32,
		active = i == 1,
		onClick = function(active)
			-- Fianlly, re-active this button, and spawn the associated craft.
			self.buttons["add"].active = false

			self:spawnAdditionalCraft()
		end
	}

	-- Finally add a save button
	self.buttons["save"] = Button:new {
		imagePath = "assets/save.png",
		x = 20,
		y = self.worldHeight - 140,
		width = 32,
		height = 32,
		active = false,
		onClick = function(active)
			self.subTitle = "Saving"
			self.savingCounter = 4
			self.buttons["save"].active = false
			self:saveConfig()
		end
	}
end

-- The Love2D callback for each time interval
function Editor:update(dt)
	self.worldPhysics:update(dt)

	_.each(self.activeCrafts, function(craft)
		craft:update(dt)
	end)

	if self.savingCounter > 0 then
		self.savingCounter = self.savingCounter - dt

		if self.savingCounter < 1 then
			self.subTitle = "Saved"
		end
	elseif self.savingCounter < 0 then
		self.savingCounter = 0
	end
end

-- The Love2D callback for each drawing frame. Draw our menu text
-- @param {number} MainMenuTime - How much time (in seconds) has ellapsed since the menu was shown
function Editor:draw()
	local LINEHEIGHT = 32 
	local FONT_SIZE = 24

	-- Title
	love.graphics.setFont(self.font)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(self.title, (self.worldWidth / 2) - (string.len(self.title) * FONT_SIZE * 0.5), LINEHEIGHT)

	if self.savingCounter > 0 then
		local saveAlpha = 1
		if self.savingCounter > 1 then
			saveAlpha = math.cos(self.savingCounter * 5.4) + 1
		end

		love.graphics.setFont(self.subTitleFont)
		love.graphics.setColor(1, 1, 1, saveAlpha)
		love.graphics.print(self.subTitle, (self.worldWidth / 2) - (string.len(self.subTitle) * FONT_SIZE * 0.5), LINEHEIGHT * 2 + 12)
	end

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
	if key == 'r' then
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
			aspects = self.draftCraftAspects[self.draftCraftNumber],
			world = self.worldPhysics,
			debug = self.debug
		}
	}
end

-- Respawns the draft craft.
function Editor:spawnAdditionalCraft()
	local SPAWN_BUFFER_DISTANCE = 50

	-- Create our test craft
	table.insert(self.activeCrafts, SpaceCraft:new { 
			xPosition = love.math.random(SPAWN_BUFFER_DISTANCE, self.worldWidth - SPAWN_BUFFER_DISTANCE), 
			yPosition = love.math.random(SPAWN_BUFFER_DISTANCE, self.worldHeight - SPAWN_BUFFER_DISTANCE),
			age = 0, 
			aspects = self.draftCraftAspects[self.draftCraftNumber],
			world = self.worldPhysics,
			debug = self.debug
		}
	)
end

-- Saves the currrent configuration to the "enemyConfig.json" file.  This configuration can then be used in Game mode.
function Editor:saveConfig()
	local CONFIG_DIR_PATH = "config/"
	local CONFIG_FILE_PATH = "config/enemyConfig.json"

		-- Ensure the data/ folder exists.
	local configFolder = love.filesystem.getInfo(CONFIG_DIR_PATH)

	if not configFolder or configFolder.type ~= "directory"  then
		love.filesystem.createDirectory(CONFIG_DIR_PATH)
	end

	-- Prep the text to write
	-- Build a table to serialize to a data file summarizing the play through for the ML.
	local enemyConfigTable = {}

	_.eachi(self.draftCraftAspects, function(aspectList, index)
		enemyConfigTable["e" .. index .. "Aspects"] = SetToArray(aspectList)
	end)
	
	-- Write the config file.
	love.filesystem.write(CONFIG_FILE_PATH, JSON.encode(enemyConfigTable), all)
end

return Editor