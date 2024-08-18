/obj/item/device/chameleonholo
	name = "chameleon hologram"
	icon_state = "chamholo"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	item_state = "electronic"
	throwforce = 5.0
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_ILLEGAL = 4, TECH_MAGNET = 4)
	var/active = FALSE
	var/saved_appearance
	var/saved_dir
	var/saved_density
	var/saved_examine_result
	var/static/list/blacklist = list(/obj/item/holder, /obj/item/grab)

/obj/item/device/chameleonholo/dropped()
	activate()
	..()

/obj/item/device/chameleonholo/pickup(mob/user)
	deactivate(user)
	..()

/obj/item/device/chameleonholo/equipped()
	deactivate()
	..()

/obj/item/device/chameleonholo/attack_self_tk(mob/user)
	if(active)
		deactivate()
		return

/obj/item/device/chameleonholo/examine(mob/user, infix)
	if(!active)
		return ..()
	return saved_examine_result

/obj/item/device/chameleonholo/attack_self(mob/user)
	if(!saved_appearance)
		to_chat(user, SPAN("notice", "\The [src]'s memory buffer is empty."))
		return
	to_chat(user, SPAN("notice", "You clear \the [src]'s memory buffer."))
	saved_appearance = null

/obj/item/device/chameleonholo/proc/check_blacklist(atom/target)
	for(var/type in blacklist)
		if (istype(target, type))
			return TRUE

/obj/item/device/chameleonholo/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(!istype(target,/obj))
		to_chat(user, SPAN("warning", "\The [src] can't scan \the [target]."))
		return
	if(check_blacklist(target))
		to_chat(user, SPAN("warning", "\The [src] is unable to scan \the [target]!"))
		return
	var/obj/object = target
	playsound(src, 'sound/weapons/flash.ogg', 100, 1, -6)
	to_chat(user, SPAN("notice", "Scanned \the [target]."))
	saved_appearance = object.appearance
	saved_dir = object.dir
	saved_density = object.density
	saved_examine_result = object.examine(user)

/obj/item/device/chameleonholo/proc/activate(obj/saved_item)
	if(active || !saved_appearance)
		return
	playsound(src, 'sound/effects/pop.ogg', 100, 1, -6)
	appearance = saved_appearance
	dir = saved_dir
	density = saved_density
	alpha = max(0, alpha - 50)
	active = TRUE

/obj/item/device/chameleonholo/proc/deactivate(mob/user)
	if(!active)
		return
	playsound(src, 'sound/effects/pop.ogg', 100, 1, -6)
	appearance = initial(appearance)
	dir = initial(dir)
	density = initial(density)
	active = FALSE

// Chameleon bomb, gentlemen
/obj/item/device/chameleonholo/bomb
	name = "chameleon bomb"
	description_antag = "A powerful bomb with an integrated chameleon hologram projector. Be careful, once you arm and activate it, any touch will trigger an explosion!"
	icon_state = "chambomb"
	item_state = "electronic"
	throwforce = 5.0
	throw_speed = 1
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_ILLEGAL = 5, TECH_MAGNET = 4)
	var/bomb_armed = FALSE

/obj/item/device/chameleonholo/bomb/attack_self(mob/user)
	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	bomb_armed = !bomb_armed
	if(!bomb_armed)
		to_chat(user, SPAN("notice", "You disarm \the [src]."))
	else
		to_chat(user, SPAN("warning", "You arm \the [src]!"))

/obj/item/device/chameleonholo/bomb/activate(obj/saved_item)
	if(!bomb_armed)
		return
	..()

/obj/item/device/chameleonholo/bomb/deactivate(mob/user)
	if(!bomb_armed || !active)
		return
	bomb_armed = FALSE
	visible_message(SPAN("warning", "*CLICK*"))
	to_chat(user, SPAN("danger", "<b>Fuck.</b>"))
	playsound(src, 'sound/effects/snap.ogg', 100, 1, -6)
	appearance = initial(appearance)
	dir = initial(dir)
	density = initial(density)
	spawn(10)
		if(src)
			explosion(get_turf(src), 1, 2, 3, 4)
			qdel(src)
