/datum/configuration_section/mapping
	name = "mapping"

	var/preferable_engine = MAP_ENG_SINGULARITY
	var/preferable_biodome = MAP_BIO_FOREST
	var/preferable_bar = MAP_BAR_CLASSIC

/datum/configuration_section/mapping/load_data(list/data)
	CONFIG_LOAD_STR(preferable_engine,  data["preferable_engine"])
	CONFIG_LOAD_STR(preferable_biodome, data["preferable_biodome"])
	CONFIG_LOAD_STR(preferable_bar, 	data["preferable_bar"])

	if(!(preferable_engine in list(MAP_ENG_RANDOM, MAP_ENG_SINGULARITY, MAP_ENG_MATTER)))
		preferable_engine = MAP_ENG_SINGULARITY
	if(!(preferable_biodome in list(MAP_BIO_RANDOM, MAP_BIO_FOREST, MAP_BIO_WINTER, MAP_BIO_BEACH, MAP_BIO_CONCERT)))
		preferable_biodome = MAP_BIO_FOREST
	if(!(preferable_bar in list(MAP_BAR_RANDOM, MAP_BAR_CLASSIC, MAP_BAR_MODERN, MAP_BAR_SALOON)))
		preferable_bar = MAP_BAR_CLASSIC
