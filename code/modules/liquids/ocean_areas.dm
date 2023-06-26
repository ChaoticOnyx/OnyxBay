/area/ocean
	name = "Ocean"
	icon_state = "space"
	always_unpowered = TRUE
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	environment_type = ENVIRONMENT_OUTSIDE
	is_station = FALSE
	ambient_music_tags = list(MUSIC_TAG_SPACE)
	gravity_state = AREA_GRAVITY_ALWAYS
	sound_env = SPACE

/area/ocean/generated
	map_generator = /datum/map_generator/ocean_generator

/area/ocean/trench
	name = "The Trench"

/area/ocean/trench/generated
	//map_generator = /datum/map_generator/cave_generator/trench

/area/ruin/ocean
	has_gravity = TRUE

/area/ruin/ocean/listening_outpost
	name = "Listening Station"

/area/ruin/ocean/bunker
	name = "Bunker"

/area/ruin/ocean/bioweapon_research
	name = "Syndicate Ocean Base"

/area/ruin/ocean/mining_site
	name = "Mining Site"

/area/ruin/ocean/saddam_hole
	name = "Cave Hideout"
