-- A table of Constants related to Physics and Collisions --

CollisionConstants = {
	CATEGORY_DEFAULT = 0x0001,
	CATEGORY_BOUNDARY = 0x0002,
	CATEGORY_PLAYER = 0x0004,
	CATEGORY_ENEMY = 0x0008,

	MASK_ALL = 0xFFFF,
	MASK_PLAYER_ONLY = 0x0004,
	MASK_PLAYER_AND_BOUNDARIES = 0x0006, --TODO: but this together with or'ing to be more readible?

	GROUP_NONE = 0
}

return CollisionConstants