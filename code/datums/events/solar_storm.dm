/datum/event/solar_storm
	id = "solar_storm"
	name = "Solar Storm"
	description = "The solar storm will burn everyone out of a station."

	fire_only_once = TRUE
	mtth = 3 HOURS
	blacklisted_maps = list(/datum/map/polar)

	var/const/temp_incr     = 100
	var/const/fire_loss     = 40
	var/base_solar_gen_rate
	var/list/affecting_z = list()

/datum/event/solar_storm/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Security"] * (8 MINUTES))
	. -= (SSevents.triggers.roles_count["Engineer"] * (15 MINUTES))
	. = max(1 HOUR, .)

/datum/event/solar_storm/on_fire()
	affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)
	command_announcement.Announce("A solar storm has been detected approaching the [station_name()]. Please halt all EVA activites immediately and return inside.", "[station_name()] Sensor Array", zlevels = affecting_z)
	adjust_solar_output(1.5)

	// 2-6 minute duration
	addtimer(CALLBACK(src, .proc/start), 1 MINUTE)
	addtimer(CALLBACK(src, .proc/end), rand(2, 6) MINUTES)

/datum/event/solar_storm/think()
	radiate()

	set_next_think(world.time + 2 SECONDS)

/datum/event/solar_storm/proc/radiate()
	// Note: Too complicated to be worth trying to use the radiation system for this.  Its only in space anyway, so we make an exception in this case.
	for(var/mob/living/L in GLOB.living_mob_list_)
		var/turf/T = get_turf(L)
		if(!T || !(T.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
			continue

		if(!istype(T.loc,/area/space) && !istype(T,/turf/space))	//Make sure you're in a space area or on a space turf
			continue

		//Apply some heat or burn damage from the sun.
		if(istype(L, /mob/living/carbon/human))
			L.bodytemperature += temp_incr
		else
			L.adjustFireLoss(fire_loss)

/datum/event/solar_storm/proc/adjust_solar_output(mult = 1)
	if(isnull(base_solar_gen_rate))
		base_solar_gen_rate = solar_gen_rate
	solar_gen_rate = mult * base_solar_gen_rate

/datum/event/solar_storm/proc/start()
	command_announcement.Announce("The solar storm has reached the [station_name()]. Please refain from EVA and remain inside until it has passed.", "[station_name()] Sensor Array", zlevels = affecting_z)
	adjust_solar_output(5)

	set_next_think(world.time)

/datum/event/solar_storm/proc/end()
	command_announcement.Announce("The solar storm has passed the [station_name()]. It is now safe to resume EVA activities. ", "[station_name()] Sensor Array", zlevels = affecting_z)
	adjust_solar_output()
	set_next_think(0)
