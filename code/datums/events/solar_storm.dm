/datum/event/solar_storm
	id = "solar_storm"
	name = "Solar Storm"
	description = "The solar storm will burn everyone out of a station."

	mtth = 3 HOURS
	difficulty = 30
	fire_only_once = TRUE


	var/const/temp_incr     = 100
	var/const/fire_loss     = 40
	var/base_solar_gen_rate
	var/list/affecting_z = list()

/datum/event/solar_storm/New()
	. = ..()

	add_think_ctx("start", CALLBACK(src, nameof(.proc/start)), 0)
	add_think_ctx("end", CALLBACK(src, nameof(.proc/end)), 0)

/datum/event/solar_storm/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Security"] * (8 MINUTES))
	. -= (SSevents.triggers.roles_count["Engineer"] * (15 MINUTES))
	. = max(1 HOUR, .)

/datum/event/solar_storm/on_fire()
	SSannounce.play_station_announce(/datum/announce/solar_storm_approach)
	adjust_solar_output(1.5)

	// 2-6 minute duration
	set_next_think_ctx("start", world.time + (1 MINUTE))
	set_next_think_ctx("end", world.time + (rand(2, 6) MINUTES))

/datum/event/solar_storm/think()
	radiate()

	set_next_think(world.time + (2 SECONDS))

/datum/event/solar_storm/proc/radiate()
	// Note: Too complicated to be worth trying to use the radiation system for this. Its only in space anyway, so we make an exception in this case.
	for(var/mob/living/L in GLOB.living_mob_list_)
		var/turf/T = get_turf(L)
		if(!T || !(T.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
			continue

		// Make sure you're in a space area or on a space turf
		if(!istype(T.loc,/area/space) && !istype(T,/turf/space))
			continue

		// Apply some heat or burn damage from the sun.
		if(istype(L, /mob/living/carbon/human))
			L.bodytemperature += temp_incr
		else
			L.adjustFireLoss(fire_loss)

/datum/event/solar_storm/proc/adjust_solar_output(mult = 1)
	if(isnull(base_solar_gen_rate))
		base_solar_gen_rate = solar_gen_rate
	solar_gen_rate = mult * base_solar_gen_rate

/datum/event/solar_storm/proc/start()
	SSannounce.play_station_announce(/datum/announce/solar_storm_start)

	adjust_solar_output(5)
	set_next_think(world.time)

/datum/event/solar_storm/proc/end()
	SSannounce.play_station_announce(/datum/announce/solar_storm_end)

	adjust_solar_output()
	set_next_think(0)
