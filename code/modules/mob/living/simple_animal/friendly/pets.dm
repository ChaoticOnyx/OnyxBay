#define COMMAND_STOP "стой тут" //basically moves around in area.
#define COMMAND_FOLLOW "иди за" //follows a owner
#define COMMAND_WANDERING "прогуляйся" // set pet behaviour to basic behaviour: wandering
/mob/living/simple_animal/pet
	name = "Pet"
	desc = "Pet desc, it's bug"
	possession_candidate = FALSE
	var/mob/living/simple_animal/pet_holder // contains the real mob
	var/pet_path
	var/current_command
	var/list/known_commands = list()
	var/mob/master = null //undisputed master. Their commands hold ultimate sway and ultimate power.
	var/mob/target_mob
	var/area/safe_area
	var/move_to_delay = 4 //delay for the automated movement.
	var/vision_range = 7 //How big of an area to search for targets in, a vision of 7 attempts to find targets as soon as they walk into screen view

/mob/living/simple_animal/pet/Initialize()
	known_commands = list(COMMAND_STOP, COMMAND_FOLLOW, COMMAND_WANDERING)
	. = ..()
	if(pet_path)
		pet_holder = new pet_path(src)
		STOP_PROCESSING(SSmobs, pet_holder) // we will do all calling work inside this mob.
		pet_holder.the_real_src = src
		holder_type = pet_holder.holder_type
		sync_with_pet_holder()
	else
		QDEL_IN(src, 0)

/mob/living/simple_animal/pet/proc/sync_with_pet_holder()
	name = pet_holder.name
	desc = pet_holder.desc
	icon = pet_holder.icon
	icon_state = pet_holder.icon_state
	overlays = pet_holder.overlays
	update_icon()
	stat = pet_holder.stat
	health = pet_holder.health
	gender = pet_holder.gender

/mob/living/simple_animal/pet/bullet_act(obj/item/projectile/Proj)
	. = pet_holder?.bullet_act(arglist(args))

/mob/living/simple_animal/pet/blob_act(destroy, obj/effect/blob/source)
	. = pet_holder?.blob_act(arglist(args))

/mob/living/simple_animal/pet/stun_effect_act(stun_amount, agony_amount, def_zone, used_weapon)
	. = pet_holder?.stun_effect_act(arglist(args))

/mob/living/simple_animal/pet/electrocute_act(shock_damage, obj/source, siemens_coeff)
	. = pet_holder?.electrocute_act(arglist(args))

/mob/living/simple_animal/pet/emp_act(severity)
	. = pet_holder?.emp_act(arglist(args))

/mob/living/simple_animal/pet/hit_with_weapon(obj/item/O, mob/living/user, effective_force, hit_zone)
	. = pet_holder?.hit_with_weapon(arglist(args))

/mob/living/simple_animal/pet/attackby(obj/item/O, mob/user)
	. = pet_holder?.attackby(arglist(args))

/mob/living/simple_animal/pet/movement_delay()
	. = pet_holder?.movement_delay()

/mob/living/simple_animal/pet/death(gibbed, deathmessage, show_dead_message)
	pet_holder?.death(arglist(args))
	. = ..()

/mob/living/simple_animal/pet/updatehealth()
	. = pet_holder?.updatehealth()

/mob/living/simple_animal/pet/ex_act(severity)
	. = pet_holder?.ex_act(arglist(args))

/mob/living/simple_animal/pet/adjustBruteLoss(damage)
	. = pet_holder?.adjustBruteLoss(arglist(args))

/mob/living/simple_animal/pet/adjustFireLoss(damage)
	. = pet_holder?.adjustFireLoss(arglist(args))

/mob/living/simple_animal/pet/adjustToxLoss(damage)
	. = pet_holder?.adjustToxLoss(arglist(args))

/mob/living/simple_animal/pet/adjustOxyLoss(damage)
	. = pet_holder?.adjustOxyLoss(arglist(args))

/mob/living/simple_animal/pet/harvest(mob/user)
	pet_holder?.harvest(user)
	if(QDELETED(pet_holder))
		qdel(src)

/mob/living/simple_animal/pet/SA_attackable(target_mob)
	. = pet_holder?.SA_attackable(target_mob)

/mob/living/simple_animal/pet/say(message)
	. = pet_holder?.say(message)

/mob/living/simple_animal/pet/Topic(href, href_list)
	. = pet_holder?.Topic(arglist(args))

/mob/living/simple_animal/pet/get_scooped(mob/living/carbon/human/grabber, self_grab)
	. = ..()
	if(.)
		wandering()

/mob/living/simple_animal/pet/Life()
	. = ..()
	if(pet_holder)
		. = pet_holder.Life()
		sync_with_pet_holder()
	switch(current_command)
		if(COMMAND_WANDERING)
			wandering()
		if(COMMAND_STOP)
			commanded_stop()
		if(COMMAND_FOLLOW)
			follow_target()

/mob/living/simple_animal/pet/SelfMove(direction)
	var/turf/T = get_step(src, direction)
	if(safe_area && T?.loc != safe_area)
		return
	. = ..()

/mob/living/simple_animal/pet/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol)
	if(speaker == master)
		listen(speaker, lowertext(message))
	return 0

/mob/living/simple_animal/pet/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, part_c, mob/speaker = null, hard_to_hear = 0)
	if(speaker == master)
		listen(speaker, lowertext(message))
	return 0

/mob/living/simple_animal/pet/proc/commanded_stop()
	var/turf/T = get_turf(src)
	if(T.loc != safe_area)
		wandering()
		return
	//Movement
	if(!client && wander && !anchored)
		if(isturf(the_real_src.loc) && !resting && !buckled)		//This is so it only moves if it's not inside a closet, genetics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) //Some animals don't move when pulled
					SelfMove(pick(GLOB.cardinal))

/mob/living/simple_animal/pet/proc/ListTargets()
	var/list/L = hearers(src, vision_range)

	for (var/obj/mecha/M in mechas_list)
		if (M.z == src.z && get_dist(src, M) <= vision_range && can_see(src, M, vision_range))
			L += M

	return L

/mob/living/simple_animal/pet/proc/follow_target()
	stop_automated_movement = TRUE
	if(!target_mob)
		return
	if(target_mob in ListTargets(10))
		walk_to(src,target_mob,1,move_to_delay)

/mob/living/simple_animal/pet/proc/listen(mob/speaker, text)
	if(speaker != master)
		return
	for(var/command in known_commands)
		if(findtext_char(text,command))
			switch(command)
				if(COMMAND_STOP)
					if(stay_command(speaker, text))
						break
				if(COMMAND_FOLLOW)
					if(follow_command(speaker,text))
						break
				if(COMMAND_WANDERING)
					wandering()

	return 1

//returns a list of everybody we wanna do stuff with.
//TODO: make this mess of code working, if you did it, replace this proc in simple_animals.dm, and remove /proc/ keyword from same proc in hostile/commanded.dm
/mob/living/simple_animal/pet/proc/get_targets_by_name(text, filter_friendlies = 0)
	var/list/possible_targets = hearers(src,10)
	. = list()
	for(var/mob/M in possible_targets)
		if(filter_friendlies && (M.faction == faction || M == master))
			continue
		var/found = FALSE
		if(findtext_char(text, "[M]"))
			found = TRUE
		else
			var/list/parsed_name = splittext(replace_characters(lowertext("[M]"),list("-"=" ", "."=" ", "," = " ", "'" = " ")), " ") //this big MESS is basically 'turn this into words, no punctuation, lowercase so we can check first name/last name/etc'
			for(var/a in parsed_name)
				if(a == "the" || length(a) < 2) //get rid of shit words.
					continue
				if(findtext_char(text,"[a]"))
					found = TRUE
					break
		if(found)
			. += M

/mob/living/simple_animal/pet/proc/wandering()
	current_command = COMMAND_WANDERING
	stop_automated_movement = FALSE
	safe_area = null

/mob/living/simple_animal/pet/proc/stay_command(mob/speaker,text)
	target_mob = null
	current_command = COMMAND_STOP
	stop_automated_movement = TRUE
	var/turf/T = get_turf(src)
	safe_area = T?.loc
	walk_to(src,0)
	return 1

/mob/living/simple_animal/pet/proc/follow_command(mob/speaker,text)
	//we can assume 'stop following' is handled by stop_command
	if(findtext_char(text, "мной"))
		current_command = COMMAND_FOLLOW
		target_mob = speaker //this wont bite me in the ass later.
		return 1
	var/list/targets = get_targets_by_name(text)
	if(targets.len > 1 || !targets.len) //CONFUSED. WHO DO I FOLLOW?
		return 0

	current_command = COMMAND_FOLLOW //GOT SOMEBODY. BETTER FOLLOW EM.
	target_mob = targets[1] //YEAH GOOD IDEA
	// schizophrenia above

	return 1

// presets

/mob/living/simple_animal/pet/cat
	pet_path = /mob/living/simple_animal/cat/fluff

/mob/living/simple_animal/pet/kitten
	pet_path = /mob/living/simple_animal/cat/kitten

/mob/living/simple_animal/pet/corgi
	pet_path = /mob/living/simple_animal/corgi

/mob/living/simple_animal/pet/lizard
	pet_path = /mob/living/simple_animal/lizard

#undef COMMAND_FOLLOW
#undef COMMAND_STOP
