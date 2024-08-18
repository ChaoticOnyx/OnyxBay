/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20

	mob_bump_flag = SIMPLE_ANIMAL
	mob_swap_flags = MONKEY|METROID|SIMPLE_ANIMAL
	mob_push_flags = MONKEY|METROID|SIMPLE_ANIMAL

	var/show_stat_health = 1	//does the percentage health show in the stat panel for the mob

	var/icon_living = ""
	var/icon_dead = ""
	var/icon_gib = null	//We only try to show a gibbing animation if this exists.

	var/list/speak = list("...")
	var/speak_chance = 0
	var/list/emote_hear = list()	//Hearable emotes
	var/list/emote_see = list()		//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

	var/vision_range = 7 //How big of an area to search for targets in, a vision of 7 attempts to find targets as soon as they walk into screen view
	var/turns_per_move = 1
	var/turns_since_move = 0
	universal_speak = 0		//No, just no.
	var/meat_amount = 0
	var/meat_type
	var/stop_automated_movement = 0 //Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/wander = 1	// Does the mob wander around when idle?
	var/stop_automated_movement_when_pulled = 1 //When set to 1 this stops the animal from moving when someone is pulling it.

	//Interaction
	var/response_help   = "tries to help"
	var/response_disarm = "tries to disarm"
	var/response_harm   = "tries to hurt"
	var/harm_intent_damage = 3 // How much damage a human deals upon punching
	var/can_escape = 0 // 'smart' simple animals such as human enemies, or things small, big, sharp or strong enough to power out of a net
	var/weakref/panic_target = null // shy simple animals run away from humans
	var/turns_since_scan = 0
	var/shy_animal = 0

	//Temperature effect
	var/minbodytemp = 250
	var/maxbodytemp = 350
	var/heat_damage_per_tick = 3	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	var/cold_damage_per_tick = 2	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	var/fire_alert = 0
	var/oxygen_alert = 0
	var/toxins_alert = 0

	//Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/min_gas = list("oxygen" = 5)
	var/max_gas = list("plasma" = 1, "carbon_dioxide" = 5)
	var/unsuitable_atoms_damage = 2	//This damage is taken when atmos doesn't fit all the requirements above
	var/speed = 0 //LETS SEE IF I CAN SET SPEEDS FOR SIMPLE MOBS WITHOUT DESTROYING EVERYTHING. Higher speed is slower, negative speed is faster

	//LETTING SIMPLE ANIMALS ATTACK? WHAT COULD GO WRONG. Defaults to zero so Ian can still be cuddly
	var/melee_damage_lower = 0
	var/melee_damage_upper = 0
	var/attacktext = "attacked"
	var/attack_sound = null
	var/friendly = "nuzzles"
	var/environment_smash = 0
	var/resistance		  = 0	// Damage reduction
	var/armor_projectile  = 0   // Percentage of projectile damage blocked by a simple animal

	var/damtype = BRUTE
	var/defense = "melee"
	var/bodyparts = /decl/simple_animal_bodyparts // Fake bodyparts that can be shown when hit by projectiles.

	//Null rod stuff
	var/supernatural = 0
	var/purge = 0

	// contained in a cage
	var/in_stasis = 0

	var/datum/mob_ai/mob_ai
	var/is_pet = FALSE

/mob/living/simple_animal/Initialize()
	. = ..()
	if(is_pet)
		mob_ai = new /datum/mob_ai/pet()
	else if(ispath(mob_ai))
		mob_ai = new mob_ai()
	else
		mob_ai = new()
	mob_ai.holder = src

	if(bodyparts)
		bodyparts = decls_repository.get_decl(bodyparts)

	add_movespeed_modifier(/datum/movespeed_modifier/simple_animal)

/mob/living/simple_animal/Destroy()
	mob_ai.holder = null
	QDEL_NULL(mob_ai)
	panic_target = null
	. = ..()

/mob/living/simple_animal/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol)
	..()
	mob_ai.listen(speaker, message)

/mob/living/simple_animal/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, part_c, mob/speaker = null, hard_to_hear = 0)
	..()
	mob_ai.listen(speaker, message)

/mob/living/simple_animal/Life()
	if(is_ooc_dead())
		return 0
	. = ..()
	if(!.)
		walk(src, 0)
		return 0

	handle_stunned()
	handle_weakened()
	handle_paralysed()
	handle_supernatural()

	mob_ai.attempt_escape()

	mob_ai.process_moving()

	mob_ai.process_speaking()

	mob_ai.process_special_actions()

	if(in_stasis)
		return 1

	if(shy_animal)
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			handle_panic_target()

	return 1

/mob/living/simple_animal/do_check_environment()
	return !in_stasis

/mob/living/simple_animal/handle_environment(datum/gas_mixture/environment)
	var/atmos_suitable = 1

	if( abs(environment.temperature - bodytemperature) > 40 )
		bodytemperature += (environment.temperature - bodytemperature) / 5
	if(min_gas)
		for(var/gas in min_gas)
			if(environment.gas[gas] < min_gas[gas])
				atmos_suitable = 0
				oxygen_alert = 1
			else
				oxygen_alert = 0
	if(max_gas)
		for(var/gas in max_gas)
			if(environment.gas[gas] > max_gas[gas])
				atmos_suitable = 0
				toxins_alert = 1
			else
				toxins_alert = 0

	//Atmos effect
	if(bodytemperature < minbodytemp)
		fire_alert = 2
		adjustBruteLoss(cold_damage_per_tick)
	else if(bodytemperature > maxbodytemp)
		fire_alert = 1
		adjustBruteLoss(heat_damage_per_tick)
	else
		fire_alert = 0

	if(!atmos_suitable)
		adjustBruteLoss(unsuitable_atoms_damage)

/mob/living/simple_animal/proc/escape(mob/living/M, obj/O)
	O.unbuckle_mob(M)
	visible_message("<span class='danger'>\The [M] escapes from \the [O]!</span>")

/mob/living/simple_animal/proc/handle_supernatural()
	if(purge)
		purge -= 1
		update_purge_movespeed()

/mob/living/simple_animal/gib(anim, do_gibs = TRUE)
	..(icon_gib, do_gibs)

/mob/living/simple_animal/bullet_act(obj/item/projectile/Proj)
	if(!Proj)
		return

	var/damage = Proj.damage * ((100 - armor_projectile) / 100)
	if(Proj.damtype == STUN || Proj.damtype == PAIN)
		damage = (Proj.damage / 8) + (Proj.agony / 8)

	adjustBruteLoss(damage)
	return 0

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M as mob)
	..()

	switch(M.a_intent)

		if(I_HELP)
			if(health > 0)
				M.visible_message("<span class='notice'>[M] [response_help] \the [src].</span>")

		if(I_DISARM)
			M.visible_message("<span class='notice'>[M] [response_disarm] \the [src].</span>")
			M.do_attack_animation(src)
			//TODO: Push the mob away or something

		if(I_HURT)
			adjustBruteLoss(harm_intent_damage * M.species.generic_attack_mod)
			M.visible_message("<span class='warning'>[M] [response_harm] \the [src]!</span>")
			M.do_attack_animation(src)

	return

/mob/living/simple_animal/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/stack/medical))
		if(!is_ooc_dead())
			var/obj/item/stack/medical/MED = O
			if(!MED.animal_heal)
				to_chat(user, "<span class='notice'>That [MED] won't help \the [src] at all!</span>")
				return
			if(health < maxHealth)
				if(MED.amount >= 1)
					adjustBruteLoss(-MED.animal_heal)
					MED.amount -= 1
					if(MED.amount <= 0)
						qdel(MED)
					for(var/mob/M in viewers(src, null))
						if ((M.client && !( M.blinded )))
							M.show_message("<span class='notice'>[user] applies the [MED] on [src].</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] is dead, medical items won't bring \him back to life.</span>")
		return
	if(meat_type && (is_ooc_dead()))	//if the animal has a meat, and if it is dead.
		if(istype(O, /obj/item/material/knife) || istype(O, /obj/item/material/knife/butch))
			harvest(user)
	else
		if(!O.force)
			visible_message("<span class='notice'>[user] gently taps [src] with \the [O].</span>")
		else
			O.attack(src, user, user.zone_sel.selecting)

/mob/living/simple_animal/hit_with_weapon(obj/item/O, mob/living/user, effective_force, hit_zone)

	visible_message("<span class='danger'>\The [src] has been attacked with \the [O] by [user]!</span>")

	if(O.force <= resistance)
		to_chat(user, "<span class='danger'>This weapon is ineffective; it does no damage.</span>")
		return 2

	var/damage = O.force
	if(O.damtype == PAIN)
		damage = 0
	if(O.damtype == STUN)
		damage = (O.force / 8)
	if(supernatural && istype(O,/obj/item/nullrod))
		damage *= 2
		purge = 3
		update_purge_movespeed()
	adjustBruteLoss(damage)

	return 0

/mob/living/simple_animal/proc/update_purge_movespeed()
	if(purge > 0)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/purge_slowdown, slowdown = cached_slowdown * purge)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/purge_slowdown)

/mob/living/simple_animal/Stat()
	. = ..()

	if(statpanel("Status") && show_stat_health)
		stat(null, "Health: [round((health / maxHealth) * 100)]%")

/mob/living/simple_animal/death(gibbed, deathmessage = "dies!", show_dead_message)
	. = ..()
	if(.)
		icon_state = icon_dead
		density = 0
		health = 0 //Make sure dey dead.
		walk_to(src, 0)

/mob/living/simple_animal/rejuvenate()
	..()
	icon_state = icon_living
	set_density(1)

/mob/living/simple_animal/updatehealth()
	if(is_ooc_dead())
		return
	if(status_flags & GODMODE)
		health = maxHealth
		set_stat(CONSCIOUS)
	else
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - getHalLoss()
		if(health <= 0)
			death()

/mob/living/simple_animal/ex_act(severity)
	if(!blinded)
		flash_eyes()

	var/damage
	switch(severity)
		if(1.0)
			damage = 500
			if(!prob(get_flat_armor(null, "bomb")))
				gib()
		if(2.0)
			damage = 120

		if(3.0)
			damage = 30

	adjustBruteLoss(damage * blocked_mult(get_flat_armor(null, "bomb")))

/mob/living/simple_animal/adjustBruteLoss(damage)
	..()
	updatehealth()

/mob/living/simple_animal/adjustFireLoss(damage)
	..()
	updatehealth()

/mob/living/simple_animal/adjustToxLoss(damage)
	..()
	updatehealth()

/mob/living/simple_animal/adjustOxyLoss(damage)
	..()
	updatehealth()

/mob/living/simple_animal/proc/SA_attackable(target_mob)
	if (isliving(target_mob))
		var/mob/living/L = target_mob
		if(!L.stat && L.health >= 0)
			return (0)
	if (istype(target_mob,/obj/mecha))
		var/obj/mecha/M = target_mob
		if (M.occupant)
			return (0)
	return 1

/mob/living/simple_animal/say(message)
	var/verb = "says"
	if(speak_emote.len)
		verb = pick(speak_emote)

	message = sanitize(message)

	..(message, null, verb)

/mob/living/simple_animal/get_speech_ending(verb, ending)
	return verb

/mob/living/simple_animal/put_in_hands(obj/item/W) // No hands.
	W.forceMove(get_turf(src))
	return 1

// Harvest an animal's delicious byproducts
/mob/living/simple_animal/proc/harvest(mob/user)
	var/actual_meat_amount = max(1,(meat_amount/2))
	if(meat_type && actual_meat_amount>0 && (is_ooc_dead()))
		for(var/i=0;i<actual_meat_amount;i++)
			var/obj/item/meat = new meat_type(get_turf(src))
			meat.SetName("[src.name] [meat.name]")
		if(issmall(src))
			user.visible_message("<span class='danger'>[user] chops up \the [src]!</span>")
			new /obj/effect/decal/cleanable/blood/splatter(get_turf(src))
			qdel(src)
		else
			user.visible_message("<span class='danger'>[user] butchers \the [src] messily!</span>")
			gib()

/mob/living/simple_animal/handle_fire()
	return

/mob/living/simple_animal/update_fire()
	return
/mob/living/simple_animal/IgniteMob()
	return
/mob/living/simple_animal/ExtinguishMob()
	return

/mob/living/simple_animal/proc/handle_panic_target()
	//see if we should stop panicing
	var/mob/M = panic_target?.resolve()
	if(istype(M))
		if(M.loc in view(src))
			stop_automated_movement = 1
			walk_away(src, M, 7, 4)
		else
			panic_target = null
			stop_automated_movement = 0

/mob/living/simple_animal/proc/set_panic_target(mob/M)
	if(M && !ckey)
		panic_target = weakref(M)
		turns_since_scan = 5
