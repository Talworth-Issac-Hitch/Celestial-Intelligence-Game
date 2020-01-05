-----------------------
-- ASPECT DEFINITION --
-----------------------

-- For Craft which do not move and cannot be moved themselves.
StaticCraftAspectDefinition = {
	buttonImage = "assets/rock.png",
	scalingTable = {
		sizeX = 2,
		sizeY = 2,
		speed = 0
	},

	bodyType = "static"
}

return StaticCraftAspectDefinition