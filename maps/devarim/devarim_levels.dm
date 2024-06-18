/datum/space_level/devarim_1
	path = 'devarim-1.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 10
	ftl_mask = /datum/map_template/devarim_ftl_1
	mapgen_mask = /datum/map_template/devarim_mapgen_1

/datum/space_level/devarim_2
	path = 'devarim-2.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 10
	ftl_mask = /datum/map_template/devarim_ftl_2
	mapgen_mask = /datum/map_template/devarim_mapgen_2

/datum/map_template/devarim_ftl_1
	name = "devarim ftl passthrough"
	mappaths = list("maps/devarim/devarim-1-ftl.dmm")

/datum/map_template/devarim_ftl_2
	name = "devarim ftl passthrough"
	mappaths = list("maps/devarim/devarim-2-ftl.dmm")

/datum/map_template/devarim_mapgen_1
	name = "devarim mapgen passthrough"
	mappaths = list("maps/devarim/devarim-1-mapgen.dmm")

/datum/map_template/devarim_mapgen_2
	name = "devarim mapgen passthrough"
	mappaths = list("maps/devarim/devarim-2-mapgen.dmm")
