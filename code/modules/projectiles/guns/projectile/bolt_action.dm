/obj/item/gun/projectile/bolt_action
	name = "bolt action rifle"
	desc = "A bolt action rifle. Fires 7.92mm shells"
	base_icon_state = "gewehr"
	icon_state = "gewehr"
	item_state = "gewehr"
	wielded_item_state = "gewehr-wielded"
	w_class = ITEM_SIZE_HUGE
	force = 15
	mod_weight = 1.6
	mod_reach = 1.25
	mod_handy = 1.0
	slot_flags = SLOT_BACK
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	caliber = "7.92"
	handle_casings = HOLD_CASINGS
	load_method = SINGLE_CASING | SPEEDLOADER
	max_shells = 5
	ammo_type = /obj/item/ammo_casing/a792
	one_hand_penalty = 6
	var/bolt_open = FALSE
	fire_sound = SFX_792_FIRE

/obj/item/gun/projectile/bolt_action/on_update_icon()
	..()

	if(bolt_open)
		icon_state = "[base_icon_state]-open"
	else
		icon_state = base_icon_state

/obj/item/gun/projectile/bolt_action/attack_self(mob/user)
	bolt_open = !bolt_open

	if(bolt_open)
		if(chambered)
			ejectCasing()
			loaded -= chambered
			chambered = null
		playsound(get_turf(src), SFX_792_BOLT_BACK, 50, 1)
	else
		playsound(get_turf(src), SFX_792_BOLT_FORWARD, 50, 1)
		bolt_open = FALSE

	add_fingerprint(user)
	update_icon()

/obj/item/gun/projectile/bolt_action/special_check(mob/user)
	if(bolt_open)
		to_chat(user, SPAN_WARNING("You can't fire [src] while the bolt is open!"))
		return FALSE

	return ..()

/obj/item/gun/projectile/bolt_action/load_ammo(obj/item/A, mob/user)
	if(!bolt_open)
		return

	return ..()

/obj/item/gun/projectile/bolt_action/unload_ammo(mob/user, allow_dump=1)
	if(!bolt_open)
		return

	return ..()

/obj/item/gun/projectile/bolt_action/mauser
	base_icon_state = "mauser"
	icon_state = "mauser"
	item_state = "mauser"
	wielded_item_state = "mauser-wielded"
