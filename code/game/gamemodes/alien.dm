/datum/game_mode/alien
	name = "alien"
	config_tag = "alien"
	var/const/alien_possible = 1
	var/list/datum/mind/aliens = list()
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

/datum/game_mode/alien/announce()
	world << "<B>The current game mode is - alien!</B>"
	world << "<B>There is a syndicate alien on the station. Do not let the alien succeed!!</B>"

/datum/game_mode/alien/pre_setup()
	var/list/possible_aliens = get_possible_aliens()
	aliens_allowed = 1
	var/num_players = 0
	for(var/mob/new_player/P in world)
		if(P.client && P.ready)
			num_players++

	var/i = rand(5)
	var/num_aliens = 1

	// stop setup if no possible aliens
	if(!possible_aliens.len)
		return 0

	if(traitor_scaling)
		num_aliens = max(1, min(round((num_players + i) / 10), alien_possible))

//	log_game("Number of aliens: [num_aliens]")
	message_admins("Players counted: [num_players]  Number of aliens chosen: [num_aliens]")

	for(var/j = 0, j < num_aliens, j++)
		var/datum/mind/alien = pick(possible_aliens)
		aliens += alien
		possible_aliens.Remove(alien)

	for(var/datum/mind/alien in aliens)
		if(!alien || !istype(alien))
			aliens.Remove(alien)
			continue
		if(istype(alien))
			alien.special_role = "alien"

	if(!aliens.len)
		return 0
	return 1

/datum/game_mode/alien/post_setup()
	for(var/datum/mind/alien in aliens)
		if(istype(alien.current, /mob/living/silicon))
			aliens.Remove(alien.current)
		else

			var/mob/living/carbon/alien/humanoid/queen/H = new /mob/living/carbon/alien/humanoid( alien.current.loc )
			H.toxloss = 250
			var/mob/D = alien.current.client.mob
			if(alien.current.client)
				alien.current.client.mob = H
				del D
		alien.current << "<B>You are the Alien Queen.</B>"
		alien.current << "Use your facehuggers to grow your hive."

/datum/game_mode/alien/proc/get_possible_aliens()
	var/list/candidates = list()
	for(var/mob/new_player/player in world)
		if (player.client && player.ready)
			if(player.preferences.be_syndicate)
				candidates += player.mind

	if(candidates.len < 1)
		for(var/mob/new_player/player in world)
			if (player.client && player.ready)
				candidates += player.mind
	return candidates

/datum/game_mode/alien/proc/get_mob_list()
	var/list/mobs = list()
	for(var/client/C)
		mobs += C.mob
	return mobs

/datum/game_mode/alien/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/client/C)
		if (C.mob.real_name != excluded_name)
			names += C.mob.real_name
	if(!names.len)
		return null
	return pick(names)

//	DONT COMPILE THIS!!!!!