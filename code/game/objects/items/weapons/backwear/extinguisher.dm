
/obj/item/weapon/backwear/reagent/extinguisher
	name = "firefighting kit"
	desc = "An unwieldy, heavy backpack with two massive foam tanks and a retractable fire hose. Includes a connector for most models of fire extinguishers."
	icon_state = "foam0"
	base_icon = "foam"
	item_state = "backwear_extinguisher"
	hitsound = 'sound/effects/fighting/smash.ogg'
	gear_detachable = FALSE
	gear = /obj/item/weapon/extinguisher/linked
	atom_flags = null
	initial_capacity = 5000
	initial_reagent_types = list(/datum/reagent/water/firefoam = 1)
	origin_tech = list(TECH_ENGINEERING = 2)
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_GLASS = 500)

/obj/item/weapon/backwear/reagent/extinguisher/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O, /obj/structure/reagent_dispensers/watertank))
		var/amount = min((initial_capacity - reagents.total_volume), O.reagents.total_volume)
		if(!O.reagents.total_volume)
			to_chat(user, SPAN("warning", "\The [O] is empty."))
			return
		if(!amount)
			to_chat(user, SPAN("notice", "\The [src] is already full."))
			return
		O.reagents.remove_any(amount)
		reagents.add_reagent(/datum/reagent/water/firefoam, amount)
		to_chat(user, SPAN("notice", "You crack the cap off the top of your [src] and fill it with [amount] units of the contents of \the [O]."))
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
		return


/obj/item/weapon/extinguisher/linked
	name = "fire hose"
	desc = "Fire extinguisher's elder brother. Connected to a firefighting kit, it turns a mere spaceman into an entire fire brigade."
	icon = 'icons/obj/backwear.dmi'
	icon_state = "firehose"
	item_state = "firehose"
	hitsound = "swing_hit"
	force = 6.5
	mod_handy = 0.7
	mod_weight = 0.65
	mod_reach = 0.6
	w_class = ITEM_SIZE_NORMAL
	spray_amount = 120
	max_volume = 0
	safety = 0
	external_source = TRUE
	slot_flags = null
	attack_verb = list("whacked", "smacked", "attacked")
	canremove = 0
	matter = null
	var/obj/item/weapon/backwear/reagent/base_unit

/obj/item/weapon/extinguisher/linked/New(newloc, obj/item/weapon/backwear/base)
	base_unit = base
	..(newloc)

/obj/item/weapon/extinguisher/linked/Destroy() //it shouldn't happen unless the base unit is destroyed but still
	if(base_unit)
		if(base_unit.gear == src)
			base_unit.gear = null
			base_unit.update_icon()
		base_unit = null
	return ..()

/obj/item/weapon/extinguisher/linked/dropped(mob/user)
	..()
	if(base_unit)
		base_unit.reattach_gear(user)

/obj/item/weapon/extinguisher/linked/attack(mob/living/M, mob/user)
	if(user.a_intent == I_HELP)
		if(!base_unit)
			return
		if(world.time < last_use + 20) // We still catch help intent to not randomly attack people
			return
		if(!base_unit.reagents.total_volume)
			to_chat(user, SPAN("notice", "\The [base_unit] is empty."))
			return
		last_use = world.time
		base_unit.reagents.splash(M, min(base_unit.reagents.total_volume, spray_amount))
		user.visible_message(SPAN("notice", "\The [user] sprays \the [M] with \the [src]."))
		playsound(src.loc, 'sound/effects/extinguish.ogg', 75, 1, -3)
		return 1
	return ..()

/obj/item/weapon/extinguisher/linked/afterattack(atom/target, mob/user, flag)
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
