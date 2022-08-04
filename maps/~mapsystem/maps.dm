GLOBAL_DATUM_INIT(using_map, /datum/map, text2path(copytext(file2text("data/use_map"),1,-1)) || USING_MAP_DATUM; using_map = new using_map)
GLOBAL_LIST_EMPTY(all_maps)

var/const/MAP_HAS_BRANCH = 1	//Branch system for occupations, togglable
var/const/MAP_HAS_RANK = 2		//Rank system, also togglable

/hook/startup/proc/initialise_map_list()
	for(var/type in typesof(/datum/map) - /datum/map)
		var/datum/map/M
		if(type == GLOB.using_map.type)
			M = GLOB.using_map
			M.setup_map()
		else
			M = new type
		if(!M.path)
			log_error("Map '[M]' does not have a defined path, not adding to map list!")
		else
			GLOB.all_maps[M.name] = M
	return 1


/datum/map
	var/name = "Unnamed Map"
	var/full_name = "Unnamed Map"
	var/path

	var/shuttle_types = null         // Only the specified shuttles will be initialized.
	var/list/map_levels

	var/list/usable_email_tlds = list("freemail.nt")
	var/base_floor_type = /turf/simulated/floor/plating/airless // The turf type used when generating floors between Z-levels at startup.
	var/base_floor_area                                 // Replacement area, if a base_floor_type is generated. Leave blank to skip.

	var/list/allowed_jobs          //Job datums to use.
	                               //Works a lot better so if we get to a point where three-ish maps are used
	                               //We don't have to C&P ones that are only common between two of them
	                               //That doesn't mean we have to include them with the rest of the jobs though, especially for map specific ones.
	                               //Also including them lets us override already created jobs, letting us keep the datums to a minimum mostly.
	                               //This is probably a lot longer explanation than it needs to be.

	var/station_name  = "BAD Station"
	var/station_short = "Baddy"
	var/dock_name     = "THE PirateBay"
	var/boss_name     = "Captain Roger"
	var/boss_short    = "Cap'"
	var/company_name  = "BadMan"
	var/company_short = "BM"
	var/system_name = "Uncharted System"

	var/map_admin_faxes = list()

	var/shuttle_docked_message
	var/shuttle_leaving_dock
	var/shuttle_called_message
	var/shuttle_recall_message
	var/emergency_shuttle_docked_message
	var/emergency_shuttle_leaving_dock
	var/emergency_shuttle_recall_message

	/// Areas where crew members are considered to have safely left the station.
	/// Defaults to all area types on the centcom levels if left empty.
	var/list/post_round_safe_areas = list()

	var/list/station_networks = list() 		// Camera networks that will show up on the console.

	var/list/holodeck_programs = list() // map of string ids to /datum/holodeck_program instances
	var/list/holodeck_supported_programs = list() // map of maps - first level maps from list-of-programs string id (e.g. "BarPrograms") to another map
												  // this is in order to support multiple holodeck program listings for different holodecks
	                                              // second level maps from program friendly display names ("Picnic Area") to program string ids ("picnicarea")
	                                              // as defined in holodeck_programs
	var/list/holodeck_restricted_programs = list() // as above... but EVIL!

	var/allowed_spawns = list("Arrivals Shuttle","Gateway", "Cryogenic Storage", "Cyborg Storage")
	var/default_spawn = "Arrivals Shuttle"
	var/flags = 0
	var/evac_controller_type = /datum/evacuation_controller

	var/lobby_icon									// The icon which contains the lobby image(s)
	var/list/lobby_screens = list()                 // The list of lobby screen to pick() from. If left unset the first icon state is always selected.
	var/lobby_music/lobby_music                     // The track that will play in the lobby screen. Handed in the /setup_map() proc.
	var/welcome_sound = 'sound/signals/start1.ogg'	// Sound played on roundstart

	var/default_law_type = /datum/ai_laws/nanotrasen  // The default lawset use by synth units, if not overriden by their laws var.
	var/security_state = /decl/security_state/default // The default security state system to use.

	var/id_hud_icons = 'icons/mob/hud.dmi' // Used by the ID HUD (primarily sechud) overlay.

	var/list/loadout_blacklist	//list of types of loadout items that will not be pickable
	var/legacy_mode = FALSE // When TRUE, some things (like walls and windows) use their classical appearance and mechanics

	//Economy stuff
	var/starting_money = 75000		//Money in station account
	var/department_money = 5000		//Money in department accounts
	var/salary_modifier	= 1			//Multiplier to starting character money
	var/station_departments = list()//Gets filled automatically depending on jobs allowed

	//Factions prefs stuff
	var/list/faction_choices = list(
		"NanoTrasen", // NanoTrasen must be first, else Company Provocation event will break
		"Liu-Je Green Terraforming Industries",
		"Charcoal TestLabs Ltd.",
		"Blue Oceanic Explorers",
		"Milky Way Trade Union",
		"Redknight & Company Dominance Tech",
		"Indigo Special Research Collaboration"
		)

	var/list/citizenship_choices = list(
		"NanoTrasen",
		"Nova Magnitka Government",
		"Gaia Magna",
		"Moghes",
		"Ahdomai",
		"Qerrbalak",
		"Parish of the Parthenonnus Ark"
		)

	var/list/home_system_choices = list(
		"Nova Magnitka",
		"Tau Ceti",
		"Epsilon Ursae Minoris",
		"Zermig VIII",
		"Arcturia",
		"Gaia Magna",
		"Parthenonnus Ark Space Vessel"
		)

	var/list/religion_choices = list(
		"Pan-Christian United Church",
		"Mahadeva Marga",
		"Buddhism",
		"Allah Chosen Devotees",
		"A-Kami",
		"Geng Hao Dao",
		"Jesus Witnesses",
		"Syncretism",
		"Neohumanism",
		"Agnosticism",
		"Atheism"
		)

	var/list/available_events = list(
		/datum/event/nothing,
		/datum/event/apc_damage,
		/datum/event/brand_intelligence,
		/datum/event/camera_damage,
		/datum/event/economic_event,
		/datum/event/carp_migration,
		/datum/event/money_hacker,
		/datum/event/money_lotto,
		/datum/event/mundane_news,
		/datum/event/shipping_error,
		/datum/event/dust,
		/datum/event/sensor_suit_jamming,
		/datum/event/trivial_news,
		/datum/event/infestation,
		/datum/event/wallrot,
		/datum/event/electrical_storm,
		/datum/event/space_cold,
		/datum/event/spontaneous_appendicitis,
		/datum/event/communications_blackout,
		/datum/event/grid_check,
		/datum/event/ionstorm,
		/datum/event/meteor_wave,
		/datum/event/prison_break,
		/datum/event/radiation_storm,
		/datum/event/random_antag,
		/datum/event/rogue_drone,
		/datum/event/solar_storm,
		/datum/event/prison_break/virology,
		/datum/event/prison_break/xenobiology,
		/datum/event/virus_minor,
		/datum/event/stray_facehugger,
		/datum/event/wormholes,
		/datum/event/prison_break/station,
		/datum/event/spacevine,
		/datum/event/virus_major,
		/datum/event/xenomorph_infestation,
		/datum/event/biohazard_outbreak,
		/datum/event/mimic_invasion
	)

/datum/map/New()
	if(!allowed_jobs)
		allowed_jobs = subtypesof(/datum/job)
	if(!shuttle_types)
		crash_with("[src] has no shuttle_types!")

/datum/map/proc/level_has_trait(z, trait)
	return map_levels[z].has_trait(trait)

/datum/map/proc/setup_map()
	ASSERT(length(map_levels))
	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		log_to_dd("Loading map '[L.path]' at [level]")
		maploader.load_map(L.path, 1, 1, level, FALSE, FALSE, TRUE, FALSE)

	world.update_status()
	var/list/antags = GLOB.all_antag_types_
	for(var/id in antags)
		var/datum/antagonist/A = antags[id]
		A.get_starting_locations()

/datum/map/proc/send_welcome()
	return

/datum/map/proc/perform_map_generation()
	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]
		L.generate(level)

// Used to apply various post-compile procedural effects to the map.
/datum/map/proc/refresh_mining_turfs(zlevel)

	set background = 1
	set waitfor = 0

	for(var/thing in mining_walls["[zlevel]"])
		var/turf/simulated/mineral/M = thing
		M.update_icon()
	for(var/thing in mining_floors["[zlevel]"])
		var/turf/simulated/floor/asteroid/M = thing
		if(istype(M))
			M.updateMineralOverlays()

/datum/map/proc/get_network_access(network)
	switch(network)
		if(NETWORK_CIVILIAN_WEST)
			return access_mailsorting
		if(NETWORK_RESEARCH_OUTPOST)
			return access_research
		if(NETWORK_TELECOM)
			return access_heads
		if(NETWORK_COMMAND)
			return access_heads
		if(NETWORK_ENGINE, NETWORK_ENGINEERING_OUTPOST)
			return access_engine

// By default transition randomly to another zlevel
/datum/map/proc/get_transit_zlevel(current_z_level)
	var/list/candidates = list()

	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		if(level == current_z_level)
			continue

		if(!L.has_trait(ZTRAIT_CENTCOM) && !L.has_trait(ZTRAIT_SEALED))
			candidates["[level]"] = L.travel_chance

	if(!length(candidates))
		return current_z_level

	return text2num(pickweight(candidates))

/datum/map/proc/get_empty_zlevel()
	var/empty_levels = list()

	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		if(L.has_trait(ZTRAIT_EMPTY))
			empty_levels += level

	return pick(empty_levels)


/datum/map/proc/setup_economy()
	news_network.CreateFeedChannel("Nyx Daily", "SolGov Minister of Information", 1, 1)
	news_network.CreateFeedChannel("The Gibson Gazette", "Editor Mike Hammers", 1, 1)

	for(var/loc_type in typesof(/datum/trade_destination) - /datum/trade_destination)
		var/datum/trade_destination/D = new loc_type
		weighted_randomevent_locations[D] = D.viable_random_events.len
		weighted_mundaneevent_locations[D] = D.viable_mundane_events.len

	if(!station_account)
		station_account = create_account("[station_name()] Primary Account", starting_money)

	for(var/job in allowed_jobs)
		var/datum/job/J = decls_repository.get_decl(job)
		if(J.department)
			station_departments |= J.department
	for(var/department in station_departments)
		department_accounts[department] = create_account("[department] Account", department_money)

	department_accounts["Vendor"] = create_account("Vendor Account", 0)
	vendor_account = department_accounts["Vendor"]

/datum/map/proc/map_info(client/victim)
	return
// Access check is of the type requires one. These have been carefully selected to avoid allowing the janitor to see channels he shouldn't
// This list needs to be purged but people insist on adding more cruft to the radio.
/datum/map/proc/default_internal_channels()
	return list(
		num2text(PUB_FREQ)   = list(),
		num2text(AI_FREQ)    = list(access_synth),
		num2text(ENT_FREQ)   = list(),
		num2text(ERT_FREQ)   = list(access_cent_specops),
		num2text(COMM_FREQ)  = list(access_heads),
		num2text(ENG_FREQ)   = list(access_engine_equip, access_atmospherics),
		num2text(MED_FREQ)   = list(access_medical_equip),
		num2text(MED_I_FREQ) = list(access_medical_equip),
		num2text(SEC_FREQ)   = list(access_security),
		num2text(SEC_I_FREQ) = list(access_security),
		num2text(SCI_FREQ)   = list(access_tox,access_robotics,access_xenobiology),
		num2text(SUP_FREQ)   = list(access_cargo),
		num2text(SRV_FREQ)   = list(access_janitor, access_hydroponics),
	)

/datum/map/proc/get_levels_without_trait(trait)
	var/list/result = list()

	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		if(!L.has_trait(trait))
			result += level
	
	return result

/datum/map/proc/get_levels_with_trait(trait)
	var/list/result = list()

	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		if(L.has_trait(trait))
			result += level

	return result

/datum/map/proc/get_levels_with_any_trait(...)
	var/list/result = list()

	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		for(var/T in args)
			if(L.has_trait(T))
				result += level
				break
	
	return result

/datum/map/proc/get_levels_with_all_traits(...)
	var/list/result = list()

	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		var/ok = TRUE
		for(var/T in args)
			if(!L.has_trait(T))
				ok = FALSE
				break
		
		if(ok)
			result += level
	
	return result
