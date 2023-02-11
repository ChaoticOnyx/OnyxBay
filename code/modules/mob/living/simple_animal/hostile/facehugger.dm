
/mob/living/simple_animal/hostile/facehugger
	name = "alien"
	desc = "A viscious little creature, it looks like a connected pair of hands and has a long, muscular tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	icon_living = "facehugger"
	item_state = "facehugger"
	icon_dead = "facehugger_dead"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stamps on"
	density = 0
	see_in_dark = 6
	destroy_surroundings = 0
	turns_per_move = 2
	health = 15
	maxHealth = 15
	harm_intent_damage = 7.5
	speed = 4
	move_to_delay = 4
	min_gas = null
	mob_size = MOB_MINISCULE
	can_escape = 1
	pass_flags = PASS_FLAG_TABLE
	melee_damage_lower = 2.5
	melee_damage_upper = 5
	meat_type = /obj/item/reagent_containers/food/meat/xeno

	min_gas = null
	max_gas = null
	minbodytemp = 0

	ranged = 1
	pointblank_shooter = 1
	projectiletype = /obj/item/projectile/facehugger_proj
	ranged_message = "leaps"
	ranged_cooldown_cap = 2
	retreat_distance = 3 // Run away and try to leap again
	minimum_distance = 4
	holder_type = /obj/item/holder/facehugger
	faction = "xenomorph"

	var/is_sterile = FALSE

/mob/living/simple_animal/hostile/facehugger/ListTargets(dist = 7)
	var/list/L = list()
	for(var/a in hearers(src, dist))
		if(istype(a, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = a
			if(H.faction == faction) // No need to attack our fellow queens of blades
				continue
			var/obj/item/organ/internal/alien_embryo/AE = H.internal_organs_by_name[BP_EMBRYO]
			if(AE && !(AE.status & ORGAN_DEAD))
				continue // No need to leap onto infected faces
			var/obj/item/organ/internal/xenos/hivenode/HN = H.internal_organs_by_name[BP_HIVE]
			if(HN)
				continue // Don't facefuck our fellow xenohumans
			var/obj/item/mask = H.get_equipped_item(slot_wear_mask)
			if(istype(mask, /obj/item/holder/facehugger)) // No need to interrupt our allies
				var/obj/item/holder/facehugger/F = mask
				if(F.held_mob.stat) // ...unless they are dead
					continue
			L += a
	return L

/mob/living/simple_animal/hostile/facehugger/death(gibbed, deathmessage, show_dead_message)
	. = ..(deathmessage = "limps!")
	if(.)
		if(is_sterile)
			icon_state = "facehugger_impregnated"

/mob/living/simple_animal/hostile/facehugger/get_scooped(mob/living/carbon/grabber, self_grab)
	if(grabber.faction != "xenomorph" && !is_sterile && !stat)
		to_chat(grabber, SPAN("warning", "\The [src] wriggles out of your hands before you can pick it up!"))
		return
	else
		return ..()

/mob/living/simple_animal/hostile/facehugger/proc/facefuck(mob/living/carbon/human/H, silent = FALSE, forced = FALSE) // Returns FALSE if the facehugger can't latch on one's face, TRUE if it latches
	if(stat)
		return

	if(!is_mob_suitable_to_facefuck(H))
		return FALSE

	if(!try_to_strip_down_human_head(H, forced))
		return FALSE

	var/obj/item/holder/facehugger/holder = new(get_turf(src), src)
	forceMove(holder)
	holder.sync(src)
	holder.forced_equip = forced

	if(H.equip_to_slot_if_possible(holder, slot_wear_mask, FALSE, TRUE)) // So we won't simply get deleted upon trying to latch at a mob w/ no mask slot (i.e. diona)
		if(!silent)
			H.visible_message(SPAN("warning", "\The [src] latches itself onto [H]'s face!"))
	else
		holder.forceMove(H.loc)

	return TRUE


/mob/living/simple_animal/hostile/facehugger/proc/is_mob_suitable_to_facefuck(mob/living/carbon/human/H)
	return istype(H) && H.organs_by_name["chest"] && H.organs_by_name["head"]


/mob/living/simple_animal/hostile/facehugger/proc/try_to_strip_down_human_head(mob/living/carbon/human/H, forced = FALSE)
	var/obj/item/helmet = H.get_equipped_item(slot_head)
	if(helmet && (((helmet.item_flags & ITEM_FLAG_AIRTIGHT) && !forced) || !helmet.knocked_out(H, dist = 0)))
		H.visible_message(SPAN("notice", "\The [src] [pick("smacks", "smashes", "blops", "bonks")] against [H]'s [helmet] harmlessly!"))
		return FALSE

	var/obj/item/mask = H.get_equipped_item(slot_wear_mask)
	if(mask && !mask.knocked_out(H, dist = 0))
		H.visible_message(SPAN("warning", "\The [src] tries to rip [H]'s [mask] off, but fails."))
		return FALSE

	var/obj/item/l_ear = H.get_equipped_item(slot_l_ear)
	l_ear?.knocked_out(H, dist = 0)
	var/obj/item/r_ear = H.get_equipped_item(slot_r_ear)
	r_ear?.knocked_out(H, dist = 0)

	return TRUE

/mob/living/simple_animal/hostile/facehugger/proc/impregnate(mob/living/carbon/human/H)
	var/obj/item/holder/facehugger/holder = loc
	if(!istype(holder))
		CRASH("Facehugger try impregnate outside its holder")

	var/forced = isnull(holder.forced_equip) ? TRUE : holder.forced_equip
	holder.forced_equip = null
	if(!is_mob_suitable_to_impregnate(H, forced))
		return FALSE

	var/continue_impregnation = FALSE
	var/obj/item/organ/internal/alien_embryo/AE = H.internal_organs_by_name[BP_EMBRYO]
	if(!AE)
		continue_impregnation = TRUE
	else if(AE.status & ORGAN_DEAD)
		qdel(AE)
		continue_impregnation = TRUE

	if(continue_impregnation)
		AE = new /obj/item/organ/internal/alien_embryo(H)
		H.internal_organs_by_name[BP_EMBRYO] = AE
		is_sterile = TRUE
		H.Paralyse(20)
		return TRUE

	to_chat(H, "You feel something going down your throat and rapidly ejecting a few moments later.")
	return FALSE


/mob/living/simple_animal/hostile/facehugger/proc/is_mob_suitable_to_impregnate(mob/living/carbon/human/H, forced = FALSE)
	if(!istype(H))
		return FALSE

	if(H.isSynthetic())
		return FALSE

	return H.species?.xenomorph_type && !stat && !is_sterile && (forced || !H.internal_organs_by_name[BP_HIVE])


/mob/living/simple_animal/hostile/facehugger/AttackingTarget()
	. = ..()
	if(istype(., /mob/living/carbon/human))
		var/mob/living/carbon/human/H = .
		if(prob(H.getBruteLoss()/2))
			facefuck(H) // A tiny chance to facefuck them in melee

/mob/living/simple_animal/hostile/facehugger/Shoot(target, start, user, bullet = 0)
	if(target == start)
		return

	var/obj/item/projectile/facehugger_proj/A = new /obj/item/projectile/facehugger_proj(get_turf(user))
	if(!A)
		return
	src.forceMove(A)
	A.holder = src
	A.launch(target, BP_HEAD)


/////////////////////////////////////
// I'm a holder now, not a mask :P //
/////////////////////////////////////
/obj/item/holder/facehugger
	origin_tech = list(TECH_BIO = 4)
	slot_flags = SLOT_MASK | SLOT_HOLSTER
	icon_state = "facehugger"
	item_state = "facehugger"
	var/forced_equip = FALSE

/obj/item/holder/facehugger/proc/kill_holder()
	var/mob/living/simple_animal/hostile/facehugger/F = held_mob
	F.death()
	sync()

/obj/item/holder/facehugger/attack(mob/target, mob/user)
	var/mob/living/simple_animal/hostile/facehugger/F = held_mob
	if(user && !F.stat && istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		if(!do_mob(user, H, 20))
			return
		user.drop(src)
		if(F.facefuck(H, TRUE, TRUE))
			H.visible_message(SPAN("warning", "[user] latches \the [F] onto [H]'s face!"))
		return
	..()

/obj/item/holder/facehugger/equipped(mob/user, slot)
	if(slot == slot_wear_mask)
		var/mob/living/simple_animal/hostile/facehugger/F = held_mob
		if(F.impregnate(user))
			kill_holder()

	return ..()


/mob/living/simple_animal/hostile/facehugger/lamarr
	name = "Lamarr"
	desc = "For years, she kept hiding somewhere aboard Exodus. One hell of a tenacious creature, isn't she?"
	is_sterile = TRUE
