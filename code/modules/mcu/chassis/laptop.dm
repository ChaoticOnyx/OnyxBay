/obj/item/mcu_chassis/laptop
	name = "laptop computer"
	desc = "A portable computer."
	icon = 'icons/obj/mcu.dmi'
	icon_state = "laptop-closed"
	w_class = ITEM_SIZE_NORMAL
	matter = list(MATERIAL_STEEL = 300, MATERIAL_GLASS = 150)
	origin_tech = list(TECH_ENGINEERING = 1)
	max_health = 30
	cooling_bonus = 0.4

/obj/item/mcu_chassis/laptop/AltClick(mob/user)
	if(!istype(loc, /turf))
		to_chat(user, "\The [src] has to be on a stable surface first!")
		return

	anchored = !anchored

	if(anchored)
		icon_state = "laptop-open"
	else
		icon_state = "laptop-closed"

		if(!QDELETED(__mcu))
			__mcu.power_off(user)

/obj/item/mcu_chassis/laptop/attack_self(mob/user)
	if(!anchored)
		return

	return ..()

/obj/item/mcu_chassis/laptop/__on_mcu_on()
	ClearOverlays()

	AddOverlays(OVERLAY(icon, "laptop-on"))

/obj/item/mcu_chassis/laptop/__on_mcu_off(is_trap = FALSE)
	ClearOverlays()

	if(is_trap)
		AddOverlays(OVERLAY(icon, "laptop-bsod"))

/obj/item/mcu_chassis/laptop/__on_mcu_insert()
	if(__mcu.is_on())
		__on_mcu_on()
	else
		__on_mcu_off(FALSE)

/obj/item/mcu_chassis/laptop/__on_mcu_eject()
	__on_mcu_off(FALSE)

/obj/item/mcu_chassis/laptop/turn_on()
	set src in view(1)
	set name = "Turn On"
	set category = "Object"

	if(!usr.IsAdvancedToolUser())
		return
	
	if(!anchored)
		to_chat(usr, SPAN_WARNING("\The [src] should be opened first."))
		return

	__mcu?.power_on(usr)
