-------------
-- IMPORTS --
-------------
_ = require "libs/moses_min"


-----------
-- UTILS --
-----------
-- TODO: Move global Utils to their own file.

-- Creates a set, aka a table where the identifiers are keys
function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

----------------------
-- CLASS DEFINITION -- 
----------------------

-- A wrapper for handling the post-game behavior drawing .  
-- Currently uses Love2D's native Phsyics engine.
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

	gameOver = _.extend(gameInitialization, options)

	return gameInitialization
end 

-- TODO: Comment
function GameInitialization:loadEnemyTable()
	local defaultEnemyTable = {
		{ -- Slot 1, The Base Layer: spawns quickly but with a low limit.  Forms the initial challenge / interaction with the player 
			spawnInterval = 5,
			spawnCounter = 5,
			currentEnemyCount = 0,
			spawnLimit = 7,
			enemyObj = {
				name = "Comet",
				imagePath = "assets/comet-spark.png",
				imageRotationOffset = -math.pi / 4,
				aspects = Set{"enemyLinear", "faceMotion", "circular", "deadly"}, 
				debug = self.debug
			}
		},
		{ -- Slot 2, The Consistent Threat: spawns slowly, but with a high limit
			spawnInterval = 12,
			spawnCounter = -2,
			currentEnemyCount = 0,
			spawnLimit = 25,
			-- [[ Mad Moons 
			enemyObj = {
				name = "Mad Moon",
				imagePath = "assets/evil-moon.png",
				aspects = Set{"circular", "enemyStatic"}, 
				debug = self.debug
			} --]]

		},
		{ -- Slot 3, The Wrench: After a long wait and the first amp, spawns quickly
			spawnInterval = 3,
			spawnCounter = -60,
			currentEnemyCount = 0,
			spawnLimit = 10,
			--[[ Mimes 
			enemyObj = {
				name = "Mime",
				imagePath = "assets/mime.png",
				aspects = Set{"circular", "playerInputMotion", "playerOnlyCollision", "deadly"}, 
				debug = Debug
			} --]]
			--[[ Gamma Ray
			enemyObj = {
				name = "Gamma Ray",
				imagePath = "assets/lightning-frequency.png",
				imageRotationOffset = -math.pi / 4,
				aspects = Set{"enemyLinear", "faceMotion", "playerOnlyCollision", "circular", "deadly"}, 
				debug = Debug
			} --]]
			-- [[ Stun-Nado
			enemyObj = {
				name = "Stun-Nado",
				imagePath = "assets/wind-hole.png",
				angularVelocity = -5,
				aspects = Set{"enemyLinear", "faceAngle", "noEnemyCollision", "circular", "stun"}, 
				debug = self.debug
			} --]]
		},
		{ -- Slot 4, Ragnarok: If the player isn't dead yet, reward them with swift death
			spawnInterval = 2,
			spawnCounter = -120,
			currentEnemyCount = 0,
			spawnLimit = 100,
			enemyObj = { 
				name = "Thwomp",
				imagePath = "assets/head.png", 
				aspects = Set{"enemyStatic", "faceAngle", "deadly"}, 
				debug = self.debug
			}
		}
	}

	-- TODO: Load this from a file / server.	File could either be user made (manually or in an 'admin' interace), or Machine Learning generated.

	return defaultEnemyTable
end 

return GameInitialization