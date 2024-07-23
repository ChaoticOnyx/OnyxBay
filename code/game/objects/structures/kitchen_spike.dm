//////Kitchen Spike

/obj/structure/kitchenspike
	name = "meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals."
	density = 1
	anchored = 1

	can_buckle = 1
	buckle_lying = 0
	buckle_dir = SOUTH
	var/unbuckling = FALSE


/obj/structure/kitchenspike/attackby(obj/item/I, mob/living/carbon/human/user)
	if (buckled_mob)
		if (is_sharp(I))
			slice(I, user)
		else
			to_chat(user, SPAN_DANGER("You need something sharp to do that!"))
		return
	var/obj/item/grab/G = I

	if (!istype(G) || !G.affecting || !can_spike(G.affecting))
		to_chat(user, SPAN_DANGER("You can't put that on [src]!"))
		return
	if (!G.force_danger())
		to_chat(user, SPAN_DANGER("You need better grip to do it!"))
		return
	if (spike(user, G.affecting))
		qdel(G)

/obj/structure/kitchenspike/Destroy()
	if (buckled_mob)
		buckled_mob.hanging = FALSE
		unbuckle_mob()
	. = ..()

/obj/structure/kitchenspike/proc/can_spike(mob/living/victim)
	return iscarbon(victim) || isanimal(victim)

/obj/structure/kitchenspike/proc/spike(mob/user, mob/living/victim)
	user.visible_message(SPAN_DANGER("[user] starts putting [victim] onto \the [src]..."),
		SPAN("userdanger","[user] starts putting [victim] onto \the [src]..."),
		SPAN("italics", "You hear a squishy wet noise."))
	if(!do_mob(user, src, time = 120))
		return
	if(buckled_mob)
		return
	if(victim.buckled)
		return
	playsound(src.loc, "sound/effects/splat.ogg", 50, 1)
	victim.visible_message(SPAN_DANGER("[user] slams [victim] onto \the [src]!"),
		SPAN("userdanger", "[user] slams [victim] onto \the [src]!"),
		SPAN("italics", "You hear a squishy wet noise."))
	victim.forceMove(src.loc)

	var/mob/living/carbon/C = victim
	if (istype(C) && C.can_feel_pain())
		C.emote("scream")

	var/turf/simulated/pos = get_turf(victim)
	if(istype(victim, /mob/living/carbon/human))
		pos.add_blood(victim)
	else
		pos.add_blood_floor(pos)
	victim.adjustBruteLoss(30)
	victim.hanging = TRUE
	src.buckle_mob(victim)
	return TRUE


/obj/structure/kitchenspike/user_buckle_mob(mob/living/M, mob/living/user)
	return FALSE

/obj/structure/kitchenspike/user_unbuckle_mob(mob/living/user)
	if (!buckled_mob || !buckled_mob.buckled)
		return
	if (unbuckling)
		to_chat(user, SPAN_NOTICE("Someone is already trying to get [buckled_mob == user ? "you" : buckled_mob] off \the [src], you can't help!"))
		return

	var/mob/living/M = buckled_mob
	if(M != user)
		M.visible_message(\
			SPAN_WARNING("[user] tries to pull [M] free of \the [src]!"),\
			SPAN_WARNING("[user] is trying to pull you off \the [src], opening up fresh wounds!"),\
			SPAN("italics", "You hear a squishy wet noise.</span>"))
		unbuckling = TRUE
		if(!do_after(user, delay = 150, target = src, luck_check_type = LUCK_CHECK_COMBAT))
			if(M && M == buckled_mob)
				M.visible_message(\
				SPAN_WARNING("[user] fails to free [M]!"),\
				SPAN_WARNING("[user] fails to pull you off of \the [src]."))
			unbuckling = FALSE
			return
	else
		M.visible_message(\
		SPAN_WARNING("[M] struggles to break free from \the [src]!"),\
		SPAN_WARNING("You struggle to break free from \the [src], exacerbating your wounds!"),\
		SPAN("italics", "You hear a wet squishing noise."))
		M.adjustBruteLoss(30)
		if(!do_after(M, delay = 600, target = src, luck_check_type = LUCK_CHECK_COMBAT))
			if(M && M == buckled_mob)
				to_chat(M, SPAN("warning", "You fail to free yourself!"))
			return

	unbuckling = FALSE
	if(!M || M != buckled_mob)
		return
	M.adjustBruteLoss(30)
	src.visible_message(SPAN_DANGER("[M] falls free of \the [src]!"))
	M.hanging = FALSE
	unbuckle_mob()
	var/mob/living/carbon/C = M
	if (istype(C) && C.can_feel_pain())
		C.emote("scream")
	M.AdjustWeakened(10)

/obj/structure/kitchenspike/proc/slice(obj/item/I, mob/living/user)
	if (!buckled_mob)
		return

	var/mob/living/carbon/human/H = buckled_mob
	if (!istype(H))
		to_chat(user, SPAN_NOTICE("You start to butcher [buckled_mob] with your [I]..."))
		if (!do_after(user, delay = 100, target = buckled_mob, luck_check_type = LUCK_CHECK_COMBAT))
			return
		var/slab_name = buckled_mob.name
		var/slab_count = 3
		var/slab_type = /obj/item/reagent_containers/food/meat
		var/slab_nutrition = 20
		if (iscarbon(buckled_mob))
			var/mob/living/carbon/C = buckled_mob
			slab_nutrition = C.nutrition / 15
			if (istype(buckled_mob, /mob/living/carbon/alien))
				slab_type = /obj/item/reagent_containers/food/meat/xeno

		if (istype(buckled_mob,/mob/living/simple_animal))
			var/mob/living/simple_animal/critter = buckled_mob
			if (critter.meat_amount)
				slab_count = critter.meat_amount
			if (critter.meat_type)
				slab_type = critter.meat_type

		if (issmall(buckled_mob))
			slab_nutrition *= 0.5

		slab_nutrition /= slab_count

		var/reagent_transfer_amt
		if (src.buckled_mob.reagents)
			reagent_transfer_amt = round(buckled_mob.reagents.total_volume / slab_count, 1)

		for (var/i=1 to slab_count)
			var/obj/item/reagent_containers/food/meat/new_meat = new slab_type(src, rand(3,8))
			if (istype(new_meat))
				new_meat.SetName("[slab_name] [new_meat.name]")
				new_meat.reagents.add_reagent(/datum/reagent/nutriment,slab_nutrition)
				if (buckled_mob.reagents)
					buckled_mob.reagents.trans_to_obj(new_meat, reagent_transfer_amt)

		to_chat(user, SPAN_NOTICE("You've finished butchering [buckled_mob]."))
		admin_attack_log(user, buckled_mob, "Gibbed the victim", "Was gibbed", "gibbed")
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		QDEL_NULL(buckled_mob)
		return

	var/zone = check_zone(user.zone_sel?.selecting)
	var/obj/item/organ/external/organ = H.get_organ(zone)
	if (BP_IS_ROBOTIC(organ))
		to_chat(user, SPAN_WARNING("Can't extract meat from robotic limbs!"))
		return
	if (!organ || organ.is_stump())
		to_chat(user, SPAN_WARNING("Can't extract meat from there!"))
		return
	var/obj/item/organ/external/chest/C = organ
	if (istype(C) && C.butchering_capacity <= 0) //workaround for chests not getting stumped/whatever
		to_chat(user, SPAN_WARNING("Can't extract any more meat from there!"))
		return

	var/meat_limbs_left = 0
	for (var/obj/item/organ/external/O in H.organs)
		if (BP_IS_ROBOTIC(O) || O.is_stump())
			continue
		var/obj/item/organ/external/chest/OC = O
		if (istype(OC))
			meat_limbs_left += OC.butchering_capacity
			continue
		meat_limbs_left++

	var/slab_name = H.real_name
	var/slab_type = H.species.meat_type
	var/slab_nutrition = H.nutrition / meat_limbs_left
	var/nutrition_transfer_mod = 0.33
	if (issmall(H))
		nutrition_transfer_mod *= 0.5

	var/butchered_organ_name = "[organ.name]";
	user.visible_message(SPAN_WARNING("[user] tries to butcher [H]'s [butchered_organ_name]!"),\
		SPAN_NOTICE("You try to butcher [H]'s [butchered_organ_name]..."),\
		SPAN("italics", "You hear a wet squishing noise.</span>"))

	if (do_after(user, delay = 20, target = H, luck_check_type = LUCK_CHECK_COMBAT))
		if (istype(C))
			if (C.butchering_capacity <= 0)
				return
			H.apply_damage(damage = 60, damagetype = BRUTE, def_zone = zone, damage_flags = DAM_SHARP, used_weapon = I)
			C.butchering_capacity--
		else
			organ.droplimb(clean = FALSE, silent = TRUE, disintegrate = DROPLIMB_BLUNT) //blunt so it gets turned into gore
		user.visible_message(SPAN_WARNING("[user]'ve successfully butchered [H]'s [butchered_organ_name]!"),\
			SPAN_NOTICE("You've successfully butchered [H]'s [butchered_organ_name]..."),\
			SPAN("italics", "You hear a squishy wet noise.</span>"))
		if (H.can_feel_pain())
			H.emote("scream")
		H.remove_nutrition(slab_nutrition)
		var/obj/item/reagent_containers/food/meat/new_meat = new slab_type(get_turf(src), rand(3,8))
		if (istype(new_meat))
			new_meat.SetName("[slab_name] [new_meat.name]")
			new_meat.reagents.add_reagent(/datum/reagent/nutriment,slab_nutrition * nutrition_transfer_mod)
			if (H.reagents)
				H.reagents.trans_to_obj(new_meat, round(buckled_mob.reagents.total_volume / meat_limbs_left, 1))
	return
