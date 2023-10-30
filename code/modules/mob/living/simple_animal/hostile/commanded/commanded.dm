/mob/living/simple_animal/hostile/commanded
	name = "commanded"
	stance = COMMANDED_STOP
	melee_damage_lower = 0
	melee_damage_upper = 0
	density = 0
	var/list/command_buffer = list()
	var/list/known_commands = list("stay", "stop", "attack", "follow")
	var/mob/master = null //undisputed master. Their commands hold ultimate sway and ultimate power.
	var/list/allowed_targets = list() //WHO CAN I KILL D:
	var/retribution = TRUE //whether or not they will attack us if we attack them like some kinda dick.

	var/list/radial_choices = list() //list of possible buttons in radial_menu

/mob/living/simple_animal/hostile/commanded/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol)
	if((weakref(speaker) in friends) || speaker == master)
		command_buffer.Add(speaker)
		command_buffer.Add(lowertext(html_decode(message)))
	return FALSE

/mob/living/simple_animal/hostile/commanded/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, part_c, mob/speaker = null, hard_to_hear = 0)
	if((weakref(speaker) in friends) || speaker == master)
		command_buffer.Add(speaker)
		command_buffer.Add(lowertext(html_decode(message)))
	return FALSE

/mob/living/simple_animal/hostile/commanded/Life()
	while(command_buffer.len > 0)
		var/mob/speaker = command_buffer[1]
		var/text = command_buffer[2]
		var/filtered_name = lowertext(html_decode(name))
		if(dd_hasprefix(text,filtered_name) || dd_hasprefix(text,"everyone") || dd_hasprefix(text, "everybody")) //in case somebody wants to command 8 bears at once.
			var/substring = copytext(text,length(filtered_name)+1) //get rid of the name.
			listen(speaker,substring)
		command_buffer.Remove(command_buffer[1],command_buffer[2])
	. = ..()
	if(.)
		switch(stance)
			if(COMMANDED_FOLLOW)
				follow_target()
			if(COMMANDED_STOP)
				commanded_stop()



/mob/living/simple_animal/hostile/commanded/find_target(new_stance = HOSTILE_STANCE_ATTACK)
	if(!allowed_targets.len)
		return null
	var/mode = "specific"
	if(allowed_targets[1] == "everyone") //we have been given the golden gift of murdering everything. Except our master, of course. And our friends. So just mostly everyone.
		mode = "everyone"
	for(var/atom/A in ListTargets(10))
		var/mob/M = null
		if(A == src)
			continue
		if(isliving(A))
			M = A
		if(istype(A,/obj/mecha))
			var/obj/mecha/mecha = A
			if(!mecha.occupant)
				continue
			M = mecha.occupant
		if(M && M.stat)
			continue
		if(mode == "specific")
			if(!(A in allowed_targets))
				continue
			stance = new_stance
			return A
		else
			if(M == master || (weakref(M) in friends))
				continue
			stance = new_stance
			return A


/mob/living/simple_animal/hostile/commanded/proc/follow_target()
	stop_automated_movement = TRUE
	if(!target_mob)
		return
	if(target_mob in ListTargets(10))
		walk_to(src,target_mob,1,move_to_delay)

/mob/living/simple_animal/hostile/commanded/proc/commanded_stop() //Overrides enabling automated movement in /hostile/Life()
	stop_automated_movement = TRUE
	walk_to(src, 0)
	return

/mob/living/simple_animal/hostile/commanded/proc/listen(mob/speaker, text)
	for(var/command in known_commands)
		if(findtext(text,command))
			switch(command)
				if("stay")
					if(stay_command(speaker,text)) //find a valid command? Stop. Dont try and find more.
						break
				if("stop")
					if(stop_command(speaker,text))
						break
				if("attack")
					if(attack_command(speaker,text))
						break
				if("follow")
					if(follow_command(speaker,text))
						break
				else
					misc_command(speaker,text) //for specific commands

	return TRUE

//returns a list of everybody we wanna do stuff with.
/mob/living/simple_animal/hostile/commanded/proc/get_targets_by_name(text, filter_friendlies = 0)
	var/list/possible_targets = hearers(src,10)
	. = list()
	for(var/mob/M in possible_targets)
		if(filter_friendlies && ((weakref(M) in friends) || M.faction == faction || M == master))
			continue
		var/found = FALSE
		if(findtext(text, "[M]"))
			found = TRUE
		else
			var/list/parsed_name = splittext(replace_characters(lowertext(html_decode("[M]")),list("-"=" ", "."=" ", "," = " ", "'" = " ")), " ") //this big MESS is basically 'turn this into words, no punctuation, lowercase so we can check first name/last name/etc'
			for(var/a in parsed_name)
				if(a == "the" || length(a) < 2) //get rid of shit words.
					continue
				if(findtext(text,"[a]"))
					found = TRUE
					break
		if(found)
			. += M


/mob/living/simple_animal/hostile/commanded/proc/attack_command(mob/speaker,text,mob/target = null)
	set_target_mob(null) //want me to attack something? Well I better forget my old target.
	walk_to(src, 0)
	stance = HOSTILE_STANCE_IDLE
	if(target)
		if(!(target in allowed_targets))
			allowed_targets += target
		set_target_mob(target)
	else if(findtext(text,"everyone") || findtext(text,"anybody") || findtext(text, "somebody") || findtext(text, "someone")) //if its just 'attack' then just attack anybody, same for if they say 'everyone', somebody, anybody. Assuming non-pickiness.
		allowed_targets = list("everyone")//everyone? EVERYONE
		return TRUE
	else
		var/list/targets = get_targets_by_name(text)
		allowed_targets += targets
		return targets.len != 0

/mob/living/simple_animal/hostile/commanded/proc/stay_command(mob/speaker,text)
	set_target_mob(null)
	stance = COMMANDED_STOP
	stop_automated_movement = TRUE
	walk_to(src, 0)
	return 1

/mob/living/simple_animal/hostile/commanded/proc/stop_command(mob/speaker,text)
	allowed_targets = list()
	walk_to(src, 0)
	set_target_mob(null) //gotta stop SOMETHIN
	stance = HOSTILE_STANCE_IDLE
	stop_automated_movement = FALSE
	return TRUE

/mob/living/simple_animal/hostile/commanded/proc/follow_command(mob/speaker,text,mob/target = null)
	var/mob/to_follow = null
	if(!target)
		//we can assume 'stop following' is handled by stop_command
		if(findtext(text,"me"))
			stance = COMMANDED_FOLLOW
			set_target_mob(speaker) //this wont bite me in the ass later.
			return 1
		var/list/targets = get_targets_by_name(text)
		if(targets.len > 1 || !targets.len) //CONFUSED. WHO DO I FOLLOW?
			return 0
		to_follow = targets[1]
	else
		to_follow = target

	stance = COMMANDED_FOLLOW //GOT SOMEBODY. BETTER FOLLOW EM.
	set_target_mob(to_follow) //YEAH GOOD IDEA

	return TRUE

/mob/living/simple_animal/hostile/commanded/proc/misc_command(mob/speaker,text)
	return FALSE


/mob/living/simple_animal/hostile/commanded/hit_with_weapon(obj/item/O, mob/living/user, effective_force, hit_zone)
	//if they attack us, we want to kill them. None of that "you weren't given a command so free kill" bullshit.
	. = ..()
	if(!. && retribution)
		stance = HOSTILE_STANCE_ATTACK
		set_target_mob(user)
		allowed_targets += user //fuck this guy in particular.
		if(weakref(user) in friends) //We were buds :'(
			friends -= weakref(user)


/mob/living/simple_animal/hostile/commanded/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(M.a_intent == I_HURT && retribution && !client) //assume he wants to hurt us.
		set_target_mob(M)
		allowed_targets += M
		stance = HOSTILE_STANCE_ATTACK
		if(weakref(M) in friends)
			friends -= weakref(M)

/mob/living/simple_animal/hostile/commanded/CtrlShiftClick(mob/user)
	if(user.stat || !isliving(user)|| user.is_muzzled() || !(user==master))
		return

	radial_click(user)

/mob/living/simple_animal/hostile/commanded/proc/radial_click(mob/living/M)
	if(!radial_choices.len)
		radial_choices = collect_radial_choices()

	var/command = show_radial_menu(M, src,  radial_choices, require_near = FALSE)
	on_radial_click(M, command)

/mob/living/simple_animal/hostile/commanded/proc/on_radial_click(mob/living/carbon/human/M, command)
	var/mob/target = null

	switch(command)
		if("stay")
			stay_command(M,"stay")
		if("stop")
			stop_command(M,"stop")
		if("attack")
			var/list/possible_targets = radial_targets(M, FALSE)
			possible_targets += "everyone"
			target = input(M, "Choose whom to attack.", "Targeting") as null|anything in possible_targets
			if(!target)
				return FALSE
			if(target == "everyone")
				attack_command(M, "attack everyone")
			else
				attack_command(M, null, target)
		if("follow")
			target = input(M, "Choose whom to follow.", "Targeting") as null|anything in radial_targets(M, TRUE)
			if(!target)
				return FALSE
			follow_command(M, null, target)
		else
			return command

	if(prob(50))
		M.whisper("whispers something.")

	return command



/mob/living/simple_animal/hostile/commanded/proc/radial_targets(mob/commander = null, include_user = FALSE)
	var/list/possible_targets = list()

	for(var/atom/A in ListTargets())
		var/mob/M
		if(A == src)
			continue
		if(isliving(A))
			M = A
		else if(istype(A,/obj/mecha))
			var/obj/mecha/mecha = A
			if(!mecha.occupant)
				continue
			M = mecha.occupant
		else
			continue
		if(!include_user && M == commander)
			continue
		possible_targets += M

	return possible_targets

/mob/living/simple_animal/hostile/commanded/proc/collect_radial_choices()
	var/list/choices = list()

	for(var/C in known_commands)
		choices[C] = C

	return choices
