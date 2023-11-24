/obj/item/gun/whip_of_torment // Yes, it is a gun but a whip. Nuff said.
	name = "Whip of torment"
	desc = "A whip made of bones."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "whip_of_torment"
	item_state = "whip_of_torment"
	fire_sound = null
	fire_sound_text = null
	clumsy_unaffected = TRUE

	var/projectile_type = /obj/item/projectile/whip_of_torment

/obj/item/gun/whip_of_torment/consume_next_projectile(mob/user = usr)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	var/obj/item/projectile/whip_of_torment/P = new projectile_type(src)
	switch(usr.a_intent)
		if(I_GRAB)
			P.grabber = TRUE
		if(I_DISARM)
			P.weaken = 1
		if(I_HURT)
			P.damage = 15
		else
			P.agony = 15
	return(P)

/obj/item/projectile/whip_of_torment
	name = "Whip"
	icon_state = null
	hitscan = TRUE
	impact_on_original = TRUE
	var/list/tracer_list = list()
	muzzle_type = /obj/effect/projectile/muzzle/wizardwhip
	tracer_type = /obj/effect/projectile/tracer/wizardwhip
	impact_type = /obj/effect/projectile/impact/wizardwhip
	kill_count = 1000
	var/grabber = FALSE

/obj/item/projectile/whip_of_torment/on_hit(atom/target, blocked, def_zone)
	if(isturf(target))
		return

	var/atom/movable/T = target
	if(grabber)
		var/grab_chance = 100
		if(iscarbon(T))
			var/mob/living/carbon/C = T
			grab_chance -= C.run_armor_check(def_zone)
			if(def_zone == BP_CHEST || def_zone == BP_GROIN) // It is easier to grab limbs with a whip
				grab_chance -= 20
		if(!T.anchored && prob(grab_chance))
			T.throw_at(firer, get_dist(firer, T) - 1, 1)
	return ..()

/obj/item/projectile/changeling_whip/on_impact(atom/A, use_impact = TRUE)
	if(damage && damage_type == BURN)
		var/turf/T = get_turf(A)
		if(T)
			T.hotspot_expose(700, 5)

/obj/effect/projectile/muzzle/wizardwhip
	icon_state = "muzzle_whip"

/obj/effect/projectile/tracer/wizardwhip
	icon_state = "tracer_whip"

/obj/effect/projectile/impact/wizardwhip
	var/time_to_live = 2
	icon_state = "impact_whip"
