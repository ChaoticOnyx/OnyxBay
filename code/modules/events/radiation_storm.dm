/datum/event/radiation_storm
	var/const/enterBelt		= 30
	var/const/radIntervall 	= 5	// Enough time between enter/leave belt for 10 hits, as per original implementation
	var/const/leaveBelt		= 90
	var/const/revokeAccess	= 140 //Hopefully long enough for radiation levels to dissipate.
	startWhen				= 2
	announceWhen			= 1
	endWhen					= revokeAccess
	var/postStartTicks 		= 0
	var/list/rad_sources = list()
	var/target_energy = 0

/datum/event/radiation_storm/announce()
	command_announcement.Announce("High levels of beta rays detected in proximity of the [location_name()]. Please evacuate into one of the shielded maintenance tunnels.", "[location_name()] Sensor Array", new_sound = GLOB.using_map.radiation_detected_sound, zlevels = affecting_z)

/datum/event/radiation_storm/start()
	make_maint_all_access()

	for(var/area/A in GLOB.hallway)
		A.set_lighting_mode(LIGHTMODE_RADSTORM, TRUE)

/datum/event/radiation_storm/tick()
	if(activeFor == enterBelt)
		target_energy = BETA_RAY_ENERGY * rand(5, 10)
		command_announcement.Announce("The [location_name()] has entered the beta rays belt. Please remain in a sheltered area until we have passed the belt.", "[location_name()] Sensor Array", zlevels = affecting_z)
		radiate()

	if(activeFor >= enterBelt && activeFor <= leaveBelt)
		postStartTicks++

		for(var/datum/radiation_source/rad_source in rad_sources)
			var/ratio = min(activeFor / (leaveBelt / 2), 1.0)
			rad_source.info.energy = target_energy * ratio
			rad_source.info.energy = max(rad_source.info.energy, INSUFFICIENT_RADIATON_ENERGY)

	if(postStartTicks == radIntervall)
		postStartTicks = 0

	else if(activeFor == leaveBelt)
		command_announcement.Announce("The [location_name()] has passed the beta rays belt. Please allow for up to one minute while radiation levels dissipate, and report to the infirmary if you experience any unusual symptoms. Maintenance will lose all access again shortly.", "[location_name()] Sensor Array", zlevels = affecting_z)

		for(var/area/A in GLOB.hallway)
			A.set_lighting_mode(LIGHTMODE_RADSTORM, FALSE)
	
	if(activeFor > leaveBelt)
		for(var/datum/radiation_source/rad_source in rad_sources)
			rad_source.info.energy -= (rad_source.info.energy * 0.1)

/datum/event/radiation_storm/proc/radiate()
	rad_sources = list()

	for(var/z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))
		rad_sources += SSradiation.z_radiate(locate(1, 1, z), new /datum/radiation_info(50 KILO CURIE, RADIATION_BETA_RAY, max(target_energy * 0.1, INSUFFICIENT_RADIATON_ENERGY)), TRUE)

/datum/event/radiation_storm/end()
	revoke_maint_all_access()
	QDEL_LIST(rad_sources)

/datum/event/radiation_storm/syndicate/radiate()
	return
