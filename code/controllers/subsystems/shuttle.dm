SUBSYSTEM_DEF(shuttle)
	name = "Shuttle"
	wait = 2 SECONDS
	priority = SS_PRIORITY_SHUTTLE
	init_order = SS_INIT_SHUTTLE                 //Should be initialized after all maploading is over and atoms are initialized, to ensure that landmarks have been initialized.

	var/list/shuttles = list()                   //maps shuttle tags to shuttle datums, so that they can be looked up.
	var/list/process_shuttles = list()           //simple list of shuttles, for processing
	var/list/registered_shuttle_landmarks = list()
	var/last_landmark_registration_time
	var/list/shuttle_logs = list()               //Keeps records of shuttle movement, format is list(datum/shuttle = datum/shuttle_log)

	var/list/landmarks_awaiting_sector = list()  //Stores automatic landmarks that are waiting for a sector to finish loading.
	var/list/landmarks_still_needed = list()     //Stores landmark_tags that need to be assigned to the sector (landmark_tag = sector) when registered.
	var/list/shuttles_to_initialize              //A queue for shuttles that were asked to initialize too early.

	var/tmp/list/working_shuttles

/datum/controller/subsystem/shuttle/Initialize()
	last_landmark_registration_time = world.time
	initialize_shuttles()
	. = ..()

/datum/controller/subsystem/shuttle/fire(resumed = FALSE)
	if (!resumed)
		working_shuttles = process_shuttles.Copy()

	while (working_shuttles.len)
		var/datum/shuttle/shuttle = working_shuttles[working_shuttles.len]
		working_shuttles.len--
		if(shuttle.process_state && (shuttle.Process(wait, times_fired, src) == PROCESS_KILL))
			process_shuttles -= shuttle

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/shuttle/proc/register_landmark(shuttle_landmark_tag, obj/effect/shuttle_landmark/shuttle_landmark)
	if (registered_shuttle_landmarks[shuttle_landmark_tag])
		CRASH("Attempted to register shuttle landmark with tag [shuttle_landmark_tag], but it is already registered!")
	if (istype(shuttle_landmark))
		registered_shuttle_landmarks[shuttle_landmark_tag] = shuttle_landmark
		last_landmark_registration_time = world.time
		landmarks_awaiting_sector += shuttle_landmark

/datum/controller/subsystem/shuttle/proc/get_landmark(shuttle_landmark_tag)
	return registered_shuttle_landmarks[shuttle_landmark_tag]

//This is called by gameticker after all the machines and radio frequencies have been properly initialized
/datum/controller/subsystem/shuttle/proc/initialize_shuttles()
	for(var/shuttle_type in GLOB.using_map.shuttle_types)
		var/datum/shuttle/shuttle = shuttle_type
		if((shuttle in shuttles_to_initialize) || !initial(shuttle.defer_initialisation))
			initialise_shuttle(shuttle_type, TRUE)
	shuttles_to_initialize = null

/datum/controller/subsystem/shuttle/proc/initialise_shuttle(shuttle_type, during_init = FALSE)
	if(!initialized && !during_init)
		LAZYADD(shuttles_to_initialize, shuttle_type)
		return //We'll get back to it during init.
	var/datum/shuttle/shuttle = shuttle_type
	if(initial(shuttle.category) != shuttle_type)
		shuttle = new shuttle()

/datum/controller/subsystem/shuttle/stat_entry()
	..("S:[shuttles.len], L:[registered_shuttle_landmarks.len], Landmarks w/o Sector:[landmarks_awaiting_sector.len], Missing Landmarks:[landmarks_still_needed.len]")
