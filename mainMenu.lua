-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"

----------------------
-- CLASS DEFINITION -- 
----------------------

-- A class for the main menu  
MainMenu = {}
MainMenu.__index = MainMenu

---------------
-- CONSTANTS --
--------------- 
ASCII_CELESTIAL = " .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------. \n" ..
"| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |\n" ..
"| |     ______   | || |  _________   | || |   _____      | || |  _________   | || |    _______   | || |  _________   | || |     _____    | || |      __      | || |   _____      | |\n" ..
"| |   .' ___  |  | || | |_   ___  |  | || |  |_   _|     | || | |_   ___  |  | || |   /  ___  |  | || | |  _   _  |  | || |    |_   _|   | || |     /  \\     | || |  |_   _|     | |\n" ..
"| |  / .'   \\_|  | || |   | |_  \\_|  | || |    | |       | || |   | |_  \\_|  | || |  |  (__ \\_|  | || | |_/ | | \\_|  | || |      | |     | || |    / /\\ \\    | || |    | |       | |\n" ..
"| |  | |         | || |   |  _|  _   | || |    | |   _   | || |   |  _|  _   | || |   '.___`-.   | || |     | |      | || |      | |     | || |   / ____ \\   | || |    | |   _   | |\n" ..
"| |  \\ `.___.'\\  | || |  _| |___/ |  | || |   _| |__/ |  | || |  _| |___/ |  | || |  |`\\____) |  | || |    _| |_     | || |     _| |_    | || | _/ /    \\ \\_ | || |   _| |__/ |  | |\n" ..
"| |   `._____.'  | || | |_________|  | || |  |________|  | || | |_________|  | || |  |_______.'  | || |   |_____|    | || |    |_____|   | || ||____|  |____|| || |  |________|  | |\n" ..
"| |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | |\n" ..
"| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |\n" ..
" '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' \n"

ASCII_INTELLIGENCE = " .----------------.  .-----------------. .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .-----------------. .----------------.  .----------------. \n" .. 
"| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |\n" ..
"| |     _____    | || | ____  _____  | || |  _________   | || |  _________   | || |   _____      | || |   _____      | || |     _____    | || |    ______    | || |  _________   | || | ____  _____  | || |     ______   | || |  _________   | |\n" ..
"| |    |_   _|   | || ||_   \\|_   _| | || | |  _   _  |  | || | |_   ___  |  | || |  |_   _|     | || |  |_   _|     | || |    |_   _|   | || |  .' ___  |   | || | |_   ___  |  | || ||_   \\|_   _| | || |   .' ___  |  | || | |_   ___  |  | |\n" ..
"| |      | |     | || |  |   \\ | |   | || | |_/ | | \\_|  | || |   | |_  \\_|  | || |    | |       | || |    | |       | || |      | |     | || | / .'   \\_|   | || |   | |_  \\_|  | || |  |   \\ | |   | || |  / .'   \\_|  | || |   | |_  \\_|  | |\n" ..
"| |      | |     | || |  | |\\ \\| |   | || |     | |      | || |   |  _|  _   | || |    | |   _   | || |    | |   _   | || |      | |     | || | | |    ____  | || |   |  _|  _   | || |  | |\\ \\| |   | || |  | |         | || |   |  _|  _   | |\n" ..
"| |     _| |_    | || | _| |_\\   |_  | || |    _| |_     | || |  _| |___/ |  | || |   _| |__/ |  | || |   _| |__/ |  | || |     _| |_    | || | \\ `.___]  _| | || |  _| |___/ |  | || | _| |_\\   |_  | || |  \\ `.___.'\\  | || |  _| |___/ |  | |\n" ..
"| |    |_____|   | || ||_____|\\____| | || |   |_____|    | || | |_________|  | || |  |________|  | || |  |________|  | || |    |_____|   | || |  `._____.'   | || | |_________|  | || ||_____|\\____| | || |   `._____.'  | || | |_________|  | |\n" ..
"| |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | |\n" ..
"| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |\n" ..
" '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' \n"

-- Constructor.  Builds a new Main Menu screen.
-- @param {Table} options A table containing basic window information.
function MainMenu:new(options)
	local mainMenu = {
		worldWidth = 800,
		worldHeight = 600,
		time = 0,
		starcounter = 0,
		font = nil,
		gameStartHandler = nil,
		editorStartHandler = nil
	}

	setmetatable(mainMenu, MainMenu)

	mainMenu = _.extend(mainMenu, options)

	mainMenu.headerFont = love.graphics.newFont("assets/font/cour.ttf", 8)
	mainMenu.footerFont = love.graphics.newFont("assets/font/cour.ttf", 14)

	mainMenu.headerImage = love.graphics.newImage("assets/mad-moon.png")
	mainMenu.title = ASCII_CELESTIAL .. "\n\n" .. ASCII_INTELLIGENCE .. "\n\n" .. generateStarField()

	return mainMenu
end 

-- Creates random ASCII starfield
-- @return {String} - A 241x72 ASCCII Starfield 
function generateStarField() 
	local starfield = ""
	local BASE_DENSITY = 9
	local FIELD_WIDTH = 241
	local FIELD_STAR_ROWS = 24 --Actual Character height of the field is x3 this number.
	local FIELD_NUMBER_OF_SECTIONS = 3

	for i=1,FIELD_STAR_ROWS do
		local sectionNumber = math.ceil(i / FIELD_NUMBER_OF_SECTIONS)

		for j=1,FIELD_WIDTH do
			local roll = love.math.random(1, BASE_DENSITY * sectionNumber) 
			if roll >= (BASE_DENSITY * sectionNumber) then
				starfield = starfield .. "*"
			else
			    starfield = starfield .. " " 
			end 
		end

		starfield = starfield .. "\n\n"
	end

	return starfield
end

-- The Love2D callback for each time interval
function MainMenu:update(dt)
	local STAR_CHANGE_INTERVAL = 3.14

	self.time = self.time + dt
	self.starcounter = self.starcounter + dt

	if self.starcounter >= STAR_CHANGE_INTERVAL then
		self.title = ASCII_CELESTIAL .. "\n\n" .. ASCII_INTELLIGENCE .. "\n\n" .. generateStarField()
		self.starcounter = self.starcounter - STAR_CHANGE_INTERVAL 
	end
end

-- The Love2D callback for each drawing frame. Draw our menu text
-- @param {number} MainMenuTime - How much time (in seconds) has ellapsed since the menu was shown
function MainMenu:draw()
	local LINEHEIGHT = 32
	love.graphics.setFont(self.headerFont)

	love.graphics.setColor(1, 1, 1)
	love.graphics.print(self.title, 0, LINEHEIGHT)

	love.graphics.draw(self.headerImage, 1100, 32, 0, 0.15, 0.15, 0, 0)

	-- Make the game start command flash
	local footerAlpha = math.cos(self.time * 2.5) + 1

	love.graphics.setFont(self.footerFont)
	love.graphics.setColor(1, 1, 1, footerAlpha)
	love.graphics.print("Press Space to begin playing.\n\nPress Enter to begin Editing.", self.worldWidth / 3, self.worldHeight - LINEHEIGHT * 2)
	love.graphics.reset()
end


-- Love2D callback for when the player presses a key.  Start the game if the user 
function MainMenu:onKeyReleased(key)
	if key == 'space' then
		self.gameStartHandler()
	elseif key == 'return' then
		self.editorStartHandler()
	end
end

return MainMenu