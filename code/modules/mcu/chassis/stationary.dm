/obj/item/mcu_chassis/stationary
	anchored = TRUE
	density = 1
	atom_flags = ATOM_FLAG_CLIMBABLE
	center_of_mass = null
	randpixel = 0
	has_external_power_source = TRUE

/obj/item/mcu_chassis/stationary/try_drain_power(amount)
	var/area/A = get_area(src)

	if(!istype(A) || !A.powered(STATIC_EQUIP))
		return FALSE

	A.use_power_oneoff(amount, STATIC_EQUIP)

	return TRUE

/obj/item/mcu_chassis/stationary/attackby(obj/item/W, mob/user)
	if(!user.IsAdvancedToolUser())
		return ..()

	if(isWrench(W))
		if(!do_after(user, 1 SECOND, src, TRUE))
			return

		anchored = !anchored
		playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)

		if(anchored)
			user.visible_message("[user] wrenches \the [src]", "You wrench \the [src]")
		else
			user.visible_message("[user] unwrenches \the [src]", "You unwrench \the [src]")

		__mcu?.power_off()

		return

	return ..()

/obj/item/mcu_chassis/stationary/attack_hand(mob/user)
	if(!user.IsAdvancedToolUser())
		return ..()

	if(QDELETED(__mcu))
		return ..()
	
	if(__mcu.__interact(user))
		return
	
	return ..()

/obj/item/mcu_chassis/stationary/__on_mcu_insert()
	if(__mcu.is_on())
		__on_mcu_on()
	else
		__on_mcu_off(FALSE)

/obj/item/mcu_chassis/stationary/__on_mcu_eject()
	__on_mcu_off(FALSE)

/obj/item/mcu_chassis/stationary/turn_on()
	set src in view(1)
	set name = "Turn On"
	set category = "Object"

	if(!usr.IsAdvancedToolUser())
		return
	
	if(!anchored)
		to_chat(usr, SPAN_WARNING("\The [src] should be wrenched first."))
		return

	__mcu?.power_on(usr)
