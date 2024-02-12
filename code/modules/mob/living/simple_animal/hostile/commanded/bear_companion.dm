/mob/living/simple_animal/hostile/commanded/bear
	name = "bear"
	desc = "A large bear."
	stance = HOSTILE_STANCE_ALERT


	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	icon_gib = "bear_gib"
	var/icon/icon_sit = "bear_sit"

	health = 75
	maxHealth = 75

	density = 1

	attacktext = "swatted"
	melee_damage_lower = 10
	melee_damage_upper = 10
	can_escape = 1

	max_gas = list("plasma" = 2, "carbon_dioxide" = 5)

	response_help = "pets"
	response_harm = "hits"
	response_disarm = "pushes"
	bodyparts = /decl/simple_animal_bodyparts/quadruped

	known_commands = list("stay", "stop", "attack", "follow", "dance", "add friend", "remove friend")

/mob/living/simple_animal/hostile/commanded/bear/hit_with_weapon(obj/item/O, mob/living/user, effective_force, hit_zone)
	. = ..()
	if(!.)
		audible_emote("roars in rage!")

/mob/living/simple_animal/hostile/commanded/bear/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(M.a_intent == I_HURT)
		audible_emote("roars in rage!")

/mob/living/simple_animal/hostile/commanded/bear/listen()
	if(stance != COMMANDED_MISC) //cant listen if its booty shakin'
		return ..()

/mob/living/simple_animal/hostile/commanded/bear/Life()
	. = ..()
	if(. && stance == COMMANDED_MISC)
		stop_automated_movement = TRUE

//Handles cursed dancing command as well as adds/removes friends
/mob/living/simple_animal/hostile/commanded/bear/misc_command(mob/speaker, text)
	for(var/command in known_commands)
		if(findtext(text, command))
			switch(command)
				if("dance")
					dance()
				if("add friend")
					add_friend(speaker, text)
				if("remove friend")
					remove_friend(speaker, text)

/mob/living/simple_animal/hostile/commanded/bear/on_radial_click(mob/living/carbon/human/M, command)
	if(stance == COMMANDED_MISC) // bear won't accept commands while dancing
		to_chat(M, SPAN_WARNING("Your [src] is dancing, it won't listen to your orders for a while."))
		return

	. = ..()
	if(!.)
		return

	var/list/possible_targets = radial_targets(M, FALSE)
	var/mob/target = null
	switch(command)
		if("add friend")
			for(var/mob/T in possible_targets)
				if(weakref(T) in friends)
					possible_targets -= M
			if(!possible_targets.len)
				return

			target = input(M, "Choose whom to follow.", "Targeting") as null|anything in possible_targets
			if(!target)
				return

			add_friend(M, text, target)
		if("remove friend")
			for(var/mob/T in possible_targets)
				if(!(weakref(T) in friends))
					possible_targets -= M
			if(!possible_targets.len)
				return

			target = input(M, "Choose whom to follow.", "Targeting") as null|anything in possible_targets
			if(!target)
				return

			remove_friend(M, null, target)
		if("dance")
			dance()

/mob/living/simple_animal/hostile/commanded/bear/proc/dance()
	stop_automated_movement = TRUE
	stance = COMMANDED_MISC //nothing can stop this ride
	update_icon()
	visible_message("\The [src] starts to dance!.")
	var/datum/gender/G = gender_datums[gender]
	spawn(0)
		emote("dance")
	for(var/i in 1 to 10)
		if(stance != COMMANDED_MISC || incapacitated()) //something has stopped this ride.
			return

		var/message = pick(\
						"moves [G.his] head back and forth!",\
						"bobs [G.his] booty!",\
						"shakes [G.his] paws in the air!",\
						"wiggles [G.his] ears!",\
						"taps [G.his] foot!",\
						"shrugs [G.his] shoulders!",\
						"dances like you've never seen!")
		if(dir != WEST)
			set_dir(WEST)
		else
			set_dir(EAST)
		visible_message("\The [src] [message]")
		sleep(30)

	set_dir(SOUTH)
	visible_message("\The [src] bows, finished with [G.his] dance.")
	stance = COMMANDED_STOP
	stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/commanded/bear/proc/add_friend(mob/speaker, text, mob/target = null)
	var/mob/living/future_friend = null

	if(!target)
		var/list/targets = get_targets_by_name(text)
		if(targets.len > 1 || !targets.len)
			return FALSE

		if(!isliving(targets[1])) //Ghosts are not worthy of friendships
			return

		future_friend = targets[1]
	else
		future_friend = target

	if(weakref(future_friend) in friends) // Already befriended
		audible_emote("shakes his head, visibly confused!") // Feedback for players
		return FALSE

	friends += weakref(future_friend)
	audible_emote("growls affirmatevly, slightly bowing to [future_friend]!")

/mob/living/simple_animal/hostile/commanded/bear/proc/remove_friend(mob/speaker, text, mob/target = null)
	var/mob/living/former_friend = null

	if(!target)
		var/list/targets = get_targets_by_name(text)
		if(targets.len > 1 || !targets.len)
			return FALSE

		if(!isliving(targets[1])) //something is wrong. VERY wrong.
			return

		former_friend = targets[1]
	else
		former_friend = target

	if(weakref(former_friend) in friends)
		friends -= weakref(former_friend)
		audible_emote("roars at [former_friend]!")
	else
		audible_emote("shakes his head, visibly confused!") // Feedback for players



/mob/living/simple_animal/hostile/commanded/bear/_examine_text(mob/user)
	. = ..()
	if(is_ic_dead())
		. += SPAN("deadsay", "It appears to be dead.\n")
	else if(health < maxHealth)
		. += SPAN("warning", "It looks [health >= maxHealth / 2 ? "slightly" : "<b>severely</b>"] beaten!\n")
	switch(stance)
		if(HOSTILE_STANCE_IDLE)
			. += SPAN("warning", "[src] wanders aimlessly.")
		if(HOSTILE_STANCE_ALERT)
			. += SPAN("warning", "[src] looks alert!")
		if(HOSTILE_STANCE_ATTACK)
			. += SPAN("warning", "[src] is in an aggressive stance!")
		if(HOSTILE_STANCE_ATTACKING)
			. += SPAN("warning", "[src] !\n")
		if(HOSTILE_STANCE_TIRED)
			. += SPAN("warning", "[src] looks severly tired!")
		if(COMMANDED_STOP)
			. += SPAN("warning", "[src] sits patiently, waiting for its master!")
	return

/mob/living/simple_animal/hostile/commanded/bear/stay_command()
	..()
	update_icon()

/mob/living/simple_animal/hostile/commanded/bear/on_update_icon()
	if(stance == COMMANDED_STOP)
		icon_state = icon_sit
	else
		icon_state = icon_living

/mob/living/simple_animal/hostile/commanded/bear/find_target()
	. = ..()
	update_icon()

/mob/living/simple_animal/hostile/commanded/bear/follow_target()
	. = ..()
	update_icon()

/mob/living/simple_animal/hostile/commanded/bear/stop_command()
	. = ..()
	update_icon()

/mob/living/simple_animal/hostile/commanded/bear/follow_command()
	. = ..()
	update_icon()

/mob/living/simple_animal/hostile/commanded/bear/attack_command()
	. = ..()
	update_icon()

/mob/living/simple_animal/hostile/commanded/bear/MoveToTarget()
	. = ..()
	update_icon()
