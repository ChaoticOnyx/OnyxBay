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

	spawn_announcement_title = "Lifesign Alert"
	spawn_announcement = FALSE

	flags = ANTAG_RANDSPAWN

//#warn Set countdown
	var/countdown = 300

/datum/antagonist/blob/Process()
	if (countdown > 0)
		countdown--

	for (var/datum/mind/antag in current_antagonists)
		if (!antag.current || !istype(antag.current, /mob/living/carbon/human))
			continue

		if (countdown == 150)
			to_chat(antag.current, "<span class='alert'>You feel tired and bloated.</span>")
		else if (countdown == 50)
			to_chat(antag.current, "<span class='alert'>You feel like you are about to burst.</span>")
		else if (countdown <= 0)
			burst(antag.current)

	var/datum/objective/O = global_objectives[1]
	var/datum/game_mode/blob/B = SSticker.mode

	if (blob_tiles_grown_total >= O.target_amount)
		O.completed = TRUE
		B.check_finished()

	if (blob_tiles_grown_total >= (O.target_amount * 0.2) && !B.under_quarantine)
		B.under_quarantine = TRUE
		command_announcement.Announce("Confirmed outbreak of level 7 viral biohazard aboard [station_name()]. All personnel must contain the outbreak or initiate the self-destruction procedure at any cost. [station_name()] is now under quarantine, no one should exit or enter the station, all flights canceled.", "Lifesign Alert", new_sound = 'sound/AI/outbreak7.ogg')

	if (B.under_quarantine && evacuation_controller.is_arriving())
		evacuation_controller.cancel_evacuation()

/datum/antagonist/blob/antags_are_dead()
	var/datum/game_mode/blob/blob = SSticker.mode

	if (istype(blob))
		var/alive = 0

		for (var/datum/mind/antag in current_antagonists)
			if (!antag.current.is_dead())
				alive++

		if (!alive)
			return TRUE

	return FALSE

/datum/antagonist/blob/proc/burst(mob/living/carbon/human/H)
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

	global_objectives = list(new /datum/objective/blob/infest, new /datum/objective/blob/kill_crew)

/datum/antagonist/add_antagonist(datum/mind/player, ignore_role, do_not_equip, move_to_spawn, do_not_announce, preserve_appearance)
	. = ..()

	if (!(src in SSprocessing.processing))
		START_PROCESSING(SSprocessing, src)

/datum/antagonist/blob/post_spawn()
	. = ..()

	START_PROCESSING(SSprocessing, src)
