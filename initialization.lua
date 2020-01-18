-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"
JSON = require "libs/json"

function PrintKeysAndValues(table)
	for k,v in pairs(table) do
		print(k)
		print("=")
		print(v)
	end
end

----------------------
-- CLASS DEFINITION -- 
----------------------

-- A wrapper for handling the game's initialization behavior.  
GameInitialization = {}
GameInitialization.__index = GameInitialization

function GameInitialization:new(options)
	local gameInitialization = {
		debug = {
			physicsVisual = false,
			physicsLog = false
		}
	}

	setmetatable(gameInitialization, GameInitialization)

	gameInitialization = _.extend(gameInitialization, options)

	gameInitialization:loadPlayerData()

	return gameInitialization
end 

function GameInitialization:loadPlayerData()
	local CONFIG_DIR_PATH = "config/"
	local CONFIG_FILE_PATH = "config/playerConfig.json"
	

	-- Ensure the data/ folder exists.
	local configFolder = love.filesystem.getInfo(CONFIG_DIR_PATH)

	if not configFolder or configFolder.type ~= "directory"  then
		love.filesystem.createDirectory(CONFIG_DIR_PATH)
	end

	local configFileInfo = love.filesystem.getInfo(CONFIG_FILE_PATH)

	-- If a config file exists, player name and type	
	-- TODO: Load configs from a server instead of locally.
	if configFileInfo and configFileInfo.type == "file"  then
		-- NOTE: Currently configs should only be a single line, but we iterate here for good measure.
		for line in love.filesystem.lines(CONFIG_FILE_PATH) do
			local config = JSON.decode(line)

			self.playerConfig = config
		end
	else
		-- Create a default config file.
		local defaultPlayerConfig = {
			playerName = "Unknown Player",
			playerType = 0
		}

		-- Save config to a file to avoid needing to create it next run
		love.filesystem.write(CONFIG_FILE_PATH, JSON.encode(defaultPlayerConfig), all)

		self.playerConfig = defaultPlayerConfig
	end

	return self.playerConfig
end

-- TODO: Comment
function GameInitialization:loadEnemyTable()
	-- Initialize the table with the defaults

	-- TODO: Also allow for overwriting of cosmetic attributes

	local enemyTable = {
		{ -- Slot 1, The Base Layer: spawns quickly but with a low limit.  Forms the initial challenge / interaction with the player 
			spawnInterval = 5,
			spawnCounter = 5,
			currentEnemyCount = 0,
			spawnLimit = 5,
			enemyObj = {
				name = "1st Enemy",
				aspects = Set{"circular", "deadly", "fixedInitialSpeed"}, 
				debug = self.debug
			}
		},
		{ -- Slot 2, The Consistent Threat: spawns slowly, but with a high limit
			spawnInterval = 8,
			spawnCounter = -15,
			currentEnemyCount = 0,
			spawnLimit = 20,
			-- [[ Mad Moons 
			enemyObj = {
				name = "2nd Enemy",
				aspects = Set{"enemyStatic"}, 
				debug = self.debug
			} --]]

		},
		{ -- Slot 3, The Wrench: After a long wait and the first amp, spawns quickly
			spawnInterval = 3,
			spawnCounter = -90,
			currentEnemyCount = 0,
			spawnLimit = 10,

			-- [[ Stun-Nado
			enemyObj = {
				name = "3rd Enemy",
				aspects = Set{"noEnemyCollision", "circular", "stun", "fixedInitialSpeed"}, 
				debug = self.debug
			} --]]
		},
		{ -- Slot 4, Ragnarok: If the player isn't dead yet, reward them with swift death
			spawnInterval = 2,
			spawnCounter = -120,
			currentEnemyCount = 0,
			spawnLimit = 100,
			enemyObj = { 
				name = "4th Enemy",
				aspects = Set{"playerInputMotion", "waveFadingVisibility", "linearDampening"}, 
				debug = self.debug
			}
		}
	}


	-- NOTE: Currently it assumes this file was manually created, and won't make one if it doesn't find it.
	local CONFIG_FILE_PATH = "config/enemyConfig.json"

	local configFileInfo = love.filesystem.getInfo(CONFIG_FILE_PATH)

	-- If a config file exists, Load enemy aspects from a file.	File could either be user made (manually or in 
	--an 'admin' interace), or Machine Learning generated.	
	-- TODO: Load configs from a server instead of locally.
	-- TO-FUCKING-DO: Allow level configs to apply aspects to the player as well.
	if configFileInfo and configFileInfo.type == "file"  then

		local aspectOverrides = {
		}

		-- NOTE: Currently configs should only be a single line, but we iterate here for good measure.
		for line in love.filesystem.lines(CONFIG_FILE_PATH) do
			local config = JSON.decode(line)

			-- TODO: Make size generic
			aspectOverrides[1] = Set(config.e1Aspects)
			aspectOverrides[2] = Set(config.e2Aspects)
			aspectOverrides[3] = Set(config.e3Aspects)
			aspectOverrides[4] = Set(config.e4Aspects)
		end

		-- For each enemy slot, overwrite the default aspect list.'
		_.eachi(enemyTable, function(enemyTableEntry, index)
			enemyTableEntry.enemyObj.aspects = aspectOverrides[index]
		end)
	end

	return enemyTable
end 

return GameInitialization