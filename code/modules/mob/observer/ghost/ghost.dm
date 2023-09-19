/// A list of images for things ghosts should still be able to see when they toggle darkness
GLOBAL_LIST_EMPTY(ghost_darkness_images)

/// A list of images for things ghosts should still be able to see even without ghost sight
GLOBAL_LIST_EMPTY(ghost_sightless_images)

/mob/observer/ghost
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | KEEP_TOGETHER | LONG_GLIDE
	blinded = 0
	anchored = 1	//  don't get pushed around
	universal_speak = 1

	mob_flags = MOB_FLAG_HOLY_BAD
	movement_handlers = list(/datum/movement_handler/mob/multiz_connected, /datum/movement_handler/mob/incorporeal)

	var/is_manifest = FALSE
	var/next_visibility_toggle = 0
	var/can_reenter_corpse
	var/bootime = 0
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghost - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	var/atom/movable/following = null
	var/glide_before_follow = 0

	var/admin_ghosted = FALSE

	var/has_enabled_antagHUD = FALSE
	var/medHUD = FALSE
	var/antagHUD = FALSE

	var/health_scan = FALSE
	var/chem_scan = FALSE
	var/rads_scan = FALSE
	var/gas_scan = FALSE

	/// Wheather ghost's message will contain owner's ckey.
	var/anonsay = FALSE
	/// Wheather the ghost can see other ghosts.
	var/ghostvision = TRUE
	/// Wheather the ghost has night vision enabled.
	var/seeindarkness = TRUE
	/// Wheather the ghost will examine everything it clicks on.
	var/inquisitiveness = TRUE

	var/obj/item/device/multitool/ghost_multitool

	var/list/hud_images // A list of hud images

	/// Holder for a spawners menu.
	var/datum/spawners_menu/spawners_menu = null

/mob/observer/ghost/New(mob/body)
	see_in_dark = 100
	verbs += /mob/proc/toggle_antag_pool
	verbs += /mob/proc/join_as_actor
	verbs += /mob/proc/join_response_team

	var/turf/T
	if(ismob(body))
		T = get_turf(body)               //Where is the body located?
		attack_logs_ = body.attack_logs_ //preserve our attack logs by copying them to our ghost

		set_appearance(body)

		name = body.mind?.name
		if(isnull(name))
			name = body.real_name

		mind = body.mind //we don't transfer the mind but we keep a reference to it.
	else
		spawn(10) // wait for the observer mob to receive the client's key
			mind = new /datum/mind(key)
			mind.set_current(src)

	if(!T)
		T = pick(GLOB.latejoin | GLOB.latejoin_cryo | GLOB.latejoin_gateway) //Safety in case we cannot find the body's position

	forceMove(T)
	set_glide_size(16)

	if(isnull(name))
		name = capitalize(pick(gender == MALE ? GLOB.first_names_male : GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
	real_name = name

	if(GLOB.cult)
		GLOB.cult.add_ghost_magic(src)

	ghost_multitool = new(src)

	GLOB.ghost_mob_list += src

	..()

/mob/observer/ghost/Destroy()
	GLOB.ghost_mob_list.Remove(src)
	stop_following()
	QDEL_NULL(ghost_multitool)
	if(hud_images)
		for(var/image/I in hud_images)
			show_hud_icon(I.icon_state, FALSE)
		hud_images = null
	return ..()

/mob/observer/ghost/Topic(href, href_list)
	if(src != usr)
		href_exploit(ckey, href)
		return

	if (href_list["track"])
		if(istype(href_list["track"],/mob))
			var/mob/target = locate(href_list["track"]) in SSmobs.mob_list
			if(target)
				ManualFollow(target)
		else
			var/atom/target = locate(href_list["track"])
			if(istype(target))
				ManualFollow(target)

	if(href_list["possess"])
		var/mob/living/target = locate(href_list["possess"]) in GLOB.living_mob_list_
		if(isliving(target))
			try_to_occupy(target)

/mob/observer/ghost/proc/try_to_occupy(mob/living/L)
	if(jobban_isbanned(src, "Animal"))
		to_chat(src, SPAN_WARNING("You're banned from occupying mobs!"))
		return
	if(!L.controllable)
		to_chat(src, SPAN_WARNING("[L] can't be occupied!"))
		return
	if(L.client || (L.ckey && copytext(L.ckey, 1, 2) == "@"))
		to_chat(src, SPAN_WARNING("[L] is already occupied!"))
		return
	if(!MayRespawn(TRUE, isanimal(mind?.current) || isbot(mind?.current) ? DEAD_ANIMAL_DELAY : ANIMAL_SPAWN_DELAY))
		return

	log_and_message_admins("occupied clientless mob - ([L.type]) ([L]).", src, get_turf(L), L)

	stop_following()
	L.ckey = ckey
	L.teleop = null
	L.reload_fullscreen()
	L.on_ghost_possess()

/mob/observer/ghost/verb/ghost_possess(mob/living/M in GLOB.available_mobs_for_possess)
	set name = "Ghost Possess"
	set desc = "Occupy the mob"
	set category = "Ghost"

	if(M)
		try_to_occupy(M)


/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/

/mob/observer/ghost/Life()
	..()
	if(!loc)
		return
	if(!client)
		return 0

	handle_hud_glasses()

	if(antagHUD)
		var/list/target_list = list()
		for(var/mob/living/target in oview(src, 14))
			if(target.mind && target.mind.special_role)
				target_list += target
		if(target_list.len)
			assess_targets(target_list, src)
	if(medHUD)
		process_medHUD(src)


/mob/observer/ghost/proc/process_medHUD(mob/M)
	var/client/C = M.client
	for(var/mob/living/carbon/human/patient in oview(M, 14))
		C.images += patient.hud_list[HEALTH_HUD]
		C.images += patient.hud_list[STATUS_HUD_OOC]

/mob/observer/ghost/proc/assess_targets(list/target_list, mob/observer/ghost/U)
	var/client/C = U.client
	for(var/mob/living/carbon/human/target in target_list)
		C.images += target.hud_list[SPECIALROLE_HUD]
	for(var/mob/living/silicon/target in target_list)
		C.images += target.hud_list[SPECIALROLE_HUD]
	return 1

/mob/proc/ghostize(can_reenter_corpse = CORPSE_CAN_REENTER)
	if(!key)
		return
	if(copytext(key, 1, 2) == "@")
		return

	var/mob/observer/ghost/ghost = (!QDELETED(teleop) && isghost(teleop)) ? teleop : new(src)

	hide_fullscreens()
	ghost.key = key
	ghost.can_reenter_corpse = can_reenter_corpse
	ghost.timeofdeath = is_ooc_dead() ? src.timeofdeath : world.time

	if(!ghost.client?.holder && !config.ghost.allow_antag_hud)
		ghost.verbs -= /mob/observer/ghost/verb/toggle_antagHUD

	if(ghost.client)
		ghost.updateghostprefs()
		ghost.updateghostsight()

	SEND_SIGNAL(src, SIGNAL_MOB_GHOSTIZED)

	return ghost

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/proc/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Leave your body and enter the land of the dead."

	if(is_ooc_dead())
		announce_ghost_joinleave(ghostize(can_reenter_corpse = TRUE))
		return

	if(!may_ghost())
		to_chat(src, SPAN("warning", "You may not to ghost right now."))
		return

	var/response = alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you won't be able to [config.misc.respawn_delay ? "play this round for another [config.misc.respawn_delay] minute\s" : "return to this body"]! You can't change your mind so choose wisely!)", "Are you sure you want to ghost?", "Ghost", "Stay in body")
	if(response == "Stay in body" || !may_ghost())
		return

	log_and_message_admins("has ghosted")
	var/mob/observer/ghost/ghost = ghostize(can_reenter_corpse = FALSE)
	if(ghost)
		ghost.timeofdeath = world.time // Because the living mob won't have a time of death and we want the respawn timer to work properly.
		announce_ghost_joinleave(ghost)

/mob/living/proc/may_ghost()
	return TRUE

/mob/living/carbon/human/may_ghost()
	if(istype(loc, /obj/machinery/cryopod))
		return TRUE
	if(internal_organs_by_name[BP_BRAIN])
		var/obj/item/organ/internal/cerebrum/brain/brain = internal_organs_by_name[BP_BRAIN]
		if(brain.is_broken() && stat == UNCONSCIOUS)
			return TRUE
	if(internal_organs_by_name[BP_CELL])
		var/obj/item/organ/internal/cell/C = internal_organs_by_name[BP_CELL]
		if(!C.cell || C.cell.charge <= 1)
			return TRUE
	return FALSE

/mob/living/silicon/robot/may_ghost()
	if(istype(loc, /obj/machinery/cryopod/robot))
		return TRUE
	else if(!cell || cell.charge <= 1 || !is_component_functioning("power cell"))
		return TRUE
	return FALSE

/mob/living/silicon/robot/drone/may_ghost()
	return TRUE

/mob/observer/ghost/can_use_hands()
	return 0

/mob/observer/ghost/is_active()
	return 0

/mob/observer/ghost/Stat()
	. = ..()
	if(statpanel("Status"))
		if(evacuation_controller)
			var/eta_status = evacuation_controller.get_status_panel_eta()
			if(eta_status)
				stat(null, eta_status)

/mob/observer/ghost/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"

	if(!client)
		return
	if(!(mind && mind.current && mind.current.loc && can_reenter_corpse))
		to_chat(src, SPAN("warning", "You have no body."))
		return
	if(mind.current.key && copytext(mind.current.key,1,2) != "@")	//makes sure we don't accidentally kick any clients
		to_chat(src, SPAN("warning", "Another consciousness is in your body... It is resisting you."))
		return
	stop_following()
	mind.current.key = key
	mind.current.teleop = null
	mind.current.reload_fullscreen()
	if(isliving(mind.current))
		var/mob/living/L = mind.current
		L.handle_regular_hud_updates() // So we see a proper health icon and stuff
	if(!admin_ghosted)
		announce_ghost_joinleave(mind, 0, "They now occupy their body again.")
	return 1

/mob/observer/ghost/verb/toggle_medHUD()
	set category = "Ghost"
	set name = "Toggle Medical HUD"
	set desc = "Toggles Medical HUD allowing you to see how everyone is doing"

	if(!client)
		return

	medHUD = !medHUD

	to_chat(src, SPAN_NOTICE("Medical HUD has been [medHUD ? "enabled" : "disabled"]"))

/mob/observer/ghost/verb/toggle_antagHUD()
	set category = "Ghost"
	set name = "Toggle Antag HUD"
	set desc = "Toggles Antag HUD allowing you to see who is the antagonist"

	if(!client)
		return

	var/mentor = is_mentor(client)
	if(!config.ghost.allow_antag_hud && (!client.holder || mentor))
		to_chat(src, SPAN_WARNING("Admins have disabled this for this round."))
		return

	if(jobban_isbanned(src, "AntagHUD"))
		to_chat(src, SPAN_DANGER("You have been banned from using this feature"))
		return

	if(config.ghost.antag_hud_restricted && !has_enabled_antagHUD && (!client.holder || mentor))
		var/response = tgui_alert(src, "If you turn this on, you will not be able to take any part in the round.", "Toggle Antag HUD", list("Yes", "No"))
		if(isnull(response) || response == "No")
			return
		can_reenter_corpse = 0

	if(!has_enabled_antagHUD && (!client.holder || mentor))
		has_enabled_antagHUD = TRUE

	antagHUD = !antagHUD

	to_chat(src, SPAN_NOTICE("Antag HUD has been [antagHUD ? "enabled" : "disabled"]"))

/mob/observer/ghost/verb/open_spawners_menu()
	set category = "Ghost"
	set name = "Spawners Menu"
	set desc = "See all currently available spawners"

	if(isnull(spawners_menu))
		spawners_menu = new(src)

	spawners_menu.tgui_interact(src)

/mob/observer/ghost/verb/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"

	if(!client)
		return

	var/response = tgui_input_list(src, "Choose an area to teleport to.", "Teleport", area_repository.get_areas_by_z_level())
	if(isnull(response))
		return

	var/area/chosen_area = area_repository.get_areas_by_z_level()[response]
	if(!istype(chosen_area))
		to_chat(src, "Chosen area is unavailable.")
		return

	var/list/area_turfs = get_area_turfs(chosen_area, shall_check_if_holy() ? list(/proc/is_holy_turf) : list())
	if(!length(area_turfs))
		to_chat(src, SPAN_WARNING("This area has been entirely made into sacred grounds, you cannot enter it while you are in this plane of existence!"))
		return

	ghost_to_turf(pick(area_turfs))

/mob/observer/ghost/verb/dead_tele_coord()
	set category = "Ghost"
	set name = "Teleport to Coordinate"
	set desc= "Teleport to a coordinate"

	if(!client)
		return

	var/turf_x = tgui_input_number(src, "Choose a X coordinate.", "Teleport to Coordinate")
	if(isnull(turf_x))
		return
	var/turf_y = tgui_input_number(src, "Choose an Y coordinate.", "Teleport to Coordinate")
	if(isnull(turf_y))
		return
	var/turf_z = tgui_input_number(src, "Choose a Z coordinate.", "Teleport to Coordinate")
	if(isnull(turf_z))
		return

	var/turf/T = locate(turf_x, turf_y, turf_z)
	if(istype(T))
		if(shall_check_if_holy() && is_holy_turf(T))
			return
		ghost_to_turf(T)
	else
		to_chat(src, SPAN_WARNING("Invalid coordinates."))

/mob/observer/ghost/verb/follow()
	set category = "Ghost"
	set name = "Follow"
	set desc = "Follow and haunt a mob."

	if(!client)
		return

	var/response = tgui_input_list(src, "Choose a target to follow.", "Follow", get_follow_targets())
	if(!response)
		return

	var/datum/follow_holder/holder = response
	if(!holder.show_entry())
		return

	ManualFollow(holder.followed_instance)

/mob/observer/ghost/proc/ghost_to_turf(turf/target_turf)
	if(check_is_holy_turf(target_turf))
		to_chat(src, SPAN_WARNING("The target location is holy grounds!"))
		return
	stop_following()
	forceMove(target_turf)

// This is the ghost's follow verb with an argument
/mob/observer/ghost/proc/ManualFollow(atom/movable/target)
	if(!target || target == following || target == src)
		return

	stop_following()
	following = target
	register_signal(following, SIGNAL_MOVED, /atom/movable/proc/move_to_turf)
	register_signal(following, SIGNAL_DIR_SET, /atom/proc/recursive_dir_set)
	register_signal(following, SIGNAL_QDELETING, /mob/observer/ghost/proc/stop_following)

	to_chat(src, SPAN_NOTICE("Now following \the [following]."))
	move_to_turf(following, loc, following.loc)
	glide_before_follow = src.glide_size
	src.glide_size = target.glide_size

/mob/observer/ghost/proc/stop_following()
	if(following)
		to_chat(src, SPAN_NOTICE("No longer following \the [following]."))
		unregister_signal(following, SIGNAL_MOVED)
		unregister_signal(following, SIGNAL_DIR_SET)
		unregister_signal(following, SIGNAL_QDELETING)
		following = null
		glide_size = glide_before_follow
		glide_before_follow = 0

/mob/observer/ghost/move_to_turf(atom/movable/am, old_loc, new_loc)
	var/turf/T = get_turf(new_loc)
	if(check_is_holy_turf(T))
		to_chat(src, SPAN_WARNING("You cannot follow something standing on holy grounds!"))
		return
	..()

/mob/observer/ghost/memory()
	set hidden = TRUE
	to_chat(src, SPAN_WARNING("You are dead! You have no mind to store memory!"))

/mob/observer/ghost/add_memory()
	set hidden = TRUE
	to_chat(src, SPAN_WARNING("You are dead! You have no mind to store memory!"))

/mob/observer/ghost/PostIncorporealMovement()
	stop_following()

/mob/observer/ghost/verb/analyse_health(mob/living/carbon/human/H in GLOB.human_mob_list)
	set category = null
	set name = "Analyse Health"

	show_browser(usr, medical_scan_results(H, TRUE), "window=scanconsole;size=430x350")

/mob/observer/ghost/verb/toggle_inquisition()
	set category = "Ghost"
	set name = "Toggle Inquisitiveness"
	set desc = "Sets whether your ghost examines everything on click by default"

	inquisitiveness = !inquisitiveness

	to_chat(src, SPAN_NOTICE("You [inquisitiveness ? "now" : "no longer"] examine everything you click on."))

/mob/observer/ghost/verb/toggle_health_scan()
	set category = "Ghost"
	set name = "Toggle Scan (Health)"
	set desc = "Toggles whether you health-scan living beings on click"

	health_scan = !health_scan

	to_chat(src, SPAN_NOTICE("Health scan has been [health_scan ? "enabled" : "disabled"]"))

/mob/observer/ghost/verb/toggle_chem_scan()
	set category = "Ghost"
	set name = "Toggle Scan (Chem)"
	set desc = "Toggles whether you scan living beings for chemicals and addictions on click"

	chem_scan = !chem_scan

	to_chat(src, SPAN_NOTICE("Chem scan has been [chem_scan ? "enabled" : "disabled"]"))

/mob/observer/ghost/verb/toggle_gas_scan()
	set category = "Ghost"
	set name = "Toggle Scan (Gas)"
	set desc = "Toggles whether you analyze gas contents on click"

	gas_scan = !gas_scan

	to_chat(src, SPAN_NOTICE("Gas scan has been [gas_scan ? "enabled" : "disabled"]"))

/mob/observer/ghost/verb/check_radiation()
	set category = "Ghost"
	set name = "Toggle Scan (Rads)"
	set desc = "Toggles whether you analyze radiation on click"

	rads_scan = !rads_scan

	to_chat(src, SPAN_NOTICE("Radiation scan has been [rads_scan ? "enabled" : "disabled"]"))

/mob/observer/ghost/verb/view_manfiest()
	set name = "Show Crew Manifest"
	set category = "Ghost"

	var/dat = "<meta charset=\"utf-8\">"
	dat += "<h4>Crew Manifest</h4>"
	dat += html_crew_manifest()

	show_browser(src, dat, "window=manifest;size=370x420;can_close=1")

//This is called when a ghost is drag clicked to something.
/mob/observer/ghost/MouseDrop(atom/over)
	if(!usr || !over) return
	if(isghost(usr) && usr.client && isliving(over))
		var/mob/living/M = over
		// If they an admin, see if control can be resolved.
		if(usr.client.holder && usr.client.holder.cmd_ghost_drag(src,M))
			return
		// Otherwise, see if we can possess the target.
		if(usr == src && try_possession(M))
			return
	if(istype(over, /obj/machinery/drone_fabricator))
		if(try_drone_spawn(src, over))
			return

	return ..()

/mob/observer/ghost/proc/try_possession(mob/living/M)
	if(!config.ghost.ghosts_can_possess_animals)
		to_chat(src, SPAN_WARNING("Ghosts are not permitted to possess animals."))
		return 0
	if(!M.can_be_possessed_by(src))
		return 0
	return M.do_possession(src)

/mob/observer/ghost/pointed(atom/A as mob|obj|turf in view())
	if(!..())
		return 0
	usr.visible_message(SPAN_DEADSAY("<b>[src]</b> points to [A]"))
	return 1

/mob/observer/ghost/proc/show_hud_icon(icon_state, make_visible)
	if(!hud_images)
		hud_images = list()
	var/image/hud_image = hud_images[icon_state]
	if(!hud_image)
		hud_image = image('icons/mob/mob.dmi', loc = src, icon_state = icon_state)
		hud_images[icon_state] = hud_image

	if(make_visible)
		add_client_image(hud_image)
	else
		remove_client_image(hud_image)

/mob/observer/ghost/verb/toggle_anonsay()
	set category = "Ghost"
	set name = "Toggle Anonymous Chat"
	set desc = "Toggles showing your key in dead chat"

	anonsay = !anonsay

	to_chat(src, anonsay ? SPAN_INFO("Your key won't be shown when you speak in dead chat.") : SPAN_INFO("Your key will be publicly visible again."))

/mob/observer/ghost/canface()
	return 1

/mob/proc/can_admin_interact()
	return 0

/mob/observer/ghost/can_admin_interact()
	return check_rights(R_ADMIN, 0, src)

/mob/observer/ghost/verb/toggle_ghostsee()
	set category = "Ghost"
	set name = "Toggle Ghost Vision"
	set desc = "Toggles your ability to see things only ghosts can see, like other ghosts"

	ghostvision = !ghostvision

	updateghostsight()

	to_chat(src, SPAN_NOTICE("You [ghostvision ? "now" : "no longer"] have ghost vision."))

/mob/observer/ghost/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "Ghost"

	seeindarkness = !seeindarkness

	updateghostsight()

	to_chat(src, SPAN_NOTICE("You [seeindarkness ? "now" : "no longer"] see in darkness."))

/mob/observer/ghost/proc/updateghostprefs()
	anonsay = cmptext(get_preference_value("CHAT_GHOSTANONSAY"), GLOB.PREF_YES)
	ghostvision = cmptext(get_preference_value("GHOST_SEEGHOSTS"), GLOB.PREF_YES)
	seeindarkness = cmptext(get_preference_value("GHOST_DARKVISION"), GLOB.PREF_YES)
	inquisitiveness = cmptext(get_preference_value("GHOST_INQUISITIVENESS"), GLOB.PREF_YES)

/mob/observer/ghost/proc/updateghostsight()
	if(seeindarkness)
		set_see_invisible(SEE_INVISIBLE_NOLIGHTING)
	else
		set_see_invisible(ghostvision ? SEE_INVISIBLE_OBSERVER : SEE_INVISIBLE_LIVING)
	updateghostimages()

/mob/observer/ghost/proc/updateghostimages()
	if(!client)
		return

	client.images -= GLOB.ghost_sightless_images
	client.images -= GLOB.ghost_darkness_images

	if(!seeindarkness)
		client.images |= GLOB.ghost_sightless_images

	if(ghostvision)
		client.images |= GLOB.ghost_darkness_images

	client.images -= ghost_image

/mob/observer/ghost/MayRespawn(feedback = FALSE, respawn_time = 0)
	if(!client)
		return FALSE
	if(mind?.current && (mind.current in GLOB.living_mob_list_) && (can_reenter_corpse in list(CORPSE_CAN_REENTER, CORPSE_CAN_REENTER_AND_RESPAWN)))
		if(feedback)
			to_chat(src, SPAN_WARNING("Your non-dead body prevents you from respawning."))
		return FALSE
	if(config.ghost.antag_hud_restricted && has_enabled_antagHUD == TRUE)
		if(feedback)
			to_chat(src, SPAN_WARNING("antagHUD restrictions prevent you from respawning."))
		return FALSE

	var/timedifference = world.time - timeofdeath
	if(!client.holder && respawn_time && timeofdeath && timedifference < respawn_time MINUTES)
		var/timedifference_text = time2text(respawn_time MINUTES - timedifference,"mm:ss")
		to_chat(src, SPAN_WARNING("You must have been dead for [respawn_time] minute\s to respawn. You have [timedifference_text] left."))
		return FALSE

	return TRUE

/proc/isghostmind(datum/mind/player)
	return player && !isnewplayer(player.current) && (!player.current || isghost(player.current) || (isliving(player.current) && player.current.is_ooc_dead()) || !player.current.client)

/mob/proc/check_is_holy_turf(turf/T)
	return 0

/mob/observer/ghost/check_is_holy_turf(turf/T)
	if(shall_check_if_holy() && is_holy_turf(T))
		return TRUE

/mob/observer/ghost/proc/shall_check_if_holy()
	if(invisibility >= INVISIBILITY_OBSERVER)
		return FALSE
	if(check_rights(R_ADMIN|R_FUN, 0, src))
		return FALSE
	return TRUE

/mob/observer/ghost/proc/set_appearance(mob/target)
	var/pre_alpha = alpha
	var/pre_plane = plane
	var/pre_layer = layer
	var/pre_invis = invisibility
	var/pre_opacity = opacity

	appearance = target
	appearance_flags |= initial(appearance_flags)
	alpha = pre_alpha
	plane = pre_plane
	layer = pre_layer
	opacity = pre_opacity

	overlays -= target.active_typing_indicator
	overlays -= target.active_thinking_indicator

	set_invisibility(pre_invis)
	ClearTransform()	//make goast stand up

/mob/observer/ghost/verb/respawn()
	set name = "Respawn"
	set category = "OOC"

	if(!(config.misc.abandon_allowed))
		to_chat(src, SPAN_NOTICE("Respawn is disabled."))
		return
	if(!SSticker.mode)
		to_chat(src, SPAN_NOTICE("<B>You may not attempt to respawn yet.</B>"))
		return
	if(SSticker.mode.deny_respawn)
		to_chat(src, SPAN_NOTICE("Respawn is disabled for this roundtype."))
		return
	else if(!MayRespawn(1, config.misc.respawn_delay))
		return

	to_chat(src, "You can respawn now, enjoy your new life!")
	to_chat(src, SPAN_NOTICE("<B>Make sure to play a different character, and please roleplay correctly!</B>"))
	announce_ghost_joinleave(client, 0)

	var/mob/new_player/M = new /mob/new_player()
	M.key = key
	log_and_message_admins("has respawned.", M)
