
/obj/item/gun/projectile/grenade_launcher
	name = "grenade launcher"
	desc = "Widely known as a Bloop Tube, it's ancient, but still compact, reliable and, more importantly, unremarkably stylish."
	icon_state = "blooptube"
	item_state = "blooptube"

	w_class = ITEM_SIZE_NORMAL
	force = 9.5
	mod_weight = 0.9
	mod_reach = 0.8
	mod_handy = 0.9
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT

	caliber = "40mm"
	handle_casings = HOLD_CASINGS
	load_method = SINGLE_CASING
	max_shells = 1
	ammo_type = /obj/item/ammo_casing/grenade
	fire_sound = 'sound/effects/weapons/misc/bloop.ogg'
	has_safety = FALSE
	starts_loaded = FALSE

/obj/item/gun/projectile/grenade_launcher/unload_ammo(atom/movable/unloader, allow_dump = TRUE, dump_loc = null)
	if(loaded.len)
		var/obj/item/ammo_casing/C = loaded[loaded.len]
		loaded.len--
		if(ismob(unloader))
			var/mob/user = unloader
			if(user.has_in_passive_hand(src))
				user.pick_or_drop(C)
			else
				C.forceMove(get_turf(unloader))
		else if(Adjacent(src, unloader))
			C.forceMove(get_turf(unloader))

		unloader.visible_message("<b>[unloader]</b> removes \a [C] from [src].", SPAN("notice", "You remove \a [C] from [src]."))
		playsound(src.loc, "bullet_insert", 50, 1)
	else
		to_chat(unloader, SPAN("warning", "[src] is empty."))

	update_icon()
