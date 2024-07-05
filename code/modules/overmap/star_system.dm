/datum/star_system
	var/name = null
	var/desc = null
	var/parallax_property = null
	var/visitable = FALSE
	var/list/asteroids = list()
	var/threat_level = THREAT_LEVEL_NONE

	var/x = 0
	var/y = 0
	var/alignment = "unaligned"
	var/owner = "unaligned"
	var/hidden = FALSE
	var/list/system_type = null
	var/event_chance = 0
	var/list/possible_events = list()
	var/list/active_missions = list()

	var/list/system_contents = list()

	var/mission_sector = FALSE
	var/objective_sector = FALSE
	var/visited = FALSE

	var/system_traits = 0
	var/is_capital = FALSE
	var/list/adjacency_list = list()
	var/list/initial_adjacencies = list()
	var/occupying_z = 0
	var/list/wormhole_connections = list()
	var/sector = 1
	var/is_hypergate = FALSE
	var/preset_trader = null
	var/datum/trader/trader = null
	var/list/audio_cues = null
	var/mappath = /datum/map_template/empty127

/datum/star_system/New(name, desc, threat_level, alignment, owner, hidden, system_type, system_traits, is_capital, adjacency_list, wormhole_connections, x, y, parallax_property, visitable, sector, is_hypergate, audio_cues)
	. = ..()
	//Load props first.
	if(name)
		src.name = name
	if(desc)
		src.desc = desc
	if(threat_level)
		src.threat_level = threat_level
	if(alignment)
		src.alignment = alignment
	if(owner)
		src.owner = owner
	if(hidden)
		src.hidden = hidden
	if(system_type)
		src.system_type = system_type
	if(system_traits)
		src.system_traits = system_traits
	if(is_capital)
		src.is_capital = is_capital
	if(adjacency_list)
		var/list/cast_adjacency_list = adjacency_list
		src.adjacency_list = cast_adjacency_list
		src.initial_adjacencies = cast_adjacency_list.Copy()
	if(wormhole_connections)
		src.wormhole_connections = wormhole_connections
	if(x)
		src.x = x
	if(y)
		src.y = y
	if(parallax_property)
		src.parallax_property = parallax_property
	if(visitable)
		src.visitable = visitable
	if(sector)
		src.sector = sector
	if(is_hypergate)
		src.is_hypergate = is_hypergate
	if(audio_cues)
		src.audio_cues = audio_cues

/datum/star_system/proc/generate_anomaly()
	if(prob(15))
		create_wormhole()
	if(system_type)
		apply_system_effects()
		return
	switch(threat_level)
		if(THREAT_LEVEL_NONE)
			system_type = pick(
				list(
					tag = "safe",
					label = "Empty space",
				),
				list(
					tag = "nebula",
					label = "Nebula",
				),
				list(
					tag = "gas",
					label = "Gas cloud",
				),
				list(
					tag = "icefield",
					label = "Ice field",
				),
				list(
					tag = "ice_planet",
					label = "Planetary system",
				),
			)
		if(THREAT_LEVEL_UNSAFE)
			system_type = pick(
				list(
					tag = "debris",
					label = "Asteroid field",
				),
				list(
					tag = "pirate",
					label = "Debris",
				),
				list(
					tag = "nebula",
					label = "Nebula",
				),
				list(
					tag = "hazardous",
					label = "Untagged hazard",
				),
			)
		if(THREAT_LEVEL_DANGEROUS)
			system_type = pick(
				list(
					tag = "quasar",
					label = "Quasar",
				),
				list(
					tag = "radioactive",
					label = "Radioactive",
				),
				list(
					tag = "blackhole",
					label = "Black hole",
				),
			)
	apply_system_effects()

/datum/star_system/proc/spawn_asteroids()
	pass()

/datum/star_system/proc/apply_system_effects()
	pass()

/datum/star_system/proc/dist(datum/star_system/other)
	var/dx = other.x - x
	var/dy = other.y - y
	return sqrt((dx * dx) + (dy * dy))

/datum/star_system/proc/add_ship(obj/structure/overmap/OM, turf/target_turf)
	if(!system_contents.Find(OM))
		system_contents += OM

	if(OM.role == MAIN_OVERMAP && !occupying_z)
		initialize_z_level()

	var/turf/destination
	destination = locate(rand(TRANSITION_EDGE, 127 - TRANSITION_EDGE), rand(TRANSITION_EDGE, 127 - TRANSITION_EDGE), occupying_z)

	OM.forceMove(destination)
	if(istype(OM, /obj/structure/overmap))
		OM.current_system = src

	after_enter(OM)

/// Generic proc to remove ship from a system. Use `remove_fully = FALSE` when ship is landing on a system within a planet, so it will stay in the system (but not physically)
/datum/star_system/proc/remove_ship(obj/structure/overmap/OM, atom/new_loc, remove_fully = FALSE)
	if(remove_fully)
		system_contents -= OM
		OM.current_system = null

	OM.forceMove(new_loc)

	after_enter(OM)

/datum/star_system/proc/initialize_z_level()
	var/datum/map_template/map = new mappath()
	var/turf/new_center = map.load_new_z()
	occupying_z = new_center.z
	var/obj/effect/overmap_anomaly/star/star = new /obj/effect/overmap_anomaly/star(new_center)
	var/curr_offset_x = 128
	for(var/i = 1 to rand(2, 5))
		sleep(rand(1 SECOND, 5 SECONDS))
		var/obj/effect/overmap_anomaly/visitable/planetoid/planetoid = new (new_center)
		planetoid.orbit(star, curr_offset_x, FALSE, rand(4000, 5000), pre_rotation = TRUE)
		curr_offset_x += 128
		planetoid.pregenerate(i)

/datum/star_system/proc/after_enter(obj/structure/overmap/OM)
	pass()

/datum/map_template/empty127
	mappaths = list('maps/templates/empty_127.dmm')
