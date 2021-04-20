
/mob/living/simple_animal/hostile/facehugger
	name = "alien"
	desc = "A viscious little creature, it looks like a connected pair of hands and has a long, muscular tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger_inactive"
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
	speed = 0
	move_to_delay = 0
	density = 0
	min_gas = null
	mob_size = MOB_MINISCULE
	can_escape = 1
	pass_flags = PASS_FLAG_TABLE
	melee_damage_lower = 5
	melee_damage_upper = 7.5

	ranged = 1
	pointblank_shooter = 1
	projectiletype = /obj/item/projectile/facehugger_proj
	ranged_message = "leaps"
	ranged_cooldown_cap = 2
	retreat_distance = 3 // Run away and try to leap again
	minimum_distance = 4
	holder_type = /obj/item/weapon/holder/facehugger
	faction = "xenomorph"

	var/is_sterile = FALSE

/mob/living/simple_animal/hostile/facehugger/ListTargets(dist = 7)
	var/list/L = list()
	for(var/a in hearers(src, dist))
		if(istype(a, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = a
			if(H.faction == faction) // No need to attack our fellow queens of blades
				continue
			var/obj/item/mask = H.get_equipped_item(slot_wear_mask)
			if(istype(mask, /obj/item/weapon/holder/facehugger)) // No need to interrupt our allies
				var/obj/item/weapon/holder/facehugger/F = mask
				if(F.wasted) // ...unless they are dead
					continue
			L += a
	return L

/mob/living/simple_animal/hostile/facehugger/death(gibbed, deathmessage, show_dead_message)
	. = ..(deathmessage = "limps!")
	if(.)
		if(is_sterile)
			icon_state = "facehugger_impregnated"

/mob/living/simple_animal/hostile/facehugger/get_scooped(mob/living/carbon/grabber)
	if(grabber.faction != "xenomorph" && !is_sterile && !stat)
		to_chat(grabber, SPAN("warning", "\The [src] wriggles out of your hands before you can pick it up!"))
		return
	else
		return ..()

/mob/living/simple_animal/hostile/facehugger/proc/facefuck(mob/living/carbon/human/H, silent = FALSE) // rude
	if(stat)
		return
	var/obj/item/organ/external/chest/VC = H.organs_by_name["chest"]
	var/obj/item/organ/external/head/VH = H.organs_by_name["head"]
	if(!VC || !VH)
		return 0
	var/obj/item/helmet = H.get_equipped_item(slot_head)
	if(helmet && ((helmet.item_flags & ITEM_FLAG_AIRTIGHT) || !helmet.knocked_out(H, dist = 0)))
		H.visible_message(SPAN("notice", "\The [src] [pick("smacks", "smashes", "blops", "bonks")] against [H]'s [helmet] harmlessly!"))
		return 0
	var/obj/item/mask = H.get_equipped_item(slot_wear_mask)
	if(mask && !mask.knocked_out(H, dist = 0))
		H.visible_message(SPAN("warning", "\The [src] tries to rip [H]'s [mask] off, but fails."))
		return 0
	var/obj/item/weapon/holder/facehugger/holder = new()
	src.forceMove(holder)
	if(!silent)
		H.visible_message(SPAN("warning", "\The [src] latches itself onto [H]'s face!"))
	holder.sync(src)
	H.equip_to_slot(holder, slot_wear_mask)
	if(impregnate(H))
		holder.kill_holder()
	H.Paralyse(20)
	return 1

/mob/living/simple_animal/hostile/facehugger/proc/impregnate(mob/living/carbon/human/H)
	if(!H)
		return 0

	var/obj/item/organ/internal/alien_embryo/AE = H.internal_organs_by_name[BP_EMBRYO]
	if(!AE)
		AE = new /obj/item/organ/internal/alien_embryo(H)
		H.internal_organs_by_name[BP_EMBRYO] = AE
		is_sterile = TRUE
		to_chat(H, "You feel something going down your throat!")
		return 1
	to_chat(H, "You feel something going down your throat and rapidly ejecting a few moments later.")
	return 0

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
/obj/item/weapon/holder/facehugger
	origin_tech = list(TECH_BIO = 4)
	slot_flags = SLOT_MASK | SLOT_HOLSTER
	throw_speed = 4
	icon_state = "facehugger"
	item_state = "facehugger"
	var/wasted = FALSE

/obj/item/weapon/holder/facehugger/proc/kill_holder()
	var/mob/living/simple_animal/hostile/facehugger/F = contents[1]
	if(F)
		F.death()
		sync(F)
		wasted = TRUE

/obj/item/weapon/holder/facehugger/sync(mob/living/M)
	..()
	if(!istype(M, /mob/living/simple_animal/hostile/facehugger))
		return
	var/mob/living/simple_animal/hostile/facehugger/F = M
	if(F.stat)
		wasted = TRUE

/obj/item/weapon/holder/facehugger/attack(mob/target, mob/user)
	var/mob/living/simple_animal/hostile/facehugger/F = contents[1]
	if(user && !F.stat && istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		if(!do_mob(user, H, 20))
			return
		user.drop_from_inventory(src)
		if(F.facefuck(H, TRUE))
			H.visible_message(SPAN("warning", "[user] latches \the [F] onto [H]'s face!"))
		return
	..()
