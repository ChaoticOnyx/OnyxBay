
/obj/item/weapon/backwear/reagent/pepper
	name = "crowdbuster kit"
	desc = "A heavy backpack made of two pepper tanks and a retractable pepperspray nozzle, manufactured by Uhang Inc. Your best choice for killing them asthmatics!"
	icon_state = "pepper1"
	base_icon = "pepper"
	item_state = "backwear_pepper"
	hitsound = 'sound/effects/fighting/smash.ogg'
	gear_detachable = FALSE
	gear = /obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster
	atom_flags = null
	initial_capacity = 300
	initial_reagent_types = list(/datum/reagent/capsaicin/condensed = 1)
	origin_tech = list(TECH_ENGINEERING = 2)
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_GLASS = 500)

/obj/item/weapon/backwear/reagent/pepper/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O, /obj/structure/reagent_dispensers/peppertank))
		var/amount = min((initial_capacity - reagents.total_volume), O.reagents.total_volume)
		if(!O.reagents.total_volume)
			to_chat(user, SPAN("warning", "\The [O] is empty."))
			return
		if(!amount)
			to_chat(user, SPAN("notice", "\The [src] is already full."))
			return
		O.reagents.trans_to_obj(src, amount)
		to_chat(user, SPAN("notice", "You crack the cap off the top of your [src] and fill it with [amount] units of the contents of \the [O]."))
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
		return

/obj/item/weapon/backwear/reagent/pepper/resolve_grab_gear(mob/living/carbon/human/user)
	. = ..()
	if(. && gear)
		var/obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster/C = gear
		C.external_container = src // Sadly it's safer and easier to do it this way since New/Initialize sequences are a shitmaze

/obj/item/weapon/backwear/reagent/standard_dispenser_refill(mob/user, obj/structure/reagent_dispensers/target)
	return 0

/obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster
	name = "crowdbuster"
	desc = "It fires a large cloud of condensed capsaicin to blind and down an opponent quickly."
	icon = 'icons/obj/backwear.dmi'
	icon_state = "crowdbuster0"
	item_state = "crowdbuster"
	possible_transfer_amounts = null
	volume = 0
	amount_per_transfer_from_this = 10
	step_delay = 1
	atom_flags = null
	slot_flags = null
	canremove = 0
	unacidable = 1 //TODO: make these replaceable so we won't need such ducttaping
	matter = null
	var/obj/item/weapon/backwear/reagent/base_unit

/obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster/New(newloc, obj/item/weapon/backwear/base)
	base_unit = base
	src.verbs -= /obj/item/weapon/reagent_containers/spray/verb/empty
	..(newloc)

/obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster/Destroy() //it shouldn't happen unless the base unit is destroyed but still
	if(base_unit)
		if(base_unit.gear == src)
			base_unit.gear = null
			base_unit.update_icon()
		base_unit = null
	return ..()

/obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster/dropped(mob/user)
	..()
	if(base_unit)
		base_unit.reattach_gear(user)

/obj/item/weapon/reagent_containers/spray/chemsprayer/crowdbuster/attack_self(mob/user)
	widespray = !widespray
	if(widespray)
		to_chat(user, "\The [src]'s nozzle is now set to wide spraying mode.")
		icon_state = "crowdbuster1"
	else
		to_chat(user, "\The [src]'s nozzle is now set to narrow spraying mode.")
		icon_state = "crowdbuster0"

/*
/obj/item/weapon/reagent_containers/spray/pepper/linked/Spray_at(atom/A, mob/user)
	if(A.density && proximity)
		A.visible_message("[usr] sprays [A] with [src].")
		reagents.splash(A, amount_per_transfer_from_this)
		return
	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T, T1, T2)

	for(var/a = 1 to 3)
		spawn(0)
			if(reagents.total_volume < 1) break
			var/obj/effect/effect/water/chempuff/D = new /obj/effect/effect/water/chempuff(get_turf(src))
			var/turf/my_target = the_targets[a]
			D.create_reagents(amount_per_transfer_from_this)
			if(!src)
				return
			reagents.trans_to_obj(D, amount_per_transfer_from_this)
			D.set_color()
			D.set_up(my_target, rand(6, 8), 2)
	return

/obj/item/weapon/reagent_containers/spray/pepper/linked/attack(mob/living/M, mob/user)
	if(user.a_intent == I_HELP)
		if(!base_unit)
			return
		if(world.time < last_use + 20) // We still catch help intent to not randomly attack people
			return
		if(!base_unit.reagents.total_volume)
			to_chat(user, SPAN("notice", "\The [base_unit] is empty."))
			return
		last_use = world.time
		base_unit.reagents.splash(M, min(reagents.total_volume, spray_amount))
		user.visible_message(SPAN("notice", "\The [user] sprays \the [M] with \the [src]."))
		playsound(src.loc, 'sound/effects/extinguish.ogg', 75, 1, -3)
		return 1
	return ..()

/obj/item/weapon/reagent_containers/spray/pepper/linked/afterattack(atom/target, mob/user, flag)
	if(!base_unit)
		return
	if(target == base_unit)
		return
	if(!base_unit.reagents.total_volume)
		to_chat(usr, SPAN("notice", "\The [src] is empty."))
		return
	if(world.time < last_use + 20)
		return
	last_use = world.time
	playsound(src.loc, 'sound/effects/extinguish.ogg', 75, 1, -3)
	if(istype(target, /obj/item/clothing/mask/smokable))
		var/obj/item/clothing/mask/smokable/cig = target
		cig.die()

	var/direction = get_dir(src,target)
	if(user.buckled && isobj(user.buckled))
		spawn(0)
			propel_object(user.buckled, user, turn(direction,180))

	var/turf/T = get_turf(target)
	var/per_particle = min(spray_amount, base_unit.reagents.total_volume)/spray_particles
	for(var/a = 1 to spray_particles)
		spawn(0)
			if(!src || !base_unit.reagents.total_volume)
				return
			var/obj/effect/effect/water/W = new /obj/effect/effect/water(get_turf(src))
			W.create_reagents(per_particle)
			base_unit.reagents.trans_to_obj(W, per_particle)
			W.set_color()
			W.set_up(T)

	if((istype(usr.loc, /turf/space)) || (usr.lastarea.has_gravity == 0))
		user.inertia_dir = get_dir(target, user)
		step(user, user.inertia_dir)
	return ..()
*/
