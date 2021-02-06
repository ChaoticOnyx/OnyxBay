/obj/effect/vine/HasProximity(atom/movable/AM)
	if(!is_mature() || seed.get_trait(TRAIT_SPREAD) != 2)
		return

	var/mob/living/M = AM
	if(!istype(M))
		return

	if(!is_valid_target(M))
		return

	if(issmall(M) || prob(round(seed.get_trait(TRAIT_POTENCY) / 6)))
		//wait a tick for the Entered() proc that called HasProximity() to finish (and thus the moving animation),
		//so we don't appear to teleport from two tiles away when moving into a turf adjacent to vines.
		spawn(1)
			if(prob(seed.get_trait(((TRAIT_POTENCY) / 2) * 3)))
				entangle(M)

/obj/effect/vine/attack_hand(mob/user)
	manual_unbuckle(user)

/obj/effect/vine/attack_generic(mob/user)
	if(istype(user))
		manual_unbuckle(user)

/obj/effect/vine/Crossed(atom/movable/O)
	if(isliving(O))
		trodden_on(O)

/obj/effect/vine/proc/trodden_on(mob/living/victim)
	if(!is_valid_target(victim)) // Aight man ye good
		return
	wake_neighbors()
	if(!is_mature())
		return
	if(prob(seed.get_trait(((TRAIT_POTENCY) / 2) * 3)))
		entangle(victim)
	var/mob/living/carbon/human/H = victim
	if(istype(H) && H.shoes)
		return
	seed.do_thorns(victim, src)
	seed.do_sting(victim, src, pick(BP_R_FOOT, BP_L_FOOT, BP_R_LEG, BP_L_LEG))

/obj/effect/vine/proc/manual_unbuckle(mob/user)
	if(!buckled_mob)
		return

	if(buckled_mob != user)
		to_chat(user, SPAN("notice", "You try to free \the [buckled_mob] from \the [src]."))
		var/chance = round(100 / (20 * seed.get_trait(TRAIT_POTENCY) / 100))
		if(prob(chance))
			buckled_mob.visible_message(\
				SPAN("notice", "\The [user] frees \the [buckled_mob] from \the [src]."),\
				SPAN("notice", "\The [user] frees you from \the [src]."),\
				SPAN("warning", "You hear shredding and ripping."))
			unbuckle_mob()
	else
		user.setClickCooldown(100)
		var/breakouttime = rand(600, 1200) //1 to 2 minutes.

		user.visible_message(
			SPAN("danger", "\The [user] attempts to get free from [src]!"),
			SPAN("warning", "You attempt to get free from [src]."))

		if(do_after(user, breakouttime, incapacitation_flags = INCAPACITATION_DEFAULT & ~INCAPACITATION_RESTRAINED))
			if(unbuckle_mob())
				user.visible_message(
					SPAN("danger", "\The [user] manages to escape [src]!"),
					SPAN("warning", "You successfully escape [src]!"))

/obj/effect/vine/proc/entangle(mob/living/victim)
	if(buckled_mob)
		return

	if(victim.anchored)
		return

	if(!Adjacent(victim))
		return

	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		if(H.species.species_flags & SPECIES_FLAG_NO_TANGLE)
			return
		if(victim.loc != loc && istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.item_flags & ITEM_FLAG_NOSLIP))
			visible_message(SPAN("danger", "Tendrils lash to drag \the [victim] but \the [src] can't pull them across the ground!"))
			return

	victim.visible_message(
		SPAN("danger", "Tendrils lash out from \the [src] and drag \the [victim] in!"),
		SPAN("danger", "Tendrils lash out from \the [src] and drag you in!"))

	victim.forceMove(loc)
	if(buckle_mob(victim))
		victim.set_dir(pick(GLOB.cardinal))
		to_chat(victim, SPAN("danger", "The tendrils [pick("wind", "tangle", "tighten", "coil", "knot", "snag", "twist", "constrict", "squeeze", "clench", "tense")] around you!"))

/obj/effect/vine/buckle_mob()
	. = ..()
	if(.)
		START_PROCESSING(SSvines, src)

/obj/effect/vine/proc/is_valid_target(mob/living/M)
	if(!M)
		return 0
	if(M.faction == "floral")
		return 0
	return 1
