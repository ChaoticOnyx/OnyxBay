/*

In short:
 * Random area alarms
 * All areas jammed
 * Random gateways spawning hellmonsters (and turn people into cluwnes if ran into)
 * Broken APCs/Fire Alarms
 * Scary music
 * Random tiles changing to culty tiles.

*/
/datum/universal_state/hell
	name = "Hell Rising"
	desc = "OH FUCK OH FUCK OH FUCK"

/datum/universal_state/hell/OnShuttleCall(mob/user)
	return 1
	/*
	if(user)
		to_chat(user, "<span class='sinister'>All you hear on the frequency is static and panicked screaming. There will be no shuttle call today.</span>")
	return 0
	*/


// Apply changes when entering state
/datum/universal_state/hell/OnEnter()
	set background = 1

	//Separated into separate procs for profiling
	MiscSet()
	KillMobs()
	SSskybox.reinstate_skyboxes("narsie", FALSE)

/datum/universal_state/hell/proc/MiscSet()
	var/list/areas = area_repository.get_areas_by_z_level(GLOB.is_player_but_not_space_area)
	for(var/i in areas)
		var/area/A = areas[i]
		for(var/turf/floor/T in A)
			if(!T.holy && prob(1))
				new /obj/effect/gateway/active/cult(T)

/datum/universal_state/hell/proc/KillMobs()
	for(var/mob/living/simple_animal/M in SSmobs.mob_list)
		if(M && !M.client)
			M.set_stat(DEAD)
