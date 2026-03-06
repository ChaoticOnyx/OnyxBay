/obj/item/mcu_chassis/console
	name = "console"
	desc = "A stationary computer."
	icon = 'icons/obj/mcu.dmi'
	icon_state = "console"
	anchored = TRUE
	density = 1
	atom_flags = ATOM_FLAG_CLIMBABLE
	center_of_mass = null
	randpixel = 0
	max_health = 80
	has_external_power_source = TRUE

/obj/item/mcu_chassis/console/try_drain_power(amount)
	var/area/A = get_area(src)

	if(!istype(A) || !A.powered(STATIC_EQUIP))
		return FALSE

	A.use_power_oneoff(amount, STATIC_EQUIP)

	return TRUE

/obj/item/mcu_chassis/console/attackby(obj/item/W, mob/user)
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

/obj/item/mcu_chassis/console/attack_hand(mob/user)
	if(!user.IsAdvancedToolUser())
		return ..()

	if(QDELETED(__mcu))
		return ..()
	
	if(__mcu.__interact(user))
		return
	
	return ..()

/obj/item/mcu_chassis/console/__on_mcu_on()
	ClearOverlays()

	AddOverlays(OVERLAY(icon, "console-on"))

/obj/item/mcu_chassis/console/__on_mcu_off(is_trap = FALSE)
	ClearOverlays()

	if(is_trap)
		AddOverlays(OVERLAY(icon, "console-bsod"))

/obj/item/mcu_chassis/console/__on_mcu_insert()
	if(__mcu.is_on())
		__on_mcu_on()
	else
		__on_mcu_off(FALSE)

/obj/item/mcu_chassis/console/__on_mcu_eject()
	__on_mcu_off(FALSE)

/obj/item/mcu_chassis/console/turn_on()
	set src in view(1)
	set name = "Turn On"
	set category = "Object"

	if(!usr.IsAdvancedToolUser())
		return
	
	if(!anchored)
		to_chat(usr, SPAN_WARNING("\The [src] should be wrenched first."))
		return

	__mcu?.power_on(usr)
