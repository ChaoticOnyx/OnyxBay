#define MAX_MIMICS 16
#define MIN_MIMICS 8
#define PLAYABLE_MIMICS 3

/datum/event/mimic_invasion
	announceWhen = 40
	endWhen = 41

/datum/event/mimic_invasion/start()
	set background = 1
	set waitfor = 0

	var/mimics_count = rand(MIN_MIMICS, MAX_MIMICS)
	var/spawned = 0

	while(spawned < mimics_count)
		CHECK_TICK

		var/area/A = pick_area(list(/proc/is_station_area))
		var/obj/item/O = pick(A.contents)

		if(QDELETED(O) || !istype(O))
			continue

		var/turf/T = get_turf(O.loc)
		var/mob/living/simple_animal/hostile/mimic/M = new(T, O, null)
		log_and_message_admins("A mimic has spawned", null, T, M)

		if(spawned < PLAYABLE_MIMICS)
			M.controllable = TRUE
			notify_ghosts("A new mimic available", null, M, posses_mob = TRUE)
		else
			M.controllable = FALSE

		spawned += 1

/datum/event/mimic_invasion/announce()
	level_seven_announcement()

#undef MAX_MIMICS
#undef MIN_MIMICS
#undef PLAYABLE_MIMICS
