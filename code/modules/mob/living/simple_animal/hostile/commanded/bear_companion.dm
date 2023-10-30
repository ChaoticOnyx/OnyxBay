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

	known_commands = list("stay", "stop", "attack", "follow", "dance", "befriend", "forget")

/mob/living/simple_animal/hostile/commanded/bear/hit_with_weapon(obj/item/O, mob/living/user, effective_force, hit_zone)
	. = ..()
	if(!.)
		visible_emote("roars in rage!")

/mob/living/simple_animal/hostile/commanded/bear/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(M.a_intent == I_HURT)
		visible_emote("roars in rage!")

/mob/living/simple_animal/hostile/commanded/bear/listen()
	if(stance != COMMANDED_MISC) //cant listen if its booty shakin'
		return ..()

/mob/living/simple_animal/hostile/commanded/bear/Life()
	. = ..()
	if(. && stance == COMMANDED_MISC)
		stop_automated_movement = TRUE

//Handles cursed dancing command as well as adds/removes friends
/mob/living/simple_animal/hostile/commanded/bear/misc_command(mob/speaker,text)
	for(var/command in known_commands)
		if(findtext(text,command))
			switch(command)
				if("dance")
					dance()
				if("befriend")
					add_friend(speaker, text)
				if("forget")
					remove_friend(speaker, text)

/mob/living/simple_animal/hostile/commanded/bear/proc/dance()
	stop_automated_movement = TRUE
	stance = COMMANDED_MISC //nothing can stop this ride
	src.visible_message("\The [src] starts to dance!.")
	var/datum/gender/G = gender_datums[gender]
	var/decl/emote/human/dance/dance_emote = new /decl/emote/human/dance
	spawn(0)
		dance_emote.do_emote(src)
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
		src.visible_message("\The [src] [message]")
		sleep(30)
	dance_emote.dancing.Remove(weakref(src))
	set_dir(SOUTH)
	src.visible_message("\The [src] bows, finished with [G.his] dance.")
	stance = COMMANDED_STOP
	stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/commanded/bear/proc/add_friend(mob/speaker,text)
	var/list/targets = get_targets_by_name(text)
	if(targets.len > 1 || !targets.len)
		return FALSE

	var/mob/living/future_friend = targets[1]

	if(!isliving(future_friend)) //Again, get_targets_by_name takes hearers(), which can add ghosts to the list. I do not find ghosts worthy of friendship.
		return

	if(weakref(future_friend) in friends) // Already befriended
		visible_emote("shakes his head, visibly confused!") // Feedback for players
		return
	friends += weakref(future_friend)
	visible_emote("growls affirmatevly, slightly bowing to [future_friend]!")


/mob/living/simple_animal/hostile/commanded/bear/proc/remove_friend(mob/speaker,text)
	var/list/targets = get_targets_by_name(text)
	if(targets.len > 1 || !targets.len)
		return FALSE

	var/mob/living/former_friend = targets[1]

	if(!isliving(former_friend)) //something is wrong. VERY wrong.
		return

	if(weakref(former_friend) in friends)
		friends -= weakref(former_friend)
		visible_emote("roars at [former_friend]!")

/mob/living/simple_animal/hostile/commanded/bear/_examine_text(mob/user)
	. = ..()
	if (is_ooc_dead())
		. += "<span class='deadsay'>It appears to be dead.</span>\n"
	else if (health < maxHealth)
		. += "<span class='warning'>"
		if (health >= maxHealth/2)
			. += "It looks slightly beaten!\n"
		else
			. += "<B>It looks severely beaten!</B>\n"
		. += "</span>"
	switch(stance)
		if(HOSTILE_STANCE_IDLE)
			. += SPAN("warning", "[src] wanders aimlessly.\n")
		if(HOSTILE_STANCE_ALERT)
			. += SPAN("warning", "[src] looks alert!\n")
		if(HOSTILE_STANCE_ATTACK)
			. += SPAN("warning", "[src] is in an aggressive stance!\n")
		if(HOSTILE_STANCE_ATTACKING)
			. += SPAN("warning", "[src] !\n")
		if(HOSTILE_STANCE_TIRED)
			. += SPAN("warning", "[src] looks severly tired!\n")
		if(COMMANDED_STOP)
			. += SPAN("warning", "[src] sits patiently, waiting for its master!\n")


	return

/mob/living/simple_animal/hostile/commanded/bear/stay_command()
	..()
	update_icon()

/mob/living/simple_animal/hostile/commanded/bear/update_icon()
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
