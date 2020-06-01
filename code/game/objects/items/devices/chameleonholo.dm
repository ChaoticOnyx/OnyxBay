/obj/item/device/chameleonholo
	name = "chameleon hologram"
	icon_state = "shield0"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	item_state = "electronic"
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_ILLEGAL = 4, TECH_MAGNET = 4)
	var/active = 0
	var/default_appearance
	var/saved_item
	var/saved_overlays

/obj/item/device/chameleonholo/New()
	default_appearance = appearance

/obj/item/device/chameleonholo/dropped()
	activate(saved_item)
	..()

/obj/item/device/chameleonholo/pickup()
	deactivate()
	..()

/obj/item/device/chameleonholo/equipped()
	deactivate()
	..()

/obj/item/device/chameleonholo/attack_self(mob/user as mob)
	if (active)
		return
	if (!saved_item)
		to_chat(user, SPAN("notice","\The [src]'s memory buffer is empty."))
		return
	to_chat(user, SPAN("notice","You clear \the [src]'s memory buffer."))
	saved_item = null
	saved_overlays = null

/obj/item/device/chameleonholo/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(!istype(target,/obj))
		to_chat(user, SPAN("warning","\The [src] can't scan \the [target]."))
		return
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1, -6)
	to_chat(user, SPAN("notice","Scanned \the [target]."))
	saved_item = target
	saved_overlays = target.overlays

/obj/item/device/chameleonholo/proc/activate(obj/saved_item)
	if(!saved_item || active)
		return
	playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
	appearance = saved_item.appearance
	dir = saved_item.dir
	overlays = saved_overlays
	alpha -= 15
	active = 1

/obj/item/device/chameleonholo/proc/deactivate()
	if (!saved_item || !active)
		return
	playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
	appearance = default_appearance
	overlays = null
	active = 0
