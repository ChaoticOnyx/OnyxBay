/datum/controller/gameticker/var/mob/target = null

/datum/game_mode/restructuring/var/finished = 0

/datum/game_mode/restructuring
	name = "Corporate Restructuring"
	config_tag = "restructuring"
	votable = 0

/datum/game_mode/restructuring/announce()
	..()
	world << "\red <B>GLOBAL TRANSMISSION FROM HEAD OFFICE: A CORPORATE RESTRUCTURING IS TO TAKE PLACE</B>"
	world << "\red <B>Stay tuned for further news; note that we do care for our employees and any layoffs will be dealt with discretion and compassion</B>"


/datum/game_mode/restructuring/post_setup()
	var/list/mobs = get_mob_list()
	while (mobs.len == 0)
		sleep(30*tick_multiplier)
		mobs = get_mob_list()
	spawn (120*tick_multiplier)
		pick_target()

/datum/game_mode/restructuring/proc/pick_target(who)
	var/mob/target
	var/mob/target_desc

	if (!who)
		target = pick(get_mob_list())
		target_desc = get_target_desc(target)
	else
		target = who
		target_desc = get_target_desc(target)
	world << "\red <B>HEAD OFFICE: [target_desc] is accused of attempting to start a Union and is now considered a threat to the station. Terminate the employee immediately.</b>"
	ticker.target = target

	target.store_memory("Head office has ordered your downsizing. Watch out!", 0)

	for(var/mob/living/silicon/ai/M in world)
		M.set_zeroth_law("[target_desc] is not human.")
		if(M.client)
			M << "These are your laws now:"
			M.show_laws()

/datum/game_mode/restructuring/check_finished()
	. = ..()
	if (finished)
		return 1
	return

/datum/game_mode/restructuring/check_win()
	var/list/left_alive = get_mob_list()
	if (left_alive.len == 1)
		var/thewinner = the_winner()
		world << "\red <B>HEAD OFFICE: Thanks to his superior brown-nosing abilities, [thewinner] has been promoted to senior management! Congratulations!"
		finished = 1
		return 1
	else if (left_alive.len == 0)
		world << "\red <B>HEAD OFFICE: Cost cutting measures have achieved 100% efficiency. Thank you for understanding our position during this volatile economic downturn."
		finished = 1
		return 1
	else
		if(ticker.target.stat != 2)
			return 0
		world << "\red <B>HEAD OFFICE: It seems we have made a mistake in our paperwork. The previous target for termination was chosen based on race, sex, and/or religious beliefs, which is against company policy. Please cancel previous termination request."
		pick_target()
		return 0

/datum/game_mode/restructuring/proc/get_mob_list()
	var/list/mobs = list()
	for(var/client/C)
		if (C.mob.stat<2 && istype(C.mob, /mob/living/carbon/human))
			mobs += C.mob
	return mobs

/datum/game_mode/restructuring/proc/the_winner()
	for(var/client/C)
		if (C.mob.stat < 2 && istype(C.mob, /mob/living/carbon/human))
			return C.mob.name

/datum/game_mode/restructuring/proc/get_target_desc(mob/target) //return a useful string describing the target
	var/targetrank = null
	for(var/datum/data/record/R in data_core.general)
		if (R.fields["name"] == target.real_name)
			targetrank = R.fields["rank"]
	if(!targetrank)
		return "[target.name]"
	return "[target.name] the [targetrank]"