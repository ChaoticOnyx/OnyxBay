/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = ITEM_SIZE_HUGE
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE
	req_access = list(access_armory)
	var/locked = 1
	var/broken = 0
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"

/obj/item/storage/lockbox/Initialize()
	update_icon()
	. = ..()

/obj/item/storage/lockbox/update_icon()
	if(locked)
		icon_state = icon_locked
		return
	if(broken)
		icon_state = icon_broken
		return
	icon_state = icon_closed

/obj/item/storage/lockbox/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/card/id))
		if(broken)
			to_chat(user, SPAN_WARNING("[src] broken!"))
			. = ..()
		if(check_access(W))
			locked = !locked
			update_icon()
			if(locked)
				to_chat(user, SPAN_NOTICE("You lock \the [src]!"))
				close_all()
				return
			else
				to_chat(user, SPAN_NOTICE("You unlock \the [src]!"))
				return
		to_chat(user, SPAN_WARNING("Wrong access!"))
		return

	if(istype(W, /obj/item/melee/energy))
		var/obj/item/melee/energy/WS = W
		if(broken)
			to_chat(user, SPAN_WARNING("[src] already broken!"))
			. = ..()
		if(WS.active)
			emag_act(INFINITY, user, W, "The locker has been sliced open by [user] with an energy blade!", "You hear metal being sliced and sparks flying.")
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, loc)
			spark_system.start()
			playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
			playsound(loc, SFX_SPARK, 50, 1)
			broken = !broken
			update_icon()
			return

	. = ..()

/obj/item/storage/lockbox/attack_hand(mob/user)
	add_fingerprint(user)

	if(locked && (loc == user)) // lockbox onmob?
		to_chat(usr, SPAN_WARNING("[src] is locked and cannot be opened!"))
		return
	else if(!locked && (loc == user))
		open(usr)
	else
		for(var/mob/M in range(1))
			if(M.s_active == src)
				close(M)
	. = ..()

/obj/item/storage/lockbox/show_to(mob/user)
	if(locked)
		to_chat(user, SPAN_WARNING("It's locked!"))
		return
	. = ..()

/obj/item/storage/lockbox/MouseDrop(over_object, src_location, over_location)
	add_fingerprint(usr)
	if (locked)
		to_chat(usr, SPAN_WARNING("[src] is locked and cannot be opened!"))
		return
	. = ..()

/obj/item/storage/lockbox/emag_act(remaining_charges, mob/user, emag_source, visual_feedback = "", audible_feedback = "")
	if(!broken)
		if(visual_feedback)
			visual_feedback = SPAN_WARNING("[visual_feedback]")
		else
			visual_feedback = SPAN_WARNING("The locker has been sliced open by [user] with an electromagnetic card!")
		if(audible_feedback)
			audible_feedback = SPAN_WARNING("[audible_feedback]")
		else
			audible_feedback = SPAN_WARNING("You hear a faint electrical spark.")
		on_hack_behavior()
		broken = TRUE
		locked = FALSE
		desc = "It appears to be broken."
		icon_state = icon_broken
		visible_message(visual_feedback, audible_feedback)
		return TRUE

/obj/item/storage/lockbox/loyalty
	name = "lockbox of loyalty implants"
	req_access = list(access_security)

/obj/item/storage/lockbox/loyalty/Initialize()
	. = ..()
	new /obj/item/implantcase/loyalty(src)
	new /obj/item/implantcase/loyalty(src)
	new /obj/item/implantcase/loyalty(src)
	new /obj/item/implanter/loyalty(src)


/obj/item/storage/lockbox/clusterbang
	name = "lockbox of clusterbangs"
	desc = "You have a bad feeling about opening this."
	req_access = list(access_security)

/obj/item/storage/lockbox/clusterbang/Initialize()
	. = ..()
	new /obj/item/grenade/flashbang/clusterbang(src)

/obj/item/storage/lockbox/proc/on_hack_behavior()
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, loc)
	spark_system.start()
	playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
	playsound(loc, "spark", 50, 1)
	broken = !broken
	update_icon()
	return

