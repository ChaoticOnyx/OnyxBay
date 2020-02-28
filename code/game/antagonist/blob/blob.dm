GLOBAL_DATUM_INIT(blobs, /datum/antagonist/blob, new)

/datum/antagonist/blob
	id = "blob"
	role_text = "Blob"
	role_text_plural = "Blobs"
	welcome_text = "<span class='danger'>You are infected by the Blob!</span>\n\
	<span class='warning'>Your body is ready to give spawn to a new blob core which will eat this station.</span>\n\
	<span class='warning'>Find a good location to spawn the core and then take control and overwhelm the station!</span>\n\
	<span class='warning'>When you have found a location, wait until you spawn; this will happen automatically and you cannot speed up the process.</span>\n\
	<span class='warning'>If you go outside of the station level, or in space, then you will die; make sure your location has lots of ground to cover.</span>"
	faction = "blob"
	hard_cap = 1
	hard_cap_round = 1
	initial_spawn_req = 1
	initial_spawn_target = 1

	spawn_announcement = FALSE

	flags = ANTAG_RANDSPAWN

	var/under_quarantine = FALSE

//#warn Set countdown
	var/countdown = 300

/datum/antagonist/blob/Process()
	if (!current_antagonists.len || antags_are_dead())
		if (under_quarantine)
			command_announcement.Announce("The outbreak is neutralized, a quarantine state is lifted.", "Lifesign Alert")
			under_quarantine = FALSE

		return

	if (countdown > 0)
		countdown--

	for (var/datum/mind/antag in current_antagonists)
		if (!antag.current || !istype(antag.current, /mob/living/carbon/))
			continue

		if (countdown == 150)
			to_chat(antag.current, "<span class='alert'>You feel tired and bloated.</span>")
		else if (countdown == 50)
			to_chat(antag.current, "<span class='alert'>You feel like you are about to burst.</span>")
		else if (countdown <= 0)
			burst(antag.current)

	var/datum/objective/O = global_objectives[1]

	if (!O.completed && blob_tiles_grown_total >= O.target_amount)
		O.completed = TRUE
		SSticker.mode.blob_domination = TRUE
	else if (!antags_are_dead() && blob_tiles_grown_total >= O.target_amount * 0.05 && under_quarantine == FALSE)
		command_announcement.Announce("Confirmed outbreak of level 7 viral biohazard aboard [station_name()]. All personnel must contain the outbreak or initiate the self-destruction procedure at any cost. [station_name()] is now under quarantine, no one should exit or enter the station, all flights canceled.", "Lifesign Alert", new_sound = 'sound/AI/outbreak7.ogg')
		under_quarantine = TRUE

	if (under_quarantine && evacuation_controller.is_arriving())
		evacuation_controller.cancel_evacuation()

/datum/antagonist/blob/antags_are_dead()
	var/alive = 0

	for (var/datum/mind/antag in current_antagonists)
		if (antag.current && !antag.current.is_dead())
			alive++

	if (!alive)
		return TRUE

	return FALSE

/datum/antagonist/blob/proc/burst(mob/living/carbon/H)
	if (istype(H, /obj/effect/blob) || !H.mind)
		return

	// Spawn a blob core if the victim is on board
	if ((H.loc.z in GLOB.using_map.station_levels) && !isspace(H.loc))
		new /obj/effect/blob/core/(H.loc, 200, H.client, 3)

	H.gib()

/datum/antagonist/blob/can_late_spawn()
	return TRUE

/datum/antagonist/blob/create_global_objectives(override)
	if (!..())
		return

	global_objectives = list(new /datum/objective/blob/infest)

/datum/antagonist/blob/add_antagonist(datum/mind/player, ignore_role, do_not_equip, move_to_spawn, do_not_announce, preserve_appearance)
	. = ..()

	countdown = initial(src.countdown)

	if (!(src in SSprocessing.processing))
		START_PROCESSING(SSprocessing, src)

/* OBJECTIVES */

/datum/objective/blob/infest
	explanation_text = "Capture"

/datum/objective/blob/infest/check_completion()
	return (blob_tiles_grown_total >= target_amount)

/datum/objective/blob/infest/New()
	..()

	var/total_turfs = 0
	var/station_level = GLOB.using_map.station_levels[1]

	for (var/turf/simulated/T in block(locate(1, 1, station_level), locate(world.maxx, world.maxy, station_level)))
		total_turfs++

	target_amount = Clamp(round(0.7 * total_turfs), 1, 2000)
	explanation_text = "Infest [target_amount] tiles of [station_name()]."
