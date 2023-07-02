
/mob/observer/eye/cameranet/xenobio
	icon_state = "generic_camera"
	var/allowed_area = null
	var/origin
	invisibility = 44

/mob/observer/eye/cameranet/xenobio/Initialize(mapload)
	var/area/A = get_area(loc)
	allowed_area = A.name
	. = ..()

/mob/observer/eye/cameranet/xenobio/setLoc(turf/destination, force_update = FALSE)
	var/area/new_area = get_area(destination)
	if(new_area && new_area.name == allowed_area)
		return ..()
	else
		return

/obj/machinery/computer/camera_advanced/xenobio
	name = "metroid management console"
	desc = "A computer used for remotely handling metroids."
	eye_type = /mob/observer/eye/cameranet/xenobio
	var/obj/machinery/monkey_recycler/connected_recycler
	var/list/stored_metroids
	var/max_metroids = 5
	var/monkeys = 0

	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"

/obj/machinery/computer/camera_advanced/xenobio/Initialize(mapload)
	. = ..()
	actions += new /datum/action/innate/metroid_place(src)
	actions += new /datum/action/innate/metroid_pick_up(src)
	actions += new /datum/action/innate/feed_metroid(src)
	actions += new /datum/action/innate/monkey_recycle(src)
	actions += new /datum/action/innate/metroid_scan(src)
	actions += new /datum/action/innate/hotkey_help(src)

	stored_metroids = list()
	for(var/obj/machinery/monkey_recycler/recycler in GLOB.monkey_recyclers)
		if(get_area(recycler.loc) == get_area(loc))
			connected_recycler = recycler
			connected_recycler.connected += src

/obj/machinery/computer/camera_advanced/xenobio/Destroy()
	for(var/thing in stored_metroids)
		var/mob/living/carbon/metroid/S = thing
		S.forceMove(drop_location())
	stored_metroids.Cut()
	if(connected_recycler)
		connected_recycler.connected -= src
	connected_recycler = null
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/GrantActions(mob/living/user)
	..()
	register_signal(user, SIGNAL_XENO_METROID_CLICK_CTRL,  .proc/XenometroidClickCtrl)
	register_signal(user, SIGNAL_XENO_TURF_CLICK_CTRL, 	 .proc/XenoTurfClickCtrl)
	register_signal(user, SIGNAL_XENO_MONKEY_CLICK_CTRL, .proc/XenoMonkeyClickCtrl)
	register_signal(user, SIGNAL_XENO_METROID_CLICK_SHIFT, .proc/XenometroidClickShift)
	register_signal(user, SIGNAL_XENO_TURF_CLICK_SHIFT,  .proc/XenoTurfClickShift)

	//Checks for recycler on every interact, prevents issues with load order on certain maps.
	if(!connected_recycler)
		for(var/obj/machinery/monkey_recycler/recycler in GLOB.monkey_recyclers)
			if(get_area(recycler.loc) == get_area(loc))
				connected_recycler = recycler
				connected_recycler.connected += src

/obj/machinery/computer/camera_advanced/xenobio/release(mob/living/user)
	unregister_signal(user, SIGNAL_XENO_METROID_CLICK_CTRL)
	unregister_signal(user, SIGNAL_XENO_TURF_CLICK_CTRL)
	unregister_signal(user, SIGNAL_XENO_MONKEY_CLICK_CTRL)
	unregister_signal(user, SIGNAL_XENO_METROID_CLICK_SHIFT)
	unregister_signal(user, SIGNAL_XENO_TURF_CLICK_SHIFT)
	..()

/obj/machinery/computer/camera_advanced/xenobio/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/reagent_containers/food/monkeycube))
		monkeys++
		to_chat(user, SPAN_NOTICE("You feed [O] to [src]. It now has [monkeys] monkey cubes stored."))
		qdel(O)
		return
	else if(istype(O, /obj/item/storage/xenobag))
		var/obj/item/storage/P = O
		var/loaded = FALSE
		for(var/obj/G in P.contents)
			if(istype(G, /obj/item/reagent_containers/food/monkeycube))
				loaded = TRUE
				monkeys++
				qdel(G)
		if(loaded)
			to_chat(user, SPAN_NOTICE("You fill [src] with the monkey cubes stored in [O]. [src] now has [monkeys] monkey cubes stored."))
		return
	..()

/datum/action/innate/metroid_place
	name = "Place metroids"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "metroid_down"

/datum/action/innate/metroid_place/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/observer/eye/cameranet/xenobio/remote_eye = C.eyeobj
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(remote_eye.visualnet.is_turf_visible(remote_eye.loc))
		for(var/mob/living/carbon/metroid/S in X.stored_metroids)
			S.forceMove(remote_eye.loc)
			S.visible_message(SPAN_NOTICE("[S] warps in!"))
			X.stored_metroids -= S
	else
		to_chat(owner, SPAN_WARNING("Target is not near a camera. Cannot proceed."))

/datum/action/innate/metroid_pick_up
	name = "Pick up metroid"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "metroid_up"

/datum/action/innate/metroid_pick_up/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/observer/eye/cameranet/xenobio/remote_eye = C.eyeobj
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(remote_eye.visualnet.is_turf_visible(remote_eye.loc))
		for(var/mob/living/carbon/metroid/S in remote_eye.loc)
			if(X.stored_metroids.len >= X.max_metroids)
				break
			if(!S.ckey)
				if(S.buckled)
					S.Feedstop()
				S.visible_message(SPAN_NOTICE("[S] vanishes in a flash of light!"))
				S.forceMove(X)
				X.stored_metroids += S
	else
		to_chat(owner, SPAN_WARNING("Target is not near a camera. Cannot proceed."))


/datum/action/innate/feed_metroid
	name = "Feed metroids"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "monkey_down"

/datum/action/innate/feed_metroid/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/observer/eye/cameranet/xenobio/remote_eye = C.eyeobj
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(remote_eye.visualnet.is_turf_visible(remote_eye.loc))
		if(X.monkeys >= 1)
			var/mob/living/carbon/human/monkey/food = new /mob/living/carbon/human/monkey(remote_eye.loc, TRUE, owner)
			if (!QDELETED(food))
				food.LAssailant = weakref(C)
				X.monkeys--
				X.monkeys = round(X.monkeys, 0.1) //Prevents rounding errors
				to_chat(owner, SPAN_NOTICE("[X] now has [X.monkeys] monkeys stored."))
		else
			to_chat(owner, SPAN_WARNING("[X] needs to have at least 1 monkey stored. Currently has [X.monkeys] monkeys stored."))
	else
		to_chat(owner, SPAN_WARNING("Target is not near a camera. Cannot proceed."))


/datum/action/innate/monkey_recycle
	name = "Recycle Monkeys"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "monkey_up"

/datum/action/innate/monkey_recycle/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/observer/eye/cameranet/xenobio/remote_eye = C.eyeobj
	var/obj/machinery/computer/camera_advanced/xenobio/X = target
	var/obj/machinery/monkey_recycler/recycler = X.connected_recycler

	if(!recycler)
		to_chat(owner, SPAN_WARNING("There is no connected monkey recycler. Use a multitool to link one."))
		return
	if(remote_eye.visualnet.is_turf_visible(remote_eye.loc))
		for(var/mob/living/carbon/human/M in remote_eye.loc)
			if(!isMonkey(M))
				continue
			if(M.stat)
				M.visible_message(SPAN_NOTICE("[M] vanishes reclaimed for recycling!"))
				X.monkeys += recycler.cube_production
				X.monkeys = round(X.monkeys, 0.1) //Prevents rounding errors
				qdel(M)
				to_chat(owner, SPAN_NOTICE("[X] now has [X.monkeys] monkeys available."))
	else
		to_chat(owner, SPAN_WARNING("Target is not near a camera. Cannot proceed."))

/datum/action/innate/metroid_scan
	name = "Scan metroid"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "metroid_scan"

/datum/action/innate/metroid_scan/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/observer/eye/cameranet/xenobio/remote_eye = C.eyeobj

	if(remote_eye.visualnet.is_turf_visible(remote_eye.loc))
		for(var/mob/living/carbon/metroid/S in remote_eye.loc)
			metroid_scan(src, S, C, FALSE)
	else
		to_chat(owner, SPAN_WARNING("Target is not near a camera. Cannot proceed."))
/datum/action/innate/hotkey_help
	name = "Hotkey Help"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "hotkey_help"

/datum/action/innate/hotkey_help/Activate()
	if(!target || !isliving(owner))
		return
	to_chat(owner, "<b>Click shortcuts:</b>")
	to_chat(owner, "Shift-click a metroid to pick it up, or the floor to drop all held metroids.")
	to_chat(owner, "Ctrl-click a metroid to scan it.")
	to_chat(owner, "Ctrl-click or a dead monkey to recycle it, or the floor to place a new monkey.")

//
// Alternate clicks for metroid, monkey and open turf if using a xenobio console


//Picks up metroid
/mob/observer/eye/cameranet/xenobio/ShiftClick(mob/user)
	SEND_SIGNAL(user, SIGNAL_XENO_METROID_CLICK_SHIFT, src)
	..()

//Place metroids
/mob/observer/eye/cameranet/xenobio/ShiftClick(mob/user)
	SEND_SIGNAL(user, SIGNAL_XENO_TURF_CLICK_SHIFT, src)
	..()

//scans metroids
/mob/observer/eye/cameranet/xenobio/CtrlClick(mob/user)
	SEND_SIGNAL(user, SIGNAL_XENO_METROID_CLICK_CTRL, src)
	..()

//picks up dead monkies
/mob/observer/eye/cameranet/xenobio/CtrlClick(mob/user)
	SEND_SIGNAL(user, SIGNAL_XENO_MONKEY_CLICK_CTRL, src)
	..()

//places monkies
/mob/observer/eye/cameranet/xenobio/CtrlClick(mob/user)
	SEND_SIGNAL(user, SIGNAL_XENO_TURF_CLICK_CTRL, src)
	..()

// Scans metroid
/obj/machinery/computer/camera_advanced/xenobio/proc/XenometroidClickCtrl(mob/living/user, mob/living/carbon/metroid/S)
	var/mob/living/C = user
	var/mob/observer/eye/cameranet/xenobio/E = C.eyeobj
	if(!E.visualnet.is_turf_visible(S.loc))
		to_chat(user, SPAN_WARNING("Target is not near a camera. Cannot proceed."))
		return
	var/area/mobarea = get_area(S.loc)
	if(mobarea.name == E.allowed_area )
		metroid_scan(src, S, C, FALSE)

//Picks up metroid
/obj/machinery/computer/camera_advanced/xenobio/proc/XenometroidClickShift(mob/living/user, mob/living/carbon/metroid/S)
	var/mob/living/C = user
	var/mob/observer/eye/cameranet/xenobio/E = C.eyeobj
	if(!E.visualnet.is_turf_visible(S.loc))
		to_chat(user, SPAN_WARNING("Target is not near a camera. Cannot proceed."))
		return
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/mobarea = get_area(S.loc)
	if(mobarea.name == E.allowed_area )
		if(X.stored_metroids.len >= X.max_metroids)
			to_chat(C, SPAN_WARNING("metroid storage is full."))
			return
		if(S.ckey)
			to_chat(C, SPAN_WARNING("The metroid wiggled free!"))
			return
		if(S.buckled)
			S.Feedstop()
		S.visible_message(SPAN_NOTICE("[S] vanishes in a flash of light!"))
		S.forceMove(X)
		X.stored_metroids += S

//Place metroids
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickShift(mob/living/user, turf/T)

	var/mob/living/C = user
	var/mob/observer/eye/cameranet/xenobio/E = C.eyeobj
	if(!E.visualnet.is_turf_visible(T))
		to_chat(user, SPAN_WARNING("Target is not near a camera. Cannot proceed."))
		return
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/turfarea = get_area(T)
	if(turfarea.name == E.allowed_area)
		for(var/mob/living/carbon/metroid/S in X.stored_metroids)
			S.forceMove(T)
			S.visible_message(SPAN_NOTICE("[S] warps in!"))
			X.stored_metroids -= S

//Place monkey
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickCtrl(mob/living/user, turf/T)

	var/mob/living/C = user
	var/mob/observer/eye/cameranet/xenobio/E = C.eyeobj
	if(!E.visualnet.is_turf_visible(T))
		to_chat(user, SPAN_WARNING("Target is not near a camera. Cannot proceed."))
		return
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/turfarea = get_area(T)
	if(turfarea.name == E.allowed_area)
		if(X.monkeys >= 1)
			var/mob/living/carbon/human/food = new /mob/living/carbon/human/monkey(T, TRUE, C)
			if (!QDELETED(food))
				food.LAssailant = weakref(C)
				X.monkeys--
				X.monkeys = round(X.monkeys, 0.1) //Prevents rounding errors
				to_chat(C, SPAN_NOTICE("[X] now has [X.monkeys] monkeys stored."))
		else
			to_chat(C, SPAN_WARNING("[X] needs to have at least 1 monkey stored. Currently has [X.monkeys] monkeys stored."))

//Pick up monkey
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoMonkeyClickCtrl(mob/living/user, mob/living/carbon/human/M)

	if(!isMonkey(M))
		return
	var/mob/living/C = user
	var/mob/observer/eye/cameranet/xenobio/E = C.eyeobj
	if(!isturf(M.loc) || !E.visualnet.is_turf_visible(M.loc))
		to_chat(user, SPAN_WARNING("Target is not near a camera. Cannot proceed."))
		return
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/mobarea = get_area(M.loc)
	if(!X.connected_recycler)
		to_chat(C, SPAN_WARNING("There is no connected monkey recycler. Use a multitool to link one."))
		return
	if(mobarea.name == E.allowed_area)
		if(!M.stat)
			return
		M.visible_message(SPAN_NOTICE("[M] vanishes reclaimed for recycling!"))
		X.monkeys += connected_recycler.cube_production
		X.monkeys = round(X.monkeys, 0.1) //Prevents rounding errors
		qdel(M)
		to_chat(C, SPAN_NOTICE("[X] now has [X.monkeys] monkeys available."))
