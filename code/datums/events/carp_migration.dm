/datum/event/carp_migration_base
	id = "carp_migration_base"
	name = "Carp Migration Incoming"
	description = "Space carp will appear near the station"

	mtth = 1 HOURS
	difficulty = 55


	options = newlist(
		/datum/event_option/carp_migration_option {
			id = "option_mundane";
			name = "Mundane Level";
			description = "1 to 6 carp";
			weight = 75;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION_R;
			event_id = "carp_migration";
			severity = EVENT_LEVEL_MUNDANE;
		},
		/datum/event_option/carp_migration_option {
			id = "option_moderate";
			name = "Moderate Level";
			description = "12 to 30 carp";
			weight = 15;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION;
			event_id = "carp_migration";
			severity = EVENT_LEVEL_MODERATE;
		},
		/datum/event_option/carp_migration_option {
			id = "option_major";
			name = "Major Level";
			description = "There will be no peaceful solution";
			weight = 10;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION;
			event_id = "carp_migration";
			severity = EVENT_LEVEL_MAJOR;
		}
	)

/datum/event/carp_migration_base/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Security"] * (10 MINUTES))
	. = max(1 HOUR, .)

/datum/event/carp_migration_base/get_conditions_description()
	. = "<em>Carp Migration</em> should not be <em>running</em>."

/datum/event/carp_migration_base/check_conditions()
	. = SSevents.evars["carp_migration_running"] != TRUE

/datum/event_option/carp_migration_option
	var/severity = EVENT_LEVEL_MUNDANE

/datum/event_option/carp_migration_option/on_choose()
	SSevents.evars["carp_migration_severity"] = severity

/datum/event/carp_migration
	id = "carp_migration"
	name = "Carp Migration"

	hide = TRUE
	triggered_only = TRUE

	var/severity = EVENT_LEVEL_MUNDANE
	var/list/spawned_carp = list()

/datum/event/carp_migration/New()
	. = ..()

	add_think_ctx("announce", CALLBACK(src, nameof(.proc/announce)), 0)
	add_think_ctx("end", CALLBACK(src, nameof(.proc/end)), 0)

/datum/event/carp_migration/on_fire()
	SSevents.evars["carp_migration_running"] = TRUE
	severity = SSevents.evars["carp_migration_severity"]

	if(severity == EVENT_LEVEL_MAJOR)
		spawn_fish(length(GLOB.landmarks_list))
	else if(severity == EVENT_LEVEL_MODERATE)
		spawn_fish(rand(4, 6)) 			// 12 to 30 carp, in small groups
	else
		spawn_fish(rand(1, 3), 1, 2)	// 1 to 6 carp, alone or in pairs

	set_next_think_ctx("announce", world.time + (30 SECONDS))
	set_next_think_ctx("end", world.time + (8 MINUTES))

/datum/event/carp_migration/proc/spawn_fish(num_groups, group_size_min = 3, group_size_max = 5)
	var/list/spawn_locations = list()

	for(var/obj/effect/landmark/C in GLOB.landmarks_list)
		if(C.name == "Carp Pack")
			spawn_locations.Add(C.loc)
	spawn_locations = shuffle(spawn_locations)
	num_groups = min(num_groups, spawn_locations.len)

	var/i = 1
	while (i <= num_groups)
		var/group_size = rand(group_size_min, group_size_max)
		if(prob(96))
			for(var/j = 1, j <= group_size, j++)
				var/mob/living/simple_animal/hostile/carp/C = new(spawn_locations[i])
				spawned_carp.Add(weakref(C))
			i++
		else
			group_size = max(1,round(group_size/6))
			group_size = min(spawn_locations.len-i+1,group_size)
			for(var/j = 1, j <= group_size, j++)
				var/mob/living/simple_animal/hostile/carp/pike/P = new(spawn_locations[i+j])
				spawned_carp.Add(weakref(P))
			i += group_size

/datum/event/carp_migration/proc/end()
	SSevents.evars["carp_migration_running"] = FALSE

	for(var/weakref/thing in spawned_carp)
		var/mob/living/simple_animal/hostile/C = thing.resolve()
		if(!C?.stat)
			var/turf/T = get_turf(C)
			if(istype(T, /turf/space))
				qdel(C)

/datum/event/carp_migration/proc/announce()
	if(severity == EVENT_LEVEL_MAJOR)
		SSannounce.play_station_announce(/datum/announce/carp_migration_major)
	else
		SSannounce.play_station_announce(/datum/announce/carp_migration, "Unknown biological [spawned_carp.len == 1 ? "entity has" : "entities have"] been detected near the [station_name()], please stand-by.")
