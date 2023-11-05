/area/elpaso/shuttle/deathsquad/centcom
	name = "Deathsquad Shuttle"
	area_flags = AREA_FLAG_RAD_SHIELDED
	base_turf = /turf/space
	dynamic_lighting = 0

/area/elpaso/shuttle/deathsquad/transit
	name = "Deathsquad Shuttle Internim"
	area_flags = AREA_FLAG_RAD_SHIELDED
	base_turf = /turf/space/transit/east

/area/elpaso/shuttle/deathsquad/station
	name = "Deathsquad Shuttle Station"
	base_turf = /turf/unsimulated/floor/frozenground
	dynamic_lighting = 0

/area/elpaso/shuttle/administration
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/elpaso/shuttle/syndicate_elite
	name = "\improper Syndicate Elite Shuttle"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/elpaso/shuttle/arrival
	name = "\improper Arrival Shuttle"

/area/elpaso/shuttle/arrival/station
	icon_state = "shuttle"
	dynamic_lighting = 0

/area/elpaso/shuttle/escape/centcom
	name = "\improper Emergency Shuttle Centcom"
	icon_state = "shuttle"
	base_turf = /turf/space
	dynamic_lighting = 0
	requires_power = 0

/area/elpaso/shuttle/escape
	name = "\improper Emergency Shuttle"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/elpaso/shuttle/escape/station
	name = "\improper Emergency Shuttle Station"
	icon_state = "shuttle2"
	base_turf = /turf/simulated/floor/plating
	dynamic_lighting = 0
	requires_power = 0

/area/elpaso/shuttle/escape/transit // the area/elpaso to pass through for 3 minute transit
	name = "\improper Emergency Shuttle Transit"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north
	requires_power = 0

/area/elpaso/shuttle/administration/transit
	name = "Administration Shuttle Transit"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/east

// SYNDICATES

/area/elpaso/syndicate_mothership
	name = "\improper Syndicate Base"
	icon_state = "syndie-ship"
	requires_power = 0
	dynamic_lighting = 0

/area/elpaso/syndicate_mothership/ninja
	name = "\improper Ninja Base"
	requires_power = 0
	base_turf = /turf/space/transit/north

// RESCUE

// names are used
/area/elpaso/rescue_base
	name = "\improper Response Team Base"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = 1
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/elpaso/rescue_base/base
	name = "\improper Barracks"
	icon_state = "yellow"
	dynamic_lighting = 0
	requires_power = 0

/area/elpaso/rescue_base/start
	name = "\improper Response Team Base"
	icon_state = "shuttlered"
	base_turf = /turf/unsimulated/floor
	dynamic_lighting = 0

/area/elpaso/rescue_base/southwest
	name = "south west"
	icon_state = "southwest"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0
	requires_power = 0

/area/elpaso/rescue_base/northwest
	name = "north west"
	icon_state = "northwest"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0
	requires_power = 0

/area/elpaso/rescue_base/northeast
	name = "north east"
	icon_state = "northeast"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/rescue_base/southeast
	name = "south east"
	icon_state = "southeast"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/rescue_base/transit
	name = "\proper bluespace"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north
	requires_power = 0

// ENEMY

// names are used
/area/elpaso/syndicate_station
	name = "\improper Independant Station"
	icon_state = "yellow"
	requires_power = 0
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/elpaso/syndicate_station/start
	name = "\improper Syndicate Forward Operating Base"
	icon_state = "yellow"
	base_turf = /turf/space
	dynamic_lighting = 0
	requires_power = 0

/area/elpaso/syndicate_station/southwest
	name = "south west"
	icon_state = "southwest"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0
	requires_power = 0

/area/elpaso/syndicate_station/northwest
	name = "north west"
	icon_state = "northwest"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/syndicate_station/northeast
	name = "north east"
	icon_state = "northeast"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0
	requires_power = 0

/area/elpaso/syndicate_station/southeast
	name = "south east"
	icon_state = "southeast"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/syndicate_station/transit
	name = "\proper bluespace"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

/area/elpaso/shuttle/syndicate_elite/northwest
	icon_state = "northwest"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/shuttle/syndicate_elite/northeast
	icon_state = "northeast"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/shuttle/syndicate_elite/southwest
	icon_state = "southwest"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/shuttle/syndicate_elite/southeast
	icon_state = "southeast"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/shuttle/syndicate_elite/transit
	name = "\proper bluespace"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

/area/elpaso/skipjack_station
	name = "\improper Skipjack"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = 0
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)
	base_turf = /turf/space

/area/elpaso/skipjack_station/southwest
	name = "south west"
	icon_state = "southwest"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/skipjack_station/northwest
	name = "north west"
	icon_state = "northwest"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/skipjack_station/northeast
	name = "north east"
	icon_state = "northeast"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/skipjack_station/southeast
	name = "south east"
	icon_state = "southeast"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/skipjack_station/base
	name = "Raider Base"
	icon_state = "yellow"
	base_turf = /turf/simulated/floor/asteroid

/area/elpaso/skipjack_station/start
	name = "\improper Skipjack"
	icon_state = "shuttlered"
	base_turf = /turf/space
	dynamic_lighting = 0

/area/elpaso/skipjack_station/transit
	name = "Skipjack Transit"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north
	dynamic_lighting = 0

//Street_areas

/area/elpaso/street/north
	name = "Streets North"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/street/south
	name = "Streets South"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/alley/lib
	name = "Alley Library"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/alley/med
	name = "Alley Medical"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/alley/rnd
	name = "Alley Research"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/alley/eng
	name = "Alley Engineering"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/alley/cargo
	name = "Alley Cargo"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

/area/elpaso/alley/bar
	name = "Alley Saloon"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

area/elpaso/desert
	name = "Desert"
	base_turf = /turf/simulated/floor/natural/sand/gray
	dynamic_lighting = 0

area/elpaso/desert_inside
	name = "Desert Building"
	base_turf = /turf/simulated/floor/natural/sand/gray
	requires_power = 0
	dynamic_lighting = 0