//Bloodchiller - Chilling Green
/obj/item/gun/projectile/magic/bloodchill
	name = "blood chiller"
	desc = "A horrifying weapon made of your own bone and blood vessels. It shoots slowing globules of your own blood. Ech."
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "bloodgun"
	w_class = ITEM_SIZE_LARGE
	slot_flags = null
	force = 5
	fire_delay = 1
	ammo_type = /obj/item/ammo_casing/magic/bloodchill
	fire_sound = 'sound/effects/attackblob.ogg'
	handle_casings = CLEAR_CASINGS
	var/charge_timer = 0
	var/charges = 0
	var/max_charges = 1
	canremove = FALSE
	has_safety = FALSE

/obj/item/gun/projectile/magic/bloodchill/think()
	charge_timer += 0.1
	if(charge_timer < fire_delay || charges >= max_charges)
		set_next_think(world.time+0.1)
		return FALSE
	charge_timer = 0
	var/mob/living/carbon/human/M = loc
	if(istype(M) && M.get_blood_volume_abs() >= 20)
		charges++
		M.remove_blood(20)
	if(charges == 1)
		loaded += new ammo_type(src)
		consume_next_projectile()
		charges--
		set_next_think(world.time+0.1)
	return TRUE

/obj/item/ammo_casing/magic/bloodchill
	projectile_type = /obj/item/projectile/magic/bloodchill

/obj/item/projectile/magic/bloodchill
	name = "blood ball"
	icon_state = "pulse0_bl"
	hitsound = 'sound/effects/splat.ogg'
	blockable = FALSE
	damage = 0

/obj/item/projectile/magic/bloodchill/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		ADD_TRAIT(target, /datum/modifier/status_effect/bloodchill)
