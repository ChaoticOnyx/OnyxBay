/datum/space_level/science_ship_1
	path = 'science_ship-1.dmm'
	travel_chance = 5

/datum/space_level/science_ship_2
	path = 'science_ship-2.dmm'
	travel_chance = 5

/area/science_ship
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)
	has_gravity = TRUE
	sound_env = LARGE_ENCLOSED
	requires_power = TRUE
	always_unpowered = TRUE

/area/science_ship/level1
	name = "Science Ship - Level 1"
	icon_state = "science_ship_level1"

/area/science_ship/level2
	name = "Science Ship - Level 2"
	icon_state = "science_ship_level2"
