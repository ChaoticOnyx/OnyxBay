/mob/living/simple_animal/hostile/commanded/skull_protector
	name = "Skull-protector"
	desc = "A collection of skulls."
	stance = HOSTILE_STANCE_ALERT

	icon_state = "skull"
	icon_living = "skull"

	health = 300
	maxHealth = 300

	density = 1

	attacktext = "swatted"
	melee_damage_lower = 10
	melee_damage_upper = 10
	can_escape = 1

	max_gas = list("plasma" = 2, "carbon_dioxide" = 5)

	response_help = "pets"
	response_harm = "hits"
	response_disarm = "pushes"
	bodyparts = /decl/simple_animal_bodyparts/skull_protector

	known_commands = list("stay", "stop", "attack", "follow", "guard")

/decl/simple_animal_bodyparts/skull_protector
	hit_zones = list("body", "carapace", "right manipulator", "left manipulator", "upper left appendage", "upper right appendage", "eye")

/mob/living/simple_animal/hostile/commanded/skull_protector/_examine_text(mob/user)
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
		if(COMMANDED_STOP)
			. += SPAN("warning", "[src] stays patiently, waiting for its master!")
	return

/mob/living/simple_animal/hostile/commanded/skull_protector/on_radial_click(mob/living/carbon/human/M, command)
	. = ..()

	if(!.)
		return

	switch(command)
		if("guard")
			stance = COMMANDED_MISC

/mob/living/simple_animal/hostile/commanded/skull_protector/misc_command(mob/speaker, text)
	for(var/command in known_commands)
		if(findtext(text, command))
			switch(command)
				if("guard")
					stance = COMMANDED_MISC

/mob/living/simple_animal/hostile/commanded/skull_protector/Life()
	if(!master)
		return

	if(stance == COMMANDED_MISC)
		stop_automated_movement = TRUE
		if(master.last_attacker_)
			revenge_attack(master.last_attacker_)
		else
			set_target_mob(master)
			Goto(master, move_to_delay, minimum_distance)
	return ..()

/mob/living/simple_animal/hostile/commanded/skull_protector/proc/revenge_attack(datum/mob_lite/master_attacker)
	for(var/mob/living/attacker in GLOB.living_mob_list_)
		if(attacker.name != master_attacker.name)
			continue

		src.ReplaceMovementHandler(/datum/movement_handler/mob/incorporeal) // COMING FOR YA NIGGER
		set_target_mob(attacker)

/mob/living/simple_animal/hostile/commanded/skull_protector/set_target_mob(mob/living/L)
	if(target_mob != L)
		if(target_mob)
			unregister_signal(target_mob, SIGNAL_QDELETING)
		target_mob = L
		if(!QDELETED(target_mob) && !client)
			register_signal(target_mob, SIGNAL_QDELETING, .proc/_target_deleted)
	if(target_mob)
		Aggro()
		if(target_mob != master)
			stance = HOSTILE_STANCE_ATTACK

/mob/living/simple_animal/hostile/commanded/skull_protector/AttackingTarget()
	if(!Adjacent(target_mob))
		return

	var/hit_zone = ran_zone()
	target_mob.stun_effect_act(rand(2,5), rand(10, 90), hit_zone, src)
	var/turf/location = get_turf(loc)
	ASSERT(location)
	explosion(location, -1, -1, 0, 4)
	qdel_self()
