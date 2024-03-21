/datum/event/prison_break_base
	id = "prison_break_base"
	name = "Containment Breach"
	description = "The doors in some areas will be open and the lights will be turned off"

	mtth = 3 HOURS
	difficulty = 55

	options = newlist(
		/datum/event_option/prison_break_option {
			id = "option_virology";
			name = "In Virology";
			weight = 25;
			event_id = "prison_break";
			eventDept = "Medical";
			areaName = list("Virology");
			areaType = list(/area/medical/virology, /area/medical/virologyaccess);
		},
		/datum/event_option/prison_break_option {
			id = "option_xenobiology";
			name = "In Xenobiology";
			weight = 25;
			event_id = "prison_break";
			eventDept = "Science";
			areaName = list("Xenobiology");
			areaType = list(/area/rnd/xenobiology);
			areaNotType = list(/area/rnd/xenobiology/xenoflora, /area/rnd/xenobiology/xenoflora_storage);
		},
		/datum/event_option/prison_break_option {
			id = "option_brig";
			name = "In Brig";
			weight = 25;
			event_id = "prison_break";
			eventDept = "Security";
			areaName = list("Brig");
			areaType = list(/area/security/prison, /area/security/brig);
			areaNotType = list();
		},
		/datum/event_option/prison_break_option {
			id = "option_everywhere";
			name = "Everywhere";
			weight = 25;
			event_id = "prison_break";
			eventDept = "Local";
			areaName = list("Brig","Virology", "Xenobiology");
			areaType = list(/area/security/prison, /area/security/brig, /area/medical/virology, /area/medical/virologyaccess, /area/rnd/xenobiology);
			areaNotType = list(/area/rnd/xenobiology/xenoflora, /area/rnd/xenobiology/xenoflora_storage);
		}
	)

/datum/event/prison_break_base/get_mtth()
	. = ..()
	. -= (SSevents.triggers.living_players_count * (2 MINUTES))
	. = max(1 HOUR, .)

/datum/event_option/prison_break_option
	/// Department name in announcement
	var/eventDept = "Security"
	/// Names of areas mentioned in AI and Engineering announcements
	var/list/areaName = list("Brig")
	/// Area types to include.
	var/list/areaType = list(/area/security/prison, /area/security/brig)
	/// Area types to specifically exclude.
	var/list/areaNotType = list()

/datum/event_option/prison_break_option/on_choose()
	SSevents.evars["prison_break_dept"] = eventDept
	SSevents.evars["prison_break_area_name"] = areaName
	SSevents.evars["prison_break_area_type"] = areaType
	SSevents.evars["prison_break_area_not_type"] = areaNotType

/datum/event/prison_break
	id = "prison_break"
	name = "Containment Breach"

	hide = TRUE
	triggered_only = TRUE

	/// List of areas to affect.
	var/list/area/areas = list()
	/// Department name in announcement.
	var/eventDept = "Security"
	/// Names of areas mentioned in AI and Engineering announcements.
	var/list/areaName = list("Brig")
	/// Area types to include.
	var/list/areaType = list(/area/security/prison, /area/security/brig)
	/// Area types to specifically exclude.
	var/list/areaNotType = list()
	var/list/affecting_z = list()

/datum/event/prison_break/New()
	. = ..()

	add_think_ctx("announce", CALLBACK(src, nameof(.proc/announce)), 0)
	add_think_ctx("release", CALLBACK(src, nameof(.proc/release)), 0)

/datum/event/prison_break/on_fire()
	affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)
	eventDept = SSevents.evars["prison_break_dept"]
	areaName = SSevents.evars["prison_break_area_name"]
	areaType = SSevents.evars["prison_break_area_type"]
	areaNotType = SSevents.evars["prison_break_area_not_type"]

	for(var/area/A in world)
		if(is_type_in_list(A,areaType) && !is_type_in_list(A,areaNotType))
			areas += A

	if(areas && areas.len > 0)
		var/my_department = "[station_name()] firewall subroutines"
		var/rc_message = "An unknown malicious program has been detected in the [english_list(areaName)] lighting and airlock control systems at [stationtime2text()]. Systems will be fully compromised within approximately three minutes. Direct intervention is required immediately.<br>"

		for(var/obj/machinery/message_server/MS in world)
			MS.send_rc_message("Engineering", my_department, rc_message, "", "", 2)

		for(var/mob/living/silicon/ai/A in GLOB.player_list)
			to_chat(A, SPAN("danger", "Malicious program detected in the [english_list(areaName)] lighting and airlock control systems by [my_department]."))

	else
		to_world_log("ERROR: Could not initate grey-tide. Unable to find suitable containment area.")
		return

	set_next_think_ctx("announce", world.time + (rand(75, 105) SECONDS))
	set_next_think_ctx("release", world.time + (rand(60, 90) SECONDS))

/datum/event/prison_break/proc/release()
	if(areas && areas.len > 0)
		var/obj/machinery/power/apc/theAPC = null
		for(var/area/A in areas)
			theAPC = A.get_apc()
			if(theAPC && theAPC.operating)	//If the apc's off, it's a little hard to overload the lights.
				for(var/obj/machinery/light/L in A)
					L.flicker(10)

			A.prison_break()

/datum/event/prison_break/proc/announce()
	if(areas && areas.len > 0)
		SSannounce.play_station_announce(/datum/announce/prison_break,
			"[pick("Gr3y.T1d3 virus","Malignant trojan")] detected in [station_name()] [(eventDept == "Security")? "imprisonment":"containment"] subroutines. Secure any compromised areas immediately. [station_name()] AI involvement is recommended.",
			"[eventDept] Alert",
		)
