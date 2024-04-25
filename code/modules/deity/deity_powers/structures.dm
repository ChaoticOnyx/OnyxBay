/obj/structure/deity/pylon
	name = "pylon"
	desc = "A crystal platform used to communicate with the deity."
	var/list/intuned = list()

/obj/structure/deity/pylon/Destroy()
	intuned.Cut()
	return ..()

/obj/structure/deity/pylon/attack_hand(mob/living/L)
	if(!linked_deity)
		return

	if(L in intuned)
		remove_intuned(L)
	else
		add_intuned(L)

/obj/structure/deity/pylon/proc/add_intuned(mob/living/L)
	if(L in intuned)
		return

	to_chat(L, SPAN_NOTICE("You place your hands on \the [src], feeling yourself intune to its vibrations."))
	intuned |= L

/obj/structure/deity/pylon/proc/remove_intuned(mob/living/L)
	if(!(L in intuned))
		return

	to_chat(L, SPAN_WARNING("You no longer feel intuned to \the [src]."))
	intuned -= L

/obj/structure/deity/altar
	name = "altar"
	desc = "A structure made for the express purpose of religion."
	var/mob/living/target
	var/force_convert_time = 60 SECONDS
	var/conversion_start_time

/obj/structure/deity/altar/Destroy()
	if(target)
		remove_target()

	if(linked_deity)
		to_chat(src, SPAN_DANGER("You've lost an altar!"))

	return ..()

/obj/structure/deity/altar/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		var/mob/living/affecting = G.affecting

		user.visible_message(SPAN_NOTICE("[user] attempts to buckle [affecting] into \the [src]!"))
		if(do_after(user, 20, src) && user_buckle_mob(affecting, user))
			qdel(G)

	return ..()

/obj/structure/deity/altar/proc/set_target(mob/living/L)
	if(target || !linked_deity)
		return

	conversion_start_time = world.time
	target = L
	set_next_think(world.time + 1 SECOND)
	update_icon()

/obj/structure/deity/altar/proc/remove_target()
	set_next_think(0)
	target = null
	update_icon()

/obj/structure/deity/altar/think()
	if(!target || !linked_deity)
		set_next_think(0)
		return

	if(target.stat == UNCONSCIOUS)
		to_chat(linked_deity, SPAN_WARNING("\The [target] has lost consciousness, breaking \the [src]'s hold on their mind!"))
		remove_target()
		set_next_think(0)
		return

	var/time_passed = conversion_start_time - world.time
	if(time_passed <= 0)
		convert()
		remove_target()
		set_next_think(0)
		return

	var/text
	switch(time_passed)
		if(40 to 60)
			text = "You can't think straight..."
		if(20 to 40)
			text = "You feel something prodding your mind..."
		if(10 to 20)
			text = "You can't... concentrate..."
		if(0 to 10)
			text = "Can't... resist... anymore."
			to_chat(linked_deity, SPAN_WARNING("\The [target] is nearly converted!"))

	to_chat(target, SPAN_OCCULT(text))
	set_next_think(world.time + 10 SECONDS)

/// The actual conversion happens here
/obj/structure/deity/altar/proc/convert()
	visible_message(SPAN_DANGER("For one thundering moment, \the [target] cries out in pain before going limp and broken."))
	GLOB.godcult.add_antagonist_mind(target.mind, TRUE, "Servant of [linked_deity]", "Your loyalty may be faulty, but you know that it now has control over you...")

/obj/structure/deity/altar/on_update_icon()
	overlays.Cut()
	if(target)
		overlays += image('icons/effects/effects.dmi', icon_state =  "summoning")
