/// Global list of all holopads for target selection in calls
GLOBAL_LIST_EMPTY(all_holopad_devices)
#define CALL_NONE 0
#define CALL_CALLING 1
#define CALL_RINGING 2
#define CALL_IN_CALL 3

/obj/item/device/holopad
	name = "Holopad"
	desc = "Small handheld disk with controls."
	icon = 'icons/obj/holopad.dmi'
	icon_state = "holopad"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	var/voice
	var/id
	var/uniq_id
	var/obj/item/device/holopad/abonent = null
	var/call_state = CALL_NONE
	var/obj/effect/hologram = null
	var/updatingPos = 0
	origin_tech = list(TECH_DATA = 4, TECH_BLUESPACE = 2, TECH_MAGNET = 4)

/obj/item/device/holopad/Initialize()
	. = ..()
	uniq_id = random_id("holopad_device", 00000, 99999)
	id = rand(1000, 9999)
	name = "[initial(name)] [id] #[uniq_id]"
	voice = "Holopad [id]"
	GLOB.all_holopad_devices += src
	become_hearing_sensitive()
	add_think_ctx("think_ring", CALLBACK(src, nameof(.proc/think_ring)), 0)
	add_think_ctx("think_holo_pos", CALLBACK(src, nameof(.proc/think_holo_pos)), 0)
	. = ..()

/obj/item/device/holopad/Destroy()
	abonent = null
	GLOB.all_holopad_devices -= src
	. = ..()

/obj/item/device/holopad/verb/setID()
	set name="Set ID"
	set category = "Object"
	set src in usr
	var/newid = sanitize(input(usr, "What would be new ID?") as null|text, MAX_NAME_LEN)
	if(newid && CanPhysicallyInteract(usr))
		id = newid
		name = "[initial(name)] [id] #[uniq_id]"

/obj/item/device/holopad/proc/getName(override_busy = 0)
	if(call_state!=CALL_NONE && !override_busy)
		return "Holopad [id] #[uniq_id] - busy"
	else
		return "Holopad [id] #[uniq_id]"

/obj/item/device/holopad/proc/incall(obj/item/device/holopad/caller)
	if(call_state != CALL_NONE)
		return FALSE
	abonent = caller
	call_state = CALL_RINGING
	icon_state = "holopad_ringing"
	desc = "[initial(desc)] Incoming call from [caller.getName()]."
	set_next_think_ctx("think_ring", world.time + 0.1 SECONDS)
	return TRUE

/obj/item/device/holopad/proc/think_ring()
	if(call_state != CALL_RINGING)
		set_next_think_ctx("think_ring", 0)
		return

	audible_message(SPAN_WARNING("Something vibrates.."), hearing_distance = 4, splash_override = "*buzz*")
	set_next_think_ctx("think_ring", world.time + 5 SECONDS)

/obj/item/device/holopad/think()
	update_holo()

/obj/item/device/holopad/proc/placeCall(mob/user)
	var/list/Targets = list()
	for(var/obj/item/device/holopad/H in GLOB.all_holopad_devices)
		if(H == src)
			continue

		Targets[H.getName()] = H

	var/selection = input("Who do you want to call?") as null|anything in Targets
	if(!selection)
		return
	var/obj/item/device/holopad/target = Targets[selection]
	if(!target)
		return
	if(target.incall(src))
		call_state = CALL_CALLING
		abonent = target
		icon_state = "holopad_calling"
		to_chat(user, SPAN_NOTICE("Calling [sanitize(abonent.getName(1))]"))
	else
		to_chat(user, SPAN_WARNING("Remote device is busy"))

/obj/item/device/holopad/proc/acceptCall()
	if(call_state == CALL_RINGING)
		if(abonent && abonent.call_state == CALL_CALLING)
			abonent.acceptCall()
			call_state = CALL_IN_CALL
			icon_state = "holopad_in_call"
			set_next_think(world.time + 1)

			say("Connection established!", language = null, verb = "transmits")
		else
			call_state = CALL_NONE
			icon_state = initial(icon_state)
			desc = initial(desc)
			abonent = null

	else if(call_state == CALL_CALLING)
		call_state = CALL_IN_CALL
		icon_state = "holopad_in_call"
		set_next_think(world.time + 1)

		say("Connection established", language = null, verb = "transmits")

/obj/item/device/holopad/proc/hangUp(remote = 0)
	if(!remote && abonent)
		abonent.hangUp(1)

	if(call_state==CALL_NONE)
		return

	audible_message(SPAN_WARNING("Connection closed"), hearing_distance = 4)
	call_state = CALL_NONE
	icon_state = initial(icon_state)
	desc = initial(desc)
	abonent = null
	qdel(hologram)

/obj/item/device/holopad/dropped()
	update_holo()
	..()

/obj/item/device/holopad/proc/update_holo()
	if(call_state == CALL_IN_CALL)
		if(!abonent)
			return
		if(!abonent.hologram)
			abonent.hologram = new()
			abonent.hologram.name = "Hologram [sanitize(id)]"
			abonent.hologram.layer = 5
		if(isliving(loc))
			abonent.hologram.icon = getHologramIcon(build_composite_icon_omnidir(loc))
		else
			abonent.hologram.icon = icon('icons/effects/effects.dmi', "icon_state"="nothing")
		if(!abonent.updatingPos)
			abonent.set_next_think_ctx("think_holo_pos", world.time + 2)

/obj/item/device/holopad/proc/think_holo_pos()
	if(call_state != CALL_IN_CALL)
		updatingPos = FALSE
		set_next_think_ctx("think_holo_pos", 0)
		return

	updatingPos = TRUE
	if(isliving(loc))
		var/mob/living/L = loc
		hologram.dir = turn(L.dir,180)
		hologram.forceMove(L.loc)
		hologram.pixel_x = ((L.dir&4)?32:((L.dir&8)?-32:0))
		hologram.pixel_y = ((L.dir&1)?32:((L.dir&2)?-32:0))
	else if(isturf(loc))
		hologram.dir = 2
		hologram.forceMove(loc)
		hologram.pixel_x = 0
		hologram.pixel_y = 0
	else
		hangUp()

	set_next_think_ctx("think_holo_pos", world.time + 2)

/obj/item/device/holopad/attack_self(mob/user)
	switch(call_state)
		if(CALL_NONE)
			placeCall()
		if(CALL_CALLING)
			hangUp()
		if(CALL_RINGING)
			acceptCall()
		if(CALL_IN_CALL)
			hangUp()

/obj/item/device/holopad/hear_say(message, verb, datum/language/language, alt_name, italics, atom/movable/speaker, sound/speech_sound, sound_vol)
	if(call_state == CALL_IN_CALL && get_dist(src, speaker) <= 3)
		abonent?.say(message, language = null, verb = "transmits")

/obj/item/device/holopad/say_do_say(list/message_data)
	var/list/listeners = get_hearers_in_view(3, src)

	for(var/atom/movable/M in listeners)
		if(M == src)
			continue

		if(istype(M, /obj/item/device/holopad))
			continue

		if(M)
			M.hear_say(
				message_data["message"],
				message_data["verb"],
				message_data["language"],
				message_data["alt_name"],
				message_data["italics"],
				src,
				message_data["sound"],
				message_data["sound_volume"]
			)

#undef CALL_NONE
#undef CALL_CALLING
#undef CALL_RINGING
#undef CALL_IN_CALL
