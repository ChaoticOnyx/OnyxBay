/datum/event/gravity
	announceWhen = 30

/datum/event/gravity/setup()
	announceWhen = rand(15, 60)

/datum/event/gravity/announce()
	command_announcement.AnnounceLocalizeable(
		TR_DATA(L10N_ANNOUNCE_GRAVITY, null, null),
		TR_DATA(L10N_ANNOUNCE_GRAVITY_TITLE, null, null),
		zlevels = affecting_z
	)

/datum/event/gravity/start()
	var/obj/machinery/gravity_generator/main/GG = GLOB.station_gravity_generator
	if(!GG)
		log_debug("The gravity generator was not found while trying to start an event.")
		return
	
	GG.set_state(FALSE)
