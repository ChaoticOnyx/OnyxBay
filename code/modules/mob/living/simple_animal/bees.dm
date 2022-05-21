/mob/living/simple_animal/bee
	name = "bees"
	icon = 'icons/obj/beekeeping.dmi'
	icon_state = "bees"
	icon_dead = "bees_dead"
	mob_size = 1
	var/strength = 1
	var/feral = 0
	var/mut = 0
	var/toxic = 0
	var/turf/target_turf
	var/mob/target_mob
	var/obj/machinery/beehive/parent
	var/list/chems
	turns_per_move = 3
	maxHealth = 20
	health = 20
	var/obj/machinery/portable_atmospherics/hydroponics/my_hydrotray
	response_harm   = "waves on"
	mob_size = MOB_MINISCULE
	pass_flags = PASS_FLAG_TABLE
	density = 0

/mob/living/simple_animal/bee/New(loc, obj/machinery/beehive/new_parent)
	parent = new_parent
	..()

/mob/living/simple_animal/bee/Destroy()
	if(parent)
		parent.owned_bee_swarms.Remove(src)

	return ..()

/mob/living/simple_animal/bee/proc/set_target_mob(mob/L)
	if(target_mob != L)
		if(target_mob)
			unregister_signal(target_mob, SIGNAL_QDELETING)
		target_mob = L
		if(!isnull(target_mob) && !client)
			register_signal(target_mob, SIGNAL_QDELETING, .proc/_target_deleted)

/mob/living/simple_animal/bee/proc/_target_deleted()
	set_target_mob(null)

/mob/living/simple_animal/bee/proc/sting_check()
//if we're strong enough, sting some people
	var/mob/living/carbon/human/M = target_mob
	if(M in view(src,1)) // Can I see my target?
		if(prob(max(feral * 10, 0)))	// Am I mad enough to want to sting? And yes, when I initially appear, I AM mad enough
			return 1
	return 0

/mob/living/simple_animal/bee/proc/sting(mob/living/carbon/human/M)
	var/sting_prob = 40 // Bees will always try to sting.
	var/obj/item/clothing/worn_suit = M.wear_suit
	var/obj/item/clothing/worn_helmet = M.head
	if(worn_suit) // Are you wearing clothes?
		sting_prob -= min(worn_suit.armor["bio"],70) // Is it sealed? I can't get to 70% of your body.
	if(worn_helmet)
		sting_prob -= min(worn_helmet.armor["bio"],30) // Is your helmet sealed? I can't get to 30% of your body.
	if( prob(sting_prob) && (M.stat == CONSCIOUS || (M.stat == UNCONSCIOUS && prob(25))) ) // Try to sting! If you're not moving, think about stinging.
		M.apply_damage(min(strength,2)+mut, BRUTE) // Stinging. The more mutated I am, the harder I sting.
		M.apply_damage((round(feral/10,1)*(max((round(strength/20,1)),1)))+toxic, TOX) // Bee venom based on how angry I am and how many there are of me!
		to_chat(M, "\red You have been stung!")
		M.flash_pain()

/mob/living/simple_animal/bee/proc/feral_update()
//if we're chasing someone, get a little bit angry
	if(target_mob && prob(5))
		feral++

	//calm down a little bit
	if(feral > 0)
		if(prob(feral * 20))
			feral -= 1
	else
		//if feral is less than 0, we're becalmed by smoke or steam
		if(feral < 0)
			feral += 1

		if(target_mob)
			set_target_mob(null)
			target_turf = null


/mob/living/simple_animal/bee/proc/spread()
	//calm down and spread out a little
	var/mob/living/simple_animal/bee/B = new(get_turf(pick(orange(src,1))))
	B.strength = rand(1,5)
	src.strength -= B.strength
	if(src.strength <= 5)
		src.icon_state = "bees"
	B.icon_state = "bees"
	if(src.parent)
		B.parent = src.parent
		src.parent.owned_bee_swarms.Add(B)

/mob/living/simple_animal/bee/proc/buzz()
	//make some noise
	if(prob(0.5))
		src.visible_message("\blue [pick("Buzzzz.","Hmmmmm.","Bzzz.")]")

/mob/living/simple_animal/bee/proc/calming()
	//smoke, water and steam calms us down
	var/calming = 0
	var/list/calmers = list(/obj/effect/effect/smoke/chem, \
	/obj/effect/effect/water, \
	/obj/effect/effect/foam, \
	/obj/effect/effect/steam, \
	/obj/effect/mist)

	for(var/this_type in calmers)
		var/mob/living/simple_animal/check_effect = locate() in src.loc
		if(istype(check_effect))
			if(check_effect.type == this_type)
				calming = 1
				break

	if(calming)
		if(feral > 0)
			src.visible_message("\blue The bees calm down!")
		feral = -10
		set_target_mob(null)
		target_turf = null
		icon_state = "bees"
		wander = 1

/mob/living/simple_animal/bee/proc/unite()
	for(var/mob/living/simple_animal/bee/B in src.loc)
		if(B == src)
			continue

		if(feral > 0)
			src.strength += B.strength
			qdel(B)
			if(strength > 5)
				icon_state = "bees_feral"
		else if(prob(10))
			//make the other swarm of bees stronger, then move away
			var/total_bees = B.strength + src.strength
			if(total_bees < 10)
				B.strength = min(5, total_bees)
				src.strength = total_bees - B.strength

				if(src.strength <= 0)
					qdel(src)
					return
				var/turf/simulated/floor/T = get_turf(get_step(src, pick(1,2,4,8)))
				density = 1
				if(T.Enter(src, get_turf(src)))
					src.loc = T
				density = 0
			break

/mob/living/simple_animal/bee/proc/target_mob_update()
	if(target_mob)
		if(target_mob in view(src,7))
			target_turf = get_turf(target_mob)
			wander = 0

		else // My target's gone! But I might still be pissed! You there. You look like a good stinging target!
			for(var/mob/living/carbon/G in view(src,7))
				set_target_mob(G)
				break

/mob/living/simple_animal/bee/proc/chasing()
	if(target_turf)
		if (!(DirBlocked(get_step(src, get_dir(src,target_turf)),get_dir(src,target_turf)))) // Check for windows and doors!
			Move(get_step(src, get_dir(src,target_turf)))
			if (prob(0.1))
				src.visible_message("\blue The bees swarm after [target_mob]!")
		if(src.loc == target_turf)
			target_turf = null
			wander = 1

/mob/living/simple_animal/bee/proc/special_wandering()
	if(target_turf) // If we have target - we will not wander
		return
	//find some flowers, harvest
	//angry bee swarms don't hang around
	if(feral > 0)
		turns_per_move = rand(1,3)
	else if(feral < 0)
		turns_since_move = 0
	else if(!my_hydrotray || my_hydrotray.loc != src.loc || my_hydrotray.dead || !my_hydrotray.seed)
		var/obj/machinery/portable_atmospherics/hydroponics/my_hydrotray = locate() in src.loc
		if(my_hydrotray)
			if(!my_hydrotray.dead && my_hydrotray.seed)
				turns_per_move = rand(20,50)
				toxic = my_hydrotray.toxins
				mut = my_hydrotray.mutation_level
			else
				my_hydrotray = null

	pixel_x = rand(-12,12)
	pixel_y = rand(-12,12)

/mob/living/simple_animal/bee/proc/nobeehive_processing()
	if(prob(10))
		strength -= 1
		if(strength <= 0)
			death()
		else if(strength <= 5)
			icon_state = "bees"

/mob/living/simple_animal/bee/Life()
	..()

	if(stat == CONSCIOUS)
		if(sting_check())
			sting(target_mob)
		feral_update()
		if(strength > 5 && feral <= 0)
			spread()
		buzz()
		calming()
		unite()
		target_mob_update()
		chasing()
		special_wandering()

	if(parent == null)
		nobeehive_processing()
