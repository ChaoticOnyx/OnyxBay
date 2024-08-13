
/mob/living/simple_animal/pig
	name = "pig"
	desc = "This sausage is still kicking."
	icon_state = "pig"
	icon_living = "pig"
	icon_dead = "pig_dead"
	speak = list("oink?", "oink", "OINK")
	speak_emote = list("oinks", "honks")
	emote_hear = list("oinks")
	emote_see = list("shakes its head", "is loafing around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/reagent_containers/food/meat/pork
	meat_amount = 5
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "headbutted"
	maxHealth = 75
	health = 75

	bodyparts = /decl/simple_animal_bodyparts/quadruped
	mob_ai = /datum/mob_ai/pig

/mob/living/simple_animal/pig/attack_hand(mob/living/carbon/M)
	if(!stat && M.a_intent == I_DISARM)
		M.visible_message(SPAN("warning", "[M] pulls [src]'s tail!"), SPAN("notice", "You pull [src]'s tail."))
		if(prob(33))
			visible_message("<b>[src]</b> oinks hysterically!")
			playsound(loc, pick('sound/effects/pig1.ogg','sound/effects/pig2.ogg','sound/effects/pig3.ogg'), 100, 1)
	else
		..()

/mob/living/simple_animal/pig/proc/consume_food(obj/item/reagent_containers/food/F, silent = FALSE)
	if(stat)
		return FALSE

	if(!Adjacent(F))
		return FALSE

	qdel(F)
	if(!silent)
		visible_message("<b>[src]</b> greedily devours \the [F]!")

	return TRUE

/mob/living/simple_animal/pig/Life()
	. = ..()
	if(!.)
		return

	if(stat || resting || buckled)
		return

	var/datum/mob_ai/pig/pig_ai = mob_ai

	if(pig_ai.movement_target && Adjacent(pig_ai.movement_target))
		consume_food(pig_ai.movement_target)
		turns_since_scan--

	if(QDELETED(pig_ai.movement_target) || !isturf(pig_ai.movement_target.loc))
		pig_ai.movement_target = null

	turns_since_scan++
	if(turns_since_scan > 5)
		turns_since_scan = 0

		if(!pig_ai.movement_target || !(pig_ai.movement_target.loc in oview(src, 3)))
			pig_ai.movement_target = null

			for(var/obj/item/reagent_containers/food/S in oview(src, 3))
				if(!isturf(S.loc))
					continue
				if(Adjacent(S))
					consume_food(S)
				else
					pig_ai.movement_target = S
				break

/mob/living/simple_animal/pig/mini
	name = "mini pig"
	desc = "This cocktail sausage is still kicking."
	icon_state = "pig_mini"
	icon_living = "pig_mini"
	icon_dead = "pig_mini_dead"
	density = FALSE
	mob_size = MOB_SMALL
	pass_flags = PASS_FLAG_TABLE
	maxHealth = 25 // Smol HP for smol piggies
	health = 25
	response_harm   = "stomps on"
	meat_amount = 2

	can_pull_size = ITEM_SIZE_NORMAL
	can_pull_mobs = MOB_PULL_SAME

	holder_type = /obj/item/holder/mini_pig

/mob/living/simple_animal/pig/mini/mykola
	name = "Mykola"
	desc = "Cargo pig, cargo pig, does whatever a cargo pig does. Probably."
	var/growth_chance = 0.01

/mob/living/simple_animal/pig/mini/mykola/consume_food(obj/item/reagent_containers/food/F, silent = FALSE)
	. = ..()
	if(!.)
		return
	growth_chance += 0.1

/mob/living/simple_animal/pig/mini/mykola/Life()
	. = ..()
	if(!.)
		return

	if(prob(growth_chance))
		new /mob/living/simple_animal/pig/dzherelo(loc)
		qdel(src)

/mob/living/simple_animal/pig/dzherelo
	name = "Dzherelo"
	desc = "If I had words to make a day for you..."
	icon_state = "pig_maxi"
	icon_living = "pig_maxi"
	icon_dead = "pig_maxi_dead"
	meat_amount = 10


// Yes, pigs DO have an advanced AI, unlike most mobs. That's exactly what we deserve.
/datum/mob_ai/pig
	var/atom/movable/movement_target

/datum/mob_ai/pig/process_moving()
	//Movement
	if(holder.client || holder.stop_automated_movement || holder.anchored || holder.resting || holder.buckled || !isturf(holder.loc))
		return

	if(movement_target)
		do_move(TRUE)
		return

	if(holder.wander)
		holder.turns_since_move++
		if(holder.turns_since_move >= holder.turns_per_move)
			if(holder.stop_automated_movement_when_pulled && holder.pulledby)
				return
			do_move()
	return

/datum/mob_ai/pig/do_move(curated = FALSE)
	if(!curated)
		..()
		return

	var/d = get_dir(holder, movement_target)
	if(d & (d - 1))
		var/ax = abs(movement_target.x - holder.x)
		var/ay = abs(movement_target.y - holder.y)
		d &= (rand(1, ax + ay) <= ax) ? 12 : 3

	holder.SelfMove(d)
