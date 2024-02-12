/datum/event/space_dust_base
	id = "space_dust_base"
	name = "Space Dust Incoming"
	description = "Commonish random event that causes small clumps of \"space dust\" to hit the station at high speeds. The \"dust\" will damage the hull of the station causin minor hull breaches."

	mtth = 1 HOURS
	difficulty = 35

	options = newlist(
		/datum/event_option/space_dust_option {
			id = "option_mundande";
			name = "Mundane Level";
			weight = 80;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION_R;
			event_id = "space_dust";
			description = "The station will face some difficulties";
			severity = EVENT_LEVEL_MUNDANE;
		},
		/datum/event_option/space_dust_option {
			id = "option_moderate";
			name = "Moderate Level";
			weight = 20;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION;
			event_id = "space_dust";
			description = "Damage to the hull is guaranteed...";
			severity = EVENT_LEVEL_MODERATE;
		}
	)



/datum/event/space_dust_base/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Engineer"] * (5 MINUTE))
	. = max(1 HOUR, .)

/datum/event/space_dust_base/get_conditions_description()
	. = "<em>Space Dust</em> should not be <em>running</em>.<br>"

/datum/event/space_dust_base/check_conditions()
	. = SSevents.evars["space_dust_running"] != TRUE

/datum/event_option/space_dust_option
	var/severity = EVENT_LEVEL_MUNDANE

/datum/event_option/space_dust_option/on_choose()
	SSevents.evars["space_dust_severity"] = severity

/datum/event/space_dust
	id = "space_dust"

	hide = TRUE
	triggered_only = TRUE

	var/list/affecting_z = list()
	var/severity = EVENT_LEVEL_MUNDANE

/datum/event/space_dust/New()
	. = ..()

	add_think_ctx("end", CALLBACK(src, nameof(.proc/end)), 0)

/datum/event/space_dust/on_fire()
	severity = SSevents.evars["space_dust_severity"]
	SSevents.evars["space_dust_running"] = TRUE
	affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)

	SSannounce.play_station_announce(/datum/announce/space_dust_start)

	set_next_think_ctx("end", world.time + (rand(1, 3) MINUTES))
	set_next_think(world.time)

/datum/event/space_dust/proc/end()
	set_next_think(0)
	SSevents.evars["space_dust_running"] = FALSE
	SSannounce.play_station_announce(/datum/announce/space_dust_end)

/datum/event/space_dust/think()
	if(!prob(10))
		set_next_think(world.time + (2 SECONDS))
		return

	var/numbers = rand(severity * 10, severity * 15)
	var/start_dir = pick(GLOB.cardinal)
	var/turf/startloc
	var/turf/targloc
	var/randomz = pick(affecting_z)
	var/randomx = rand(1 + TRANSITION_EDGE * 2, world.maxx-TRANSITION_EDGE * 2)
	var/randomy = rand(1 + TRANSITION_EDGE * 2, world.maxx-TRANSITION_EDGE * 2)
	switch(start_dir)
		if(NORTH)
			startloc = locate(randomx, world.maxy - TRANSITION_EDGE, randomz)
			targloc = locate(world.maxx - randomx,  1 + TRANSITION_EDGE, randomz)
		if(SOUTH)
			startloc = locate(randomx, 1 + TRANSITION_EDGE, randomz)
			targloc = locate(world.maxx - randomx, world.maxy - TRANSITION_EDGE, randomz)
		if(EAST)
			startloc = locate(world.maxx - TRANSITION_EDGE, randomy, randomz)
			targloc = locate(1 + TRANSITION_EDGE, world.maxy - randomy, randomz)
		if(WEST)
			startloc = locate(1 + TRANSITION_EDGE, randomy, randomz)
			targloc = locate(world.maxx - TRANSITION_EDGE, world.maxy - randomy, randomz)
	var/list/starters = getcircle(startloc, 3)
	starters += startloc

	var/rocks_per_tile = round(numbers/starters.len)
	for(var/turf/T in starters)
		for(var/i = 1 to rocks_per_tile)
			var/obj/item/projectile/bullet/rock/R = new(T)
			R.launch(targloc)

	set_next_think(world.time + (2 SECONDS))
