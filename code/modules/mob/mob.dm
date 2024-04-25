/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	STOP_PROCESSING(SSmobs, src)

	unregister_signal(src, SIGNAL_SEE_IN_DARK_SET)
	unregister_signal(src, SIGNAL_SEE_INVISIBLE_SET)
	unregister_signal(src, SIGNAL_SIGHT_SET)

	remove_from_dead_mob_list()
	remove_from_living_mob_list()
	GLOB.player_list.Remove(src)
	SSmobs.mob_list.Remove(src)

	unset_machine()
	//SStgui.force_close_all_windows(src) Needs further investigating

	QDEL_NULL(hud_used)
	QDEL_NULL(show_inventory)
	QDEL_NULL(skybox)
	QDEL_NULL(ability_master)
	QDEL_NULL(shadow)
	QDEL_NULL(bugreporter)
	QDEL_NULL(language_menu)

	click_intercept = null

	LAssailant = null
	for(var/obj/item/grab/G in grabbed_by)
		qdel(G)
	grabbed_by.Cut()

	clear_fullscreen()
	if(ability_master)
		QDEL_NULL(ability_master)

	if(click_handlers)
		click_handlers.QdelClear()
		QDEL_NULL(click_handlers)

	if(eyeobj)
		eyeobj.release(src)
		QDEL_NULL(eyeobj)

	remove_screen_obj_references()
	if(client)
		for(var/atom/movable/AM in client.screen)
			var/atom/movable/screen/screenobj = AM
			if(!istype(screenobj) || !screenobj.globalscreen)
				qdel(screenobj)
		client.screen = list()

	ghostize()
	if(mind?.current == src)
		spellremove(src)
		mind.set_current(null)
	return ..()

/mob/proc/flash_weak_pain()
	flick("weak_pain",pain)

/mob/proc/remove_screen_obj_references()
	hands = null
	pullin = null
	purged = null
	internals = null
	oxygen = null
	i_select = null
	m_select = null
	toxin = null
	fire = null
	bodytemp = null
	healths = null
	pains = null
	throw_icon = null
	block_icon = null
	blockswitch_icon = null
	nutrition_icon = null
	pressure = null
	pain = null
	item_use_icon = null
	gun_move_icon = null
	radio_use_icon = null
	gun_setting_icon = null
	ability_master = null
	zone_sel = null
	poise_icon = null

/mob/Initialize(mapload)
	. = ..()
	if(species_language)
		add_language(species_language)
	language_menu = new (src)
	update_move_intent_slowdown()
	if(ignore_pull_slowdown)
		add_movespeed_mod_immunities(src, /datum/movespeed_modifier/pull_slowdown)
	add_think_ctx("dust", CALLBACK(src, nameof(.proc/dust)), 0)
	add_think_ctx("dust_deletion", CALLBACK(src, nameof(.proc/dust_check_delete)), 0)
	add_think_ctx("remove_from_examine_context", CALLBACK(src, nameof(.proc/remove_from_recent_examines)), 0)
	add_think_ctx("weaken_context", CALLBACK(src, nameof(.proc/Weaken)), 0)
	add_think_ctx("post_close_winset", CALLBACK(src, nameof(.proc/post_close_winset)), 0)
	register_signal(src, SIGNAL_SEE_IN_DARK_SET,	nameof(.proc/set_blackness))
	register_signal(src, SIGNAL_SEE_INVISIBLE_SET,	nameof(.proc/set_blackness))
	register_signal(src, SIGNAL_SIGHT_SET,			nameof(.proc/set_blackness))
	START_PROCESSING(SSmobs, src)

/mob/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)
	if(!client)	return

	if(is_blind() && is_deaf())
		return // We're both blind & deaf, nothing to do here

	//spaghetti code
	if(type)
		if((type & VISIBLE_MESSAGE) && is_blind())//Vision related
			if(!alt)
				return
			else
				msg = alt
				type = alt_type
		if((type & AUDIBLE_MESSAGE) && is_deaf())//Hearing related
			if(!alt)
				return
			else
				msg = alt
				type = alt_type
				if(((type & VISIBLE_MESSAGE) && is_blind()))
					return
	to_chat(src, msg)


// Show a message to all mobs and objects in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/mob/visible_message(message, self_message, blind_message, range = world.view, checkghosts = null, narrate = FALSE)
	var/list/seeing_mobs = list()
	var/list/seeing_objs = list()
	get_mobs_and_objs_in_view_fast(get_turf(src), range, seeing_mobs, seeing_objs, checkghosts)

	for(var/o in seeing_objs)
		var/obj/O = o
		O.show_message(message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)

	for(var/m in seeing_mobs)
		var/mob/M = m
		if(self_message && M == src)
			M.show_message(self_message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)
			continue

		if(isghost(M))
			M.show_message(message + " (<a href='byond://?src=\ref[M];track=\ref[src]'>F</a>)", VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)
			continue

		if(M.see_invisible >= invisibility || narrate)
			M.show_message(message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)
			continue

		if(blind_message)
			M.show_message(blind_message, AUDIBLE_MESSAGE)
			continue
	//Multiz, have shadow do same
	if(shadow)
		shadow.visible_message(message, self_message, blind_message)

// Returns an amount of power drawn from the object (-1 if it's not viable).
// If drain_check is set it will not actually drain power, just return a value.
// If surge is set, it will destroy/damage the recipient and not return any power.
// Not sure where to define this, so it can sit here for the rest of time.
/atom/proc/drain_power(drain_check,surge, amount = 0)
	return -1

// Show a message to all mobs and objects in earshot of this one
// This would be for audible actions by the src mob
// message is the message output to anyone who can hear.
// self_message (optional) is what the src mob hears.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.
/mob/audible_message(message, self_message, deaf_message, hearing_distance = world.view, checkghosts = null, narrate = FALSE)
	var/list/hearing_mobs = list()
	var/list/hearing_objs = list()
	get_mobs_and_objs_in_view_fast(get_turf(src), hearing_distance, hearing_mobs, hearing_objs, checkghosts)

	for(var/o in hearing_objs)
		var/obj/O = o
		O.show_message(message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)

	for(var/m in hearing_mobs)
		var/mob/M = m
		if(self_message && M == src)
			M.show_message(self_message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)
		else if(isghost(M))
			M.show_message(message + " (<a href='byond://?src=\ref[M];track=\ref[src]'>F</a>)", AUDIBLE_MESSAGE)
		else if(M.see_invisible >= invisibility || narrate) // Cannot view the invisible
			M.show_message(message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)
		else
			M.show_message(message, AUDIBLE_MESSAGE)

/mob/proc/findname(msg)
	for(var/mob/M in SSmobs.mob_list)
		if (M.real_name == msg)
			return M
	return 0

/mob/proc/movement_delay()
	if(istype(loc, /turf/space))
		return cached_slowdown_space

	return cached_slowdown

/mob/proc/Life()
//	if(organStructure)
//		organStructure.ProcessOrgans()
	return

#define UNBUCKLED 0
#define PARTIALLY_BUCKLED 1
#define FULLY_BUCKLED 2
/mob/proc/buckled()
	// Preliminary work for a future buckle rewrite,
	// where one might be fully restrained (like an elecrical chair), or merely secured (shuttle chair, keeping you safe but not otherwise restrained from acting)
	if(!buckled)
		return UNBUCKLED
	return restrained() ? FULLY_BUCKLED : PARTIALLY_BUCKLED

/mob/proc/is_blind()
	return ((sdisabilities & BLIND) || blinded || incapacitated(INCAPACITATION_KNOCKOUT))

/mob/proc/is_deaf()
	return ((sdisabilities & DEAF) || ear_deaf || incapacitated(INCAPACITATION_KNOCKOUT))

/mob/proc/is_physically_disabled()
	return incapacitated(INCAPACITATION_DISABLED)

/mob/proc/cannot_stand()
	return incapacitated(INCAPACITATION_KNOCKDOWN)

/mob/proc/incapacitated(incapacitation_flags = INCAPACITATION_DEFAULT)
	if((incapacitation_flags & INCAPACITATION_STUNNED) && stunned)
		return 1

	if((incapacitation_flags & INCAPACITATION_FORCELYING) && (weakened || resting || LAZYLEN(pinned)))
		return 1

	if((incapacitation_flags & INCAPACITATION_KNOCKOUT) && (stat || paralysis || sleeping || (status_flags & FAKEDEATH)))
		return 1

	if((incapacitation_flags & INCAPACITATION_RESTRAINED) && restrained())
		return 1

	if((incapacitation_flags & (INCAPACITATION_BUCKLED_PARTIALLY|INCAPACITATION_BUCKLED_FULLY)))
		var/buckling = buckled()
		if(buckling >= PARTIALLY_BUCKLED && (incapacitation_flags & INCAPACITATION_BUCKLED_PARTIALLY))
			return 1
		if(buckling == FULLY_BUCKLED && (incapacitation_flags & INCAPACITATION_BUCKLED_FULLY))
			return 1

	return 0

#undef UNBUCKLED
#undef PARTIALLY_BUCKLED
#undef FULLY_BUCKLED

/**
 * Assembles one-dimensional array of strings to display inside "Status" stat panel tab.
 */
/mob/proc/get_status_tab_items()
	SHOULD_CALL_PARENT(TRUE)
	CAN_BE_REDEFINED(TRUE)
	return list()

/**
 * Assembles two-dimensional array of objects representing action entry inside stat panel. Objects must
 * look like `list([action_category], [unclickable_action_string], [action_string], [action_holder_ref])`,
 * not passing ref makes stat entry unclickable.
 */
/mob/proc/get_actions_for_statpanel()
	SHOULD_CALL_PARENT(TRUE)
	CAN_BE_REDEFINED(TRUE)
	return list()

/mob/proc/restrained()
	return

/mob/proc/reset_view(atom/A)
	if (client)
		A = A ? A : eyeobj
		if (istype(A, /atom/movable))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			if (isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
	return

/**
 * This proc creates content for nano inventory.
 * Returns TRUE if there is content to show.
 * In case there's nothing to show - returns FALSE.
 * This is done to prevent UI from showing last opened inventory.
 * Do not forget to check what this proc has returned before actually opening UI!
 */
/mob/proc/show_inv(mob/user)
	return FALSE

// Mob verbs are faster than object verbs. See http://www.byond.com/forum/?post=1326139&page=2#comment8198716 for why this isn't atom/verb/examine()
/mob/verb/examinate(atom/to_axamine as mob|obj|turf in view(client.eye))
	set name = "Examine"
	set category = "IC"

	run_examinate(to_axamine)

/// Runs examine proc chain, generates styled description and prints it to mob's client chat.
/mob/proc/run_examinate(atom/to_axamine)
	if((isliving(src) && is_ic_dead(src)) || is_blind(src))
		to_chat(src, SPAN_NOTICE("Something is there but you can't see it."))
		return

	face_atom(to_axamine)

	var/to_examine_ref = ref(to_axamine)
	var/list/examine_result

	if(isnull(client))
		examine_result = to_axamine.examine(src)
	else
		if(LAZYISIN(client.recent_examines, to_examine_ref))
			examine_result = to_axamine.examine_more(src)

			if(!length(examine_result))
				examine_result += SPAN_NOTICE("<i>You examine [to_axamine] closer, but find nothing of interest...</i>")
		else
			examine_result = to_axamine.examine(src)
			LAZYINITLIST(client.recent_examines)
			client.recent_examines[to_examine_ref] = world.time + 1 SECOND

		set_next_think_ctx("remove_from_examine_context", world.time + 1 SECOND)

	to_chat(usr, EXAMINE_BLOCK(examine_result.Join("\n")))

/mob/proc/remove_from_recent_examines()
	SIGNAL_HANDLER

	if(isnull(client))
		return

	for(var/ref in client.recent_examines)
		if(client.recent_examines[ref] > world.time)
			continue

		LAZYREMOVE(client.recent_examines, ref)

	if(client.recent_examines)
		set_next_think_ctx("remove_from_examine_context", world.time + 1 SECOND)

/mob/verb/pointed(atom/A as mob|obj|turf in view())
	set name = "Point To"
	set category = "Object"

	if(last_time_pointed_at + 2 SECONDS >= world.time)
		return
	if(!src || !isturf(src.loc) || !(A in view(src.loc)))
		return 0
	if(istype(A, /obj/effect/decal/point))
		return 0

	var/tile = get_turf(A)
	if (!tile)
		return 0

	last_time_pointed_at = world.time

	var/obj/P = new /obj/effect/decal/point(tile)
	P.set_invisibility(invisibility)
	P.pixel_x = A.pixel_x
	P.pixel_y = A.pixel_y
	QDEL_IN(P, 2 SECONDS)
	face_atom(A)
	return 1

//Gets the mob grab conga line.
/mob/proc/ret_grab(list/L)
	if (!istype(l_hand, /obj/item/grab) && !istype(r_hand, /obj/item/grab))
		return L
	if (!L)
		L = list(src)
	for(var/A in list(l_hand,r_hand))
		if (istype(A, /obj/item/grab))
			var/obj/item/grab/G = A
			if (!(G.affecting in L))
				L += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L)
	return L

/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "Object"
	set src = usr

	if(istype(loc,/obj/mecha)) return

	if(hand)
		var/obj/item/I = l_hand
		if(I)
			I.attack_self(src)
			update_inv_l_hand()
	else
		var/obj/item/I = r_hand
		if(I)
			I.attack_self(src)
			update_inv_r_hand()
	return

/*
/mob/verb/dump_source()

	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]\n", t)
		//Foreach goto(26)
	show_browser(src, master, null)
	return
*/

/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	if(mind)
		mind.show_memory(src)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")
/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")
/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (sane)
		msg = sanitize(msg)

	if (length(memory) == 0)
		memory += msg
	else
		memory += "<BR>[msg]"

	if (popup)
		memory()

/mob/proc/update_flavor_text()
	set src in usr
	if(usr != src)
		to_chat(usr, "No.")
	var/msg = sanitize(input(usr,"Set the flavor text in your 'examine' verb. Can also be used for OOC notes about your character.","Flavor Text",html_decode(flavor_text)) as message|null, extra = 0)

	if(msg != null)
		flavor_text = msg

/mob/proc/warn_flavor_changed()
	if(flavor_text && flavor_text != "") // don't spam people that don't use it!
		to_chat(src, "<h2 class='alert'>OOC Warning:</h2>")
		to_chat(src, "<span class='alert'>Your flavor text is likely out of date! <a href='byond://?src=\ref[src];flavor_change=1'>Change</a></span>")

/mob/proc/print_flavor_text()
	if (flavor_text && flavor_text != "")
		var/msg = replacetext(flavor_text, "\n", " ")
		if(length(msg) <= 40)
			. += "<span class='notice'>[msg]</span>"
		else
			. += "<span class='notice'>[copytext_preserve_html(msg, 1, 37)]... <a href='byond://?src=\ref[src];flavor_more=1'>More...</a></span>"

/*
/mob/verb/help()
	set name = "Help"
	show_browser(src, 'html/help.html', "window=help")
	return
*/

/client/verb/changes()
	set name = "Changelog"
	set category = "OOC"
	getFiles(
		'html/pie.htc',
		'html/changelog.css',
		'html/changelog.html'
		)
	show_browser(src, 'html/changelog.html', "window=changes;size=675x800")
	if(prefs.lastchangelog != changelog_hash)
		prefs.lastchangelog = changelog_hash
		SScharacter_setup.queue_preferences_save(prefs)

/mob/new_player/verb/observe()
	set name = "Observe"
	set category = "OOC"

	if(GAME_STATE < RUNLEVEL_LOBBY)
		to_chat(src, "<span class='warning'>Please wait for server initialization to complete...</span>")
		return

	var/is_admin = 0

	if(client.holder && (client.holder.rights & R_ADMIN))
		is_admin = 1

	if(is_admin && is_ooc_dead())
		is_admin = 0

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()

	for(var/obj/O in world)				//EWWWWWWWWWWWWWWWWWWWWWWWW ~needs to be optimised
		if(!O.loc)
			continue
		if(istype(O, /obj/item/disk/nuclear))
			var/name = "Nuclear Disk"
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = O

		if(istype(O, /obj/singularity))
			var/name = "Singularity"
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = O

	for(var/mob/M in sortAtom(SSmobs.mob_list))
		var/name = M.name
		if (names.Find(name))
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1

		creatures[name] = M


	client.perspective = EYE_PERSPECTIVE

	var/eye_name = null

	var/ok = "[is_admin ? "Admin Observe" : "Observe"]"
	eye_name = input("Please, select a player!", ok, null, null) as null|anything in creatures

	if (!eye_name)
		return

	var/mob/mob_eye = creatures[eye_name]

	if(client && mob_eye)
		client.eye = mob_eye
		if (is_admin)
			client.adminobs = 1
			if(mob_eye == client.mob || client.eye == client.mob)
				client.adminobs = 0

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	unset_machine()
	reset_view(null)

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		show_browser(src, null, t1)

	if(href_list["flavor_more"])
		show_browser(usr, text("<HTML><meta charset=\"utf-8\"><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", name, replacetext(flavor_text, "\n", "<BR>")), text("window=[];size=500x200", name))
		onclose(usr, "[name]")
	if(href_list["flavor_change"])
		update_flavor_text()

	return ..()

/mob/proc/pull_damage()
	return 0

/mob/living/carbon/human/pull_damage()
	if(!lying || getBruteLoss() + getFireLoss() < 100)
		return 0
	for(var/thing in organs)
		var/obj/item/organ/external/e = thing
		if(!e || e.is_stump())
			continue
		if((e.status & ORGAN_BROKEN) && !e.splinted)
			return 1
		if(e.status & ORGAN_BLEEDING)
			return 1
	return 0

/mob/MouseDrop(mob/M)
	..()
	if(M != usr)
		return
	if(usr == src)
		return
	if(!Adjacent(usr))
		return
	if(istype(M,/mob/living/silicon/ai))
		return

	if(!show_inv(usr))
		return

	usr.show_inventory?.open()

/mob/verb/stop_pulling_verb()
	set name = "Stop Pulling"
	set category = "IC"

	stop_pulling() // Verbs are less CPU time efficient than procs.

/mob/proc/stop_pulling()
	if(pulling)
		unregister_signal(pulling, SIGNAL_QDELETING)
		pulling.pulledby = null
		pulling = null

	if(pullin)
		pullin.icon_state = "pull0"

	remove_movespeed_modifier(/datum/movespeed_modifier/pull_slowdown)

/mob/proc/start_pulling(atom/movable/AM)
	if ( !AM || !usr || src==AM || !isturf(src.loc) )	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return

	AM.on_pulling_try(src)

	if (AM.anchored)
		to_chat(src, "<span class='warning'>It won't budge!</span>")
		return

	var/mob/M = AM
	if(ismob(AM))
		if(!can_pull_mobs || !can_pull_size)
			to_chat(src, "<span class='warning'>It won't budge!</span>")
			return

		if((mob_size < M.mob_size) && (can_pull_mobs != MOB_PULL_LARGER))
			to_chat(src, "<span class='warning'>It won't budge!</span>")
			return

		if((mob_size == M.mob_size) && (can_pull_mobs == MOB_PULL_SMALLER))
			to_chat(src, "<span class='warning'>It won't budge!</span>")
			return

		// If your size is larger than theirs and you have some
		// kind of mob pull value AT ALL, you will be able to pull
		// them, so don't bother checking that explicitly.

		if(!iscarbon(src))
			M.LAssailant = null
		else
			M.LAssailant = weakref(usr)

	else if(isobj(AM))
		var/obj/I = AM
		if(!can_pull_size || can_pull_size < I.w_class)
			to_chat(src, "<span class='warning'>It won't budge!</span>")
			return

	if(pulling)
		var/pulling_old = pulling
		stop_pulling()
		// Are we pulling the same thing twice? Just stop pulling.
		if(pulling_old == AM)
			return

	src.pulling = AM
	AM.pulledby = src

	if(pullin)
		pullin.icon_state = "pull1"

	register_signal(AM, SIGNAL_QDELETING, nameof(.proc/stop_pulling))
	update_pull_slowdown(AM)

	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(H.pull_damage())
			to_chat(src, "<span class='danger'>Pulling \the [H] in their current condition would probably be a bad idea.</span>")
	//Attempted fix for people flying away through space when cuffed and dragged.
	if(ismob(AM))
		var/mob/pulled = AM
		pulled.inertia_dir = 0

/mob/proc/can_use_hands()
	return

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/is_ooc_dead()
	return stat == DEAD

// Returns true if the mob is dead for IC objects (runes, machines, etc.)
/mob/proc/is_ic_dead()
	return stat == DEAD

/mob/proc/is_ready()
	return client && !!mind

/mob/proc/get_gender()
	return gender

/mob/proc/see(message)
	if(!is_active())
		return 0
	to_chat(src, message)
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

// facing verbs
/mob/proc/canface()
	return !incapacitated()

// Not sure what to call this. Used to check if humans are wearing an AI-controlled exosuit and hence don't need to fall over yet.
/mob/proc/can_stand_overridden()
	return 0

//Updates lying and icons. Could perhaps do with a rename but I can't think of anything to describe it. / Now it DEFINITELY needs a new name, but UpdateLyingBuckledAndVerbStatus() is way too retardulous ~Toby
/mob/proc/update_canmove(prevent_update_icons = FALSE)
	var/lying_old = lying
	if(!resting && cannot_stand() && can_stand_overridden())
		lying = 0
	else if(buckled)
		anchored = 1
		if(istype(buckled))
			if(buckled.buckle_lying == -1)
				lying = incapacitated(INCAPACITATION_KNOCKDOWN)
			else
				lying = buckled.buckle_lying
			if(buckled.buckle_movable || buckled.buckle_relaymove)
				anchored = 0
	else
		lying = incapacitated(INCAPACITATION_KNOCKDOWN)

	if(lying)
		set_density(0)
		if(l_hand)
			drop_l_hand()
		if(r_hand)
			drop_r_hand()
	else
		set_density(initial(density))
	reset_layer()

	for(var/obj/item/grab/G in grabbed_by)
		if(G.force_stand())
			lying = 0

	if(lying_old != lying)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/lying, slowdown = (lying ? 10 + (weakened * 2) : 0))
		if(!prevent_update_icons)
			update_icons()

/mob/proc/reset_layer()
	if(lying)
		plane = DEFAULT_PLANE
		layer = LYING_MOB_LAYER
	else
		reset_plane_and_layer()

/mob/proc/facedir(ndir)
	if(!canface() || moving)
		return 0
	set_dir(ndir)
	if(buckled && buckled.buckle_movable)
		buckled.set_dir(ndir)
	setMoveCooldown(movement_delay())
	return 1


/mob/verb/eastface()
	set hidden = 1
	return facedir(client.client_dir(EAST))


/mob/verb/westface()
	set hidden = 1
	return facedir(client.client_dir(WEST))


/mob/verb/northface()
	set hidden = 1
	return facedir(client.client_dir(NORTH))


/mob/verb/southface()
	set hidden = 1
	return facedir(client.client_dir(SOUTH))


//This might need a rename but it should replace the can this mob use things check
/mob/proc/IsAdvancedToolUser()
	return 0

/mob/proc/Stun(amount)
	if((status_flags & CANSTUN) && !(status_flags & GODMODE))
		facing_dir = null
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
	return

/mob/proc/SetStunned(amount) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if((status_flags & CANSTUN) && !(status_flags & GODMODE))
		stunned = max(amount,0)
	return

/mob/proc/AdjustStunned(amount)
	if((status_flags & CANSTUN) && !(status_flags & GODMODE))
		stunned = max(stunned + amount,0)
	return

/mob/proc/Weaken(amount)
	if((status_flags & CANWEAKEN) && !(status_flags & GODMODE))
		facing_dir = null
		weakened = max(max(weakened,amount),0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/SetWeakened(amount)
	if((status_flags & CANWEAKEN) && !(status_flags & GODMODE))
		weakened = max(amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/AdjustWeakened(amount)
	if((status_flags & CANWEAKEN) && !(status_flags & GODMODE))
		weakened = max(weakened + amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/Paralyse(amount)
	if((status_flags & CANPARALYSE) && !(status_flags & GODMODE))
		facing_dir = null
		paralysis = max(max(paralysis,amount),0)
	return

/mob/proc/SetParalysis(amount)
	if((status_flags & CANPARALYSE) && !(status_flags & GODMODE))
		paralysis = max(amount,0)
	return

/mob/proc/AdjustParalysis(amount)
	if((status_flags & CANPARALYSE) && !(status_flags & GODMODE))
		paralysis = max(paralysis + amount,0)
	return

/mob/proc/Sleeping(amount)
	facing_dir = null
	sleeping = max(max(sleeping,amount),0)
	return

/mob/proc/SetSleeping(amount)
	sleeping = max(amount,0)
	return

/mob/proc/AdjustSleeping(amount)
	sleeping = max(sleeping + amount,0)
	return

/mob/proc/Resting(amount)
	facing_dir = null
	resting = max(max(resting,amount),0)
	return

/mob/proc/SetResting(amount)
	resting = max(amount,0)
	return

/mob/proc/AdjustResting(amount)
	resting = max(resting + amount,0)
	return

/mob/proc/get_species()
	return ""

/mob/proc/get_visible_implants(class = 0)
	var/list/visible_implants = list()
	for(var/obj/item/O in embedded)
		if(O.w_class > class)
			visible_implants += O
	return visible_implants

/mob/proc/embedded_needs_process()
	return (embedded.len > 0)

/mob/proc/yank_out_object()
	set category = "Object"
	set name = "Yank out object"
	set desc = "Remove an embedded item at the cost of bleeding and pain."
	set src in view(1)

	if(!isliving(usr) || !usr.canClick())
		return
	usr.setClickCooldown(20)

	if(usr.stat == 1)
		to_chat(usr, "You are unconcious and cannot do that!")
		return

	if(usr.restrained())
		to_chat(usr, "You are restrained and cannot do that!")
		return

	var/mob/S = src
	var/mob/U = usr
	var/list/valid_objects = list()
	var/self = null

	if(S == U)
		self = 1 // Removing object from yourself.

	valid_objects = get_visible_implants(0)
	if(!valid_objects.len)
		if(self)
			to_chat(src, "You have nothing stuck in your body that is large enough to remove.")
		else
			to_chat(U, "[src] has nothing stuck in their wounds that is large enough to remove.")
		revoke_verb(src, /mob/proc/yank_out_object)
		return

	var/obj/item/selection = input("What do you want to yank out?", "Embedded objects") in valid_objects

	if(self)
		to_chat(src, "<span class='warning'>You attempt to get a good grip on [selection] in your body.</span>")
	else
		to_chat(U, "<span class='warning'>You attempt to get a good grip on [selection] in [S]'s body.</span>")
	if(!do_mob(U, S, (selection.w_class*7), incapacitation_flags = INCAPACITATION_DEFAULT & (~INCAPACITATION_FORCELYING))) //let people pinned to stuff yank it out, otherwise they're stuck... forever!!!
		return
	if(!selection || !S || !U)
		return

	if(self)
		visible_message("<span class='warning'><b>[src] rips [selection] out of their body.</b></span>","<span class='warning'><b>You rip [selection] out of your body.</b></span>")
	else
		visible_message("<span class='warning'><b>[usr] rips [selection] out of [src]'s body.</b></span>","<span class='warning'><b>[usr] rips [selection] out of your body.</b></span>")

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/organ/external/affected

		for(var/obj/item/organ/external/organ in H.organs) //Grab the organ holding the implant.
			for(var/obj/item/O in organ.implants)
				if(O == selection)
					affected = organ

		affected.implants -= selection
		for(var/datum/wound/wound in affected.wounds)
			LAZYREMOVE(wound.embedded_objects, selection)

		H.shock_stage+=20
		affected.take_external_damage((selection.w_class * 3), 0, DAM_EDGE, "Embedded object extraction")

		if(prob(selection.w_class * 5) && affected.sever_artery()) //I'M SO ANEMIC I COULD JUST -DIE-.
			H.custom_pain("Something tears wetly in your [affected] as [selection] is pulled free!", 50, affecting = affected)

		if (ishuman(U))
			var/mob/living/carbon/human/human_user = U
			human_user.bloody_hands(H)

	else if(issilicon(src))
		var/mob/living/silicon/robot/R = src
		R.embedded -= selection
		R.adjustBruteLoss(5)
		R.adjustFireLoss(10)

	selection.forceMove(get_turf(src))
	if(!(U.l_hand && U.r_hand))
		U.pick_or_drop(selection)

	for(var/obj/item/O in pinned)
		if(O == selection)
			pinned -= O
		if(!LAZYLEN(pinned))
			anchored = 0

	valid_objects = get_visible_implants(0)
	if(!valid_objects.len)
		revoke_verb(src, /mob/proc/yank_out_object)

	return 1

//Check for brain worms in head.
/mob/proc/has_brain_worms()

	for(var/I in contents)
		if(istype(I,/mob/living/simple_animal/borer))
			return I

	return 0

/mob/on_update_icon()
	return update_icons()

// /mob/verb/face_direction()
// 	set name = "Face Direction"
// 	set category = "IC"
// 	set src = usr

// 	set_face_dir()

// 	if(!facing_dir)
// 		to_chat(usr, "You are now not facing anything.")
// 	else
// 		to_chat(usr, "You are now facing [dir2text(facing_dir)].")

/mob/proc/set_face_dir(newdir)
	if(!isnull(facing_dir) && newdir == facing_dir)
		facing_dir = null
	else if(newdir)
		set_dir(newdir)
		facing_dir = newdir
	else if(facing_dir)
		facing_dir = null
	else
		set_dir(dir)
		facing_dir = dir

/mob/set_dir()
	if(facing_dir)
		if(!canface() || lying || buckled || restrained())
			facing_dir = null
		else if(dir != facing_dir)
			return ..(facing_dir)
	else
		return ..()

/mob/proc/set_stat(new_stat)
	. = stat != new_stat
	stat = new_stat

// /mob/verb/northfaceperm()
// 	set hidden = 1
// 	set_face_dir(client.client_dir(NORTH))
//
// /mob/verb/southfaceperm()
// 	set hidden = 1
// 	set_face_dir(client.client_dir(SOUTH))
//
// /mob/verb/eastfaceperm()
// 	set hidden = 1
// 	set_face_dir(client.client_dir(EAST))
//
// /mob/verb/westfaceperm()
// 	set hidden = 1
// 	set_face_dir(client.client_dir(WEST))

/mob/proc/adjustEarDamage()
	return

/mob/proc/setEarDamage()
	return

//Throwing stuff

/mob/proc/toggle_throw_mode()
	if (src.in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/proc/throw_mode_off()
	src.in_throw_mode = 0
	if(src.throw_icon) //in case we don't have the HUD and we use the hotkey
		src.throw_icon.icon_state = "act_throw_off"

/mob/proc/throw_mode_on()
	src.in_throw_mode = 1
	if(src.throw_icon)
		src.throw_icon.icon_state = "act_throw_on"

/mob/proc/toggle_antag_pool()
	set name = "Toggle Add-Antag Candidacy"
	set desc = "Toggles whether or not you will be considered a candidate by an add-antag vote."
	set category = "OOC"
	if(isghostmind(src.mind) || isnewplayer(src))
		if(SSticker.looking_for_antags)
			if(src.mind in SSticker.antag_pool)
				SSticker.antag_pool -= src.mind
				to_chat(usr, "You have left the antag pool.")
			else
				SSticker.antag_pool += src.mind
				to_chat(usr, "You have joined the antag pool. Make sure you have the needed role set to high!")
		else
			to_chat(usr, "The game is not currently looking for antags.")
	else
		to_chat(usr, "You must be observing or in the lobby to join the antag pool.")
/mob/proc/is_invisible_to(mob/viewer)
	return (!alpha || !mouse_opacity || viewer.see_invisible < invisibility)

/client/proc/check_has_body_select()
	return mob && mob.hud_used && istype(mob.zone_sel, /atom/movable/screen/zone_sel)

/client/verb/body_toggle_head()
	set name = "body-toggle-head"
	set hidden = 1
	toggle_zone_sel(list(BP_HEAD,BP_EYES,BP_MOUTH))

/client/verb/body_r_arm()
	set name = "body-r-arm"
	set hidden = 1
	toggle_zone_sel(list(BP_R_ARM,BP_R_HAND))

/client/verb/body_l_arm()
	set name = "body-l-arm"
	set hidden = 1
	toggle_zone_sel(list(BP_L_ARM,BP_L_HAND))

/client/verb/body_chest()
	set name = "body-chest"
	set hidden = 1
	toggle_zone_sel(list(BP_CHEST))

/client/verb/body_groin()
	set name = "body-groin"
	set hidden = 1
	toggle_zone_sel(list(BP_GROIN))

/client/verb/body_r_leg()
	set name = "body-r-leg"
	set hidden = 1
	toggle_zone_sel(list(BP_R_LEG,BP_R_FOOT))

/client/verb/body_l_leg()
	set name = "body-l-leg"
	set hidden = 1
	toggle_zone_sel(list(BP_L_LEG,BP_L_FOOT))

/client/proc/toggle_zone_sel(list/zones)
	if(!check_has_body_select())
		return
	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(next_in_list(mob.zone_sel.selecting,zones))

/mob/proc/has_chem_effect(chem, threshold)
	return FALSE

/mob/proc/has_admin_rights()
	return check_rights(R_ADMIN, 0, src)

/mob/proc/handle_drowning()
	return FALSE

/mob/proc/can_drown()
	return 0

/mob/proc/get_sex()
	return gender

/mob/proc/InStasis()
	return FALSE

/mob/proc/set_see_in_dark(new_see_in_dark)
	var/old_see_in_dark = see_in_dark

	if(old_see_in_dark != new_see_in_dark)
		see_in_dark = new_see_in_dark
		SEND_SIGNAL(src, SIGNAL_SEE_IN_DARK_SET, src, old_see_in_dark, new_see_in_dark)

/mob/proc/set_see_invisible(new_see_invisible)
	var/old_see_invisible = see_invisible
	if(old_see_invisible != new_see_invisible)
		see_invisible = new_see_invisible
		SEND_SIGNAL(src, SIGNAL_SEE_INVISIBLE_SET, src, old_see_invisible, new_see_invisible)

/mob/proc/set_sight(new_sight)
	var/old_sight = sight
	if(old_sight != new_sight)
		sight = new_sight
		SEND_SIGNAL(src, SIGNAL_SIGHT_SET, src, old_sight, new_sight)

/mob/proc/set_blackness()			//Applies SEE_BLACKNESS if necessary and turns it off when you don't need it. Should be called if see_in_dark, see_invisible or sight has changed
	if((see_invisible <= SEE_INVISIBLE_NOLIGHTING) || (see_in_dark >= 8) || (sight&(SEE_TURFS|SEE_MOBS|SEE_OBJS)))
		set_sight(sight&(~SEE_BLACKNESS))
	else
		set_sight(sight|SEE_BLACKNESS)

///Update the mouse pointer of the attached client in this mob
/mob/proc/update_mouse_pointer()
	client?.mouse_pointer_icon = initial(client?.mouse_pointer_icon)

	if(mouse_override_icon)
		client?.mouse_pointer_icon = mouse_override_icon
