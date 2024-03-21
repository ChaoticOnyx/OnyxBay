/datum/event/communications_blackout
	id = "communications_blackout"
	name = "Communications Blackout"
	description = "For a while telecommunications will be overloaded and not available"

	mtth = 2 HOURS
	difficulty = 50

	var/list/affecting_z = list()

/datum/event/communications_blackout/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["AI"] * (28 MINUTES))
	. -= (SSevents.triggers.roles_count["Engineer"] * (13 MINUTES))
	. = max(1 HOUR, .)

/datum/event/communications_blackout/proc/announce()
	var/alert = pick("Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you*%fj00)`5vc-BZZT",
					"Ionospheric anomalies detected. Temporary telecommunication failu*3mga;b4;'1v¬-BZZZT",
					"Ionospheric anomalies detected. Temporary telec#MCi46:5.;@63-BZZZZT",
					"Ionospheric anomalies dete'fZ\\kg5_0-BZZZZZT",
					"Ionospheri:%£ MCayj^j<.3-BZZZZZZT",
					"#4nd%;f4y6,>£%-BZZZZZZZT")

	for(var/mob/living/silicon/ai/A in GLOB.player_list)	//AIs are always aware of communication blackouts.
		if(A.z in affecting_z)
			to_chat(A, "<br>")
			to_chat(A, "<span class='warning'><b>[alert]</b></span>")
			to_chat(A, "<br>")

	if(prob(80)) //Announce most of the time, just not always to give some wiggle room for possible sabotages.
		SSannounce.play_station_announce(/datum/announce/communications_blackout, alert)

/datum/event/communications_blackout/on_fire()
	affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)

	announce()

	for(var/obj/machinery/telecomms/T in telecomms_list)
		if(T.z in affecting_z)
			if(prob(T.outage_probability))
				T.overloaded_for = max(rand(3, 6) MINUTES, T.overloaded_for)
