#define COMMAND_STOP "стой тут" //basically moves around in area.
#define COMMAND_FOLLOW "иди за" //follows a owner
#define COMMAND_WANDERING "прогуляйся" // set pet behaviour to basic behaviour: wandering
/datum/mob_ai
	var/mob/living/simple_animal/holder // contains the connected mob
	var/mob/master = null //undisputed master. Their commands hold ultimate sway and ultimate power.
	var/faction
	var/vision_range = 7 //How big of an area to search for targets in, a vision of 7 attempts to find targets as soon as they walk into screen view

/datum/mob_ai/proc/attempt_escape()
	if(holder.buckled && holder.can_escape)
		if(istype(holder.buckled, /obj/effect/energy_net))
			var/obj/effect/energy_net/Net = holder.buckled
			Net.escape_net(holder)
		else if(prob(50))
			holder.escape(holder, holder.buckled)
		else if(prob(50))
			holder.visible_message(SPAN("warning", "\The [holder] struggles against \the [holder.buckled]!"))

/datum/mob_ai/proc/process_moving()
	//Movement
	if(!holder.client && !holder.stop_automated_movement && holder.wander && !holder.anchored)
		if(isturf(holder.loc) && !holder.resting && !holder.buckled)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			holder.turns_since_move++
			if(holder.turns_since_move >= holder.turns_per_move)
				if(!(holder.stop_automated_movement_when_pulled && holder.pulledby)) //Some animals don't move when pulled
					do_move(pick(GLOB.cardinal))

/datum/mob_ai/proc/do_move(dir)
	holder.SelfMove(dir)

/datum/mob_ai/proc/process_speaking()
	//Speaking
	if(!holder.client && holder.speak_chance)
		if(rand(0,200) < holder.speak_chance)
			var/action = pick(
				holder.speak.len;      "speak",
				holder.emote_hear.len; "emote_hear",
				holder.emote_see.len;  "emote_see"
				)

			switch(action)
				if("speak")
					holder.say(pick(holder.speak))
				if("emote_hear")
					holder.audible_emote("[pick(holder.emote_hear)].")
				if("emote_see")
					holder.visible_emote("[pick(holder.emote_see)].")

/datum/mob_ai/proc/process_special_actions()
	return

/datum/mob_ai/proc/listen(mob/speaker, text)
	return TRUE

/datum/mob_ai/proc/ListTargets()
	var/list/L = hearers(holder, vision_range)

	for (var/obj/mecha/M in mechas_list)
		if (M.z == holder.z && get_dist(holder, M) <= vision_range && can_see(holder, M, vision_range))
			L += M

	return L

/datum/mob_ai/proc/return_mob_friendness(mob/M)
	. = M.faction == faction

//returns a list of everybody we wanna do stuff with.
//TODO: make this mess of code working, if you did it, replace this proc in simple_animals.dm, and remove /proc/ keyword from same proc in hostile/commanded.dm
/datum/mob_ai/proc/get_targets_by_name(text, filter_friendlies = 0)
	var/list/possible_targets = hearers(holder,10)
	. = list()
	for(var/mob/M in possible_targets)
		if(filter_friendlies && return_mob_friendness(M))
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

/datum/mob_ai/pet
	var/current_command
	var/list/known_commands = list()
	var/mob/target_mob
	var/area/safe_area
	var/move_to_delay = 4 //delay for the automated movement.
	var/timer_to_forget_target

/datum/mob_ai/pet/New()
	. = ..()
	known_commands = list(COMMAND_STOP, COMMAND_FOLLOW, COMMAND_WANDERING)

// /mob/living/simple_animal/pet/SelfMove(direction)
// 	var/turf/T = get_step(src, direction)
// 	if(safe_area && T?.loc != safe_area)
// 		return
// 	. = ..()

/datum/mob_ai/pet/process_moving()
	var/turf/T = get_turf(holder)
	if(safe_area && T.loc != safe_area)
		return
	..()

/datum/mob_ai/pet/process_special_actions()
	switch(current_command)
		if(COMMAND_WANDERING)
			wandering()
		if(COMMAND_STOP)
			commanded_stop()
		if(COMMAND_FOLLOW)
			follow_target()

/datum/mob_ai/pet/return_mob_friendness(mob/M)
	. = ..() || M == master

/datum/mob_ai/pet/proc/commanded_stop()
	var/turf/T = get_turf(holder)
	if(T.loc != safe_area)
		wandering()
		return

/datum/mob_ai/pet/proc/follow_target()
	holder.stop_automated_movement = TRUE
	if(!target_mob)
		return
	if(target_mob in ListTargets(10))
		QDEL_NULL(timer_to_forget_target)
		walk_to(holder,target_mob,1,move_to_delay)
	else
		timer_to_forget_target = addtimer(CALLBACK(src, .proc/wandering), 5 SECONDS, TIMER_STOPPABLE)

/datum/mob_ai/pet/listen(mob/speaker, text)
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

	return TRUE

/datum/mob_ai/pet/proc/wandering()
	current_command = COMMAND_WANDERING
	holder.stop_automated_movement = FALSE
	safe_area = null

/datum/mob_ai/pet/proc/stay_command(mob/speaker,text)
	target_mob = null
	current_command = COMMAND_STOP
	holder.stop_automated_movement = TRUE
	var/turf/T = get_turf(holder)
	safe_area = T?.loc
	walk_to(holder,0)
	return TRUE

/datum/mob_ai/pet/proc/follow_command(mob/speaker,text)
	//we can assume 'stop following' is handled by stop_command
	if(findtext_char(text, "мной"))
		current_command = COMMAND_FOLLOW
		target_mob = speaker //this wont bite me in the ass later.
		return 1
	var/list/targets = get_targets_by_name(text)
	if(targets.len > 1 || !length(targets)) //CONFUSED. WHO DO I FOLLOW?
		return 0

	current_command = COMMAND_FOLLOW //GOT SOMEBODY. BETTER FOLLOW EM.
	target_mob = pick(targets) //YEAH GOOD IDEA
	// schizophrenia above

	return 1

// presets for pets

/mob/living/simple_animal/cat/fluff/pet
	is_pet = TRUE

/mob/living/simple_animal/cat/kitten/pet
	is_pet = TRUE

/mob/living/simple_animal/corgi/pet
	is_pet = TRUE

/mob/living/simple_animal/lizard/pet
	is_pet = TRUE

#undef COMMAND_FOLLOW
#undef COMMAND_STOP
#undef COMMAND_WANDERING
