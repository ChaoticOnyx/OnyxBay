/obj/item/gun/whip_of_torment // Yes, it is a gun but a whip. Nuff said.
	name = "Whip of torment"
	desc = "" //TODO THINK THINK
	icon = 'icons/obj/wizard.dmi'
	icon_state = "whip_of_torment"
	item_state = "whip_of_torment"

	var/projectile_type = /obj/item/projectile/whip_of_torment

/obj/item/gun/whip_of_torment/consume_next_projectile()
	var/obj/item/projectile/whip_of_torment/P = new projectile_type(src)
	return(P)

/obj/item/projectile/whip_of_torment
	name = "Whip"
	icon_state = null
	hitscan = TRUE

	var/list/tracer_list = list()
	muzzle_type = /obj/effect/projectile/muzzle/wizardwhip
	tracer_type = /obj/effect/projectile/tracer/wizardwhip
	impact_type = /obj/effect/projectile/impact/wizardwhip

/obj/item/projectile/changeling_whip/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(isturf(target))
		return

	var/atom/movable/T = target
	return ..()

/obj/effect/projectile/muzzle/wizardwhip
	icon_state = "muzzle_whip"

/obj/effect/projectile/tracer/wizardwhip
	icon_state = "tracer_whip"

/obj/effect/projectile/impact/wizardwhip
	var/time_to_live = 2
	icon_state = "impact_whip"
