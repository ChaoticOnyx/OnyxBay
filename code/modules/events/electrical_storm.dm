/datum/event/electrical_storm
	announceWhen = 0		// Warn them shortly before it begins.
	startWhen = 30
	endWhen = 60			// Set in start()
	var/list/valid_apcs		// Shuffled list of valid APCs.

/datum/event/electrical_storm/announce()
	..()
	switch(severity)
		if(EVENT_LEVEL_MUNDANE)
			command_announcement.AnnounceLocalizeable(
				TR_DATA(L10N_ANNOUNCE_ELECTRICAL_STORM_MUNDANE, null, list("location_name" = location_name())),
				TR_DATA(L10N_ANNOUNCE_ELECTRICAL_STORM_TITLE_02, null, list("location_name" = location_name())),
				zlevels = affecting_z
			)
		if(EVENT_LEVEL_MODERATE)
			command_announcement.AnnounceLocalizeable(
				TR_DATA(L10N_ANNOUNCE_ELECTRICAL_STORM_MODERATE, null, list("location_name" = location_name())),
				TR_DATA(L10N_ANNOUNCE_ELECTRICAL_STORM_TITLE_02, null, list("location_name" = location_name())),
				zlevels = affecting_z
			)
		if(EVENT_LEVEL_MAJOR)
			command_announcement.AnnounceLocalizeable(
				TR_DATA(L10N_ANNOUNCE_ELECTRICAL_STORM_MAJOR, null, list("location_name" = location_name())),
				TR_DATA(L10N_ANNOUNCE_ELECTRICAL_STORM_TITLE_02, null, list("location_name" = location_name())),
				zlevels = affecting_z
			)

/datum/event/electrical_storm/start()
	..()
	valid_apcs = list()
	for(var/obj/machinery/power/apc/A in GLOB.apc_list)
		if(A.z in affecting_z)
			valid_apcs.Add(A)
	endWhen = (severity * 60) + startWhen

/datum/event/electrical_storm/tick()
	..()
	//See if shields can stop it first
	var/list/shields = list()
	for(var/obj/machinery/power/shield_generator/G in GLOB.machines)
		if((G.z in affecting_z) && G.running && G.check_flag(MODEFLAG_EM))
			shields += G
	if(shields.len)
		var/obj/machinery/power/shield_generator/shield_gen = pick(shields)
		//Minor breaches aren't enough to let through frying amounts of power
		if(shield_gen.take_damage(30 * severity, SHIELD_DAMTYPE_EM) <= SHIELD_BREACHED_MINOR)
			return
	if(!valid_apcs.len)
		CRASH("No valid APCs found for electrical storm event! This is likely a bug.")
	var/list/picked_apcs = list()
	for(var/i=0, i< severity*2, i++) // up to 2/4/6 APCs per tick depending on severity
		picked_apcs |= pick(valid_apcs)

	for(var/obj/machinery/power/apc/T in picked_apcs)
		// Main breaker is turned off. Consider this APC protected.
		if(!T.operating)
			continue

		// Decent chance to overload lighting circuit.
		if(prob(3 * severity))
			T.overload_lighting()

		// Relatively small chance to emag the apc as apc_damage event does.
		if(prob(0.2 * severity))
			T.emagged = 1
			T.update_icon()

		if(T.is_critical)
			T.energy_fail(10 * severity)
			continue
		else
			T.energy_fail(10 * severity * rand(severity * 2, severity * 4))

		// Very tiny chance to completely break the APC. Has a check to ensure we don't break critical APCs such as the Engine room, or AI core. Does not occur on Mundane severity.
		if(prob((0.2 * severity) - 0.2))
			T.set_broken(TRUE)



/datum/event/electrical_storm/end()
	..()
	command_announcement.AnnounceLocalizeable(
		TR_DATA(L10N_ANNOUNCE_ELECTRICAL_STORM_END, null, list("location_name" = location_name())),
		TR_DATA(L10N_ANNOUNCE_ELECTRICAL_STORM_END_TITLE, null, null)
	)
