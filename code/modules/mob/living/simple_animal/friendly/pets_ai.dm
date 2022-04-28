#define COMMAND_STOP 1 //basically moves around in area.
#define COMMAND_FOLLOW 2 //follows a owner
#define COMMAND_WANDERING 3 // set pet behaviour to basic simple animal behaviour: wandering

/datum/mob_ai/pet
	var/current_command
	var/mob/target_mob
	var/move_to_delay = 4 //delay for the automated movement.
	var/timer_to_forget_target
	var/mob/master = null //undisputed master. Their commands hold ultimate sway and ultimate power.
	var/static/list/text_to_command = list()

/datum/mob_ai/pet/Destroy()
	if(timer_to_forget_target)
		delete_wandering_timer()
	master = null
	target_mob = null
	return ..()

/datum/mob_ai/pet/New()
	..()
	if(!length(text_to_command))
		for(var/command_text in world.file2list("config/names/animal_commands/stop.txt"))
			if(!command_text)
				continue
			text_to_command[command_text] = COMMAND_STOP
		for(var/command_text in world.file2list("config/names/animal_commands/follow.txt"))
			if(!command_text)
				continue
			text_to_command[command_text] = COMMAND_FOLLOW
		for(var/command_text in world.file2list("config/names/animal_commands/wander.txt"))
			if(!command_text)
				continue
			text_to_command[command_text] = COMMAND_WANDERING

/datum/mob_ai/pet/do_move()
	..()
	var/turf/T = get_turf(holder)
	if(safe_area && T.loc != safe_area) // we are not in safe area, panic!
		create_wandering_timer()
	else
		delete_wandering_timer()

/datum/mob_ai/pet/process_special_actions()
	switch(current_command)
		if(COMMAND_STOP)
			process_waiting()
		if(COMMAND_FOLLOW)
			process_following()

/datum/mob_ai/pet/return_mob_friendness(mob/M)
	. = ..() || M == master

/datum/mob_ai/pet/proc/process_waiting()
	var/turf/T = get_turf(holder)
	if(T.loc != safe_area)
		toggle_to_wandering()
		return

/datum/mob_ai/pet/proc/ListTargets(vision_range)
	var/list/L = hearers(holder, vision_range)

	for (var/obj/mecha/M in mechas_list)
		if (M.z == holder.z && get_dist(holder, M) <= vision_range && can_see(holder, M, vision_range))
			L += M

	return L

/datum/mob_ai/pet/proc/process_following()
	holder.stop_automated_movement = TRUE
	if(!target_mob)
		return
	if(target_mob in ListTargets(holder.vision_range))
		delete_wandering_timer()
		walk_to(holder,target_mob,1,move_to_delay)
	else
		create_wandering_timer(5 SECONDS)

/datum/mob_ai/pet/proc/delete_wandering_timer()
	deltimer(timer_to_forget_target)
	timer_to_forget_target = null

/datum/mob_ai/pet/proc/create_wandering_timer(duration)
	if(timer_to_forget_target)
		return
	timer_to_forget_target = addtimer(CALLBACK(src, .proc/toggle_to_wandering), duration, TIMER_STOPPABLE)

/datum/mob_ai/pet/listen(mob/speaker, text)
	if(speaker != master)
		return

	for(var/command_text in text_to_command)
		if(findtext_char(text, command_text))
			var/command = text_to_command[command_text]
			switch(command)
				if(COMMAND_STOP)
					toggle_to_stay_command()
				if(COMMAND_FOLLOW)
					toggle_to_follow_command(speaker)
				if(COMMAND_WANDERING)
					toggle_to_wandering()
			break

/datum/mob_ai/pet/proc/toggle_to_wandering()
	current_command = COMMAND_WANDERING
	target_mob = null
	holder.stop_automated_movement = FALSE
	safe_area = null

/datum/mob_ai/pet/proc/toggle_to_stay_command()
	target_mob = null
	current_command = COMMAND_STOP
	holder.stop_automated_movement = TRUE
	var/turf/T = get_turf(holder)
	safe_area = T?.loc
	walk_to(holder,0)

/datum/mob_ai/pet/proc/toggle_to_follow_command(mob/speaker)
	current_command = COMMAND_FOLLOW
	safe_area = null
	target_mob = speaker //this wont bite me in the ass later.

#undef COMMAND_FOLLOW
#undef COMMAND_STOP
#undef COMMAND_WANDERING
