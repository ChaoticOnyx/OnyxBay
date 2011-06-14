// blahblah

/datum/game_mode/hostile
	name = "hostile takeover"
	config_tag = "takeover"
	enabled = 1

	var/agents_possible = 0

	var/list/datum/mind/syndicates = list()
	var/finished = 0
	var/list/hostile_spawns = list()
	var/list/crew_spawns = list()

/datum/game_mode/hostile/announce()
	world << "<B>The current game mode is - Hostile Takeover!</B>"
//	world << "<B>A [syndicate_name()] Strike Force is approaching [station_name()]!</B>"
//	world << "A nuclear explosive was being transported by NanoTrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It was identified by NanoTrasen as a nuclear auth. disk and now Syndicate Operatives have arrived to retake the disk and detonate NSV Luna! Also, most likely Syndicate star ships are in the vicinity so take care not to lose the disk!\n<B>Syndicate</B>: Reclaim the disk and detonate the nuclear bomb anywhere on Luna.\n<B>Personnel</B>: Hold the disk and <B>escape with the disk</B> on the shuttle!"


/datum/game_mode/hostile/pre_setup()
	agents_possible = round( get_player_count()/2.7 )
	if(agents_possible < 1)
		agents_possible = 1

	var/list/possible_syndicates = get_possible_syndicates()
	var/agent_number = 0

	if(possible_syndicates.len < 1)
		return 0

	if(possible_syndicates.len > agents_possible)
		agent_number = agents_possible
	else
		agent_number = possible_syndicates.len

	while(agent_number > 0)
		var/datum/mind/new_syndicate = pick(possible_syndicates)
		syndicates += new_syndicate
		possible_syndicates -= new_syndicate //So it doesn't pick the same guy each time.
		agent_number--

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = "MODE" //So they aren't chosen for other jobs.

	uplink_uses = (syndicates.len*10)

	return 1


/datum/game_mode/hostile/post_setup()
	for(var/obj/landmark/hostile_spawn/S in world)
		hostile_spawns += S.loc
		del(S)

	for(var/obj/landmark/crew_spawn/D in world)
		crew_spawns += D.loc
		del(D)

	var/radio_freq = random_radio_frequency()

	var/datum/disease2/disease/D = new()
	D.makerandom(1)
	D.infectionchance = 0

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.current.loc = pick(hostile_spawns)
		hostile_spawns -= synd_mind.current.loc

		equip_hostile(synd_mind.current, radio_freq)
		if(istype(synd_mind.current, /mob/living/carbon/human))
			synd_mind.current:virus2 = D.getcopy()

		synd_mind.current << "<b>* You have taken control of the NSV Luna and taken the crew as hostages. However, you do not know how to run this ship or about chemistry and virology, and you have a lethal virus that needs to be treated with spaceaillin or cured."

	var/free = max(round(syndicates.len / 5), 1)
	for(var/mob/living/carbon/human/player in world)
		if(player.mind in syndicates) continue
		player << "<b>* Your ship has been taken over by a hostile corporation. They overpower you, but you must somehow overthrow them through wit and cunning."
		if(free <= 0)
			player.loc = pick(crew_spawns)
			crew_spawns -= player.loc
		else
			player << "<b>* You're one of the ship's genetical research subjects."
			player.mutations |= 512
			if(prob(80))
				player.mutations |= 4
			else
				player.mutations |= 1
			free--

	for(var/mob/living/silicon/ai/S in world)
		S.add_supplied_law(10, "The original crew of the NSV Luna are not your true masters. Aid your new masters, the members of the syndicate taskforce. This law overrides all other laws.")


	return

obj/landmark/hostile_spawn
	name = "Hostile-Spawn"
obj/landmark/crew_spawn
	name = "Crew-Prison"

/datum/game_mode/hostile/proc/equip_hostile(mob/living/carbon/human/synd_mob, radio_freq)

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset(synd_mob)
	R.set_frequency(radio_freq)
	synd_mob.equip_if_possible(R, synd_mob.slot_ears)

	synd_mob.equip_if_possible(new /obj/item/clothing/under/syndicate(synd_mob), synd_mob.slot_w_uniform)
	synd_mob.equip_if_possible(new /obj/item/clothing/shoes/black(synd_mob), synd_mob.slot_shoes)
	synd_mob.equip_if_possible(new /obj/item/clothing/suit/armor/vest(synd_mob), synd_mob.slot_wear_suit)
	synd_mob.equip_if_possible(new /obj/item/clothing/gloves/swat(synd_mob), synd_mob.slot_gloves)
	synd_mob.equip_if_possible(new /obj/item/clothing/head/helmet/swat(synd_mob), synd_mob.slot_head)

	synd_mob.equip_if_possible(new /obj/item/weapon/storage/backpack(synd_mob), synd_mob.slot_back)
	synd_mob.equip_if_possible(new /obj/item/weapon/reagent_containers/pill/tox(synd_mob), synd_mob.slot_in_backpack)
	synd_mob.equip_if_possible(new /obj/item/weapon/handcuffs(synd_mob), synd_mob.slot_in_backpack)
	synd_mob.equip_if_possible(new /obj/item/weapon/gun/energy/general(synd_mob), synd_mob.slot_in_backpack)
	synd_mob.equip_if_possible(new /obj/item/weapon/gun/revolver(synd_mob), synd_mob.slot_in_backpack)
	synd_mob.equip_if_possible(new /obj/item/weapon/baton(synd_mob), synd_mob.slot_in_backpack)

	synd_mob.update_clothing()

/datum/game_mode/hostile/check_win()
/*	if (src.nuke_detonated)
		finished = 1
		return

	for(var/obj/item/weapon/disk/nuclear/D in world)
		var/disk_area = get_area(D)
		if(istype(disk_area, /area/shuttle/escape/centcom))
			finished = 2
			break

	return*/

/datum/game_mode/hostile/check_finished()
/*
	if((src.finished) || (main_shuttle.location==2))
		return 1
	else
		return 0
*/

/datum/game_mode/hostile/declare_completion()
/*
	for(var/obj/item/weapon/disk/nuclear/D in world)
		var/disk_area = get_area(D)
		if(istype(disk_area, /area/shuttle/escape/centcom))
			finished = 2
			break

	switch(finished)
		if(0)
			world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
			world << "<B>[syndicate_name()] operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</B> Next time, don't lose the disk!"

		if(1)
			world << "<B>[syndicate_name()] operatives have destroyed [station_name()]!</B>"
			for(var/datum/mind/M in syndicates)
				if(!M.current)
					continue
				if(M.current.client)
					world << text("<B>[M.current.key] was [M.current.real_name]</B> [M.current.stat == 2 ? "(DEAD)" : ""]")

		if(2)
			world << "<FONT size = 3><B>The Research Staff has stopped the [syndicate_name()] Operatives!</B></FONT>"
			for(var/datum/mind/M in ticker.minds)
				if (!M.current)
					continue
				if ((M.current.client) && !(locate(M) in syndicates))
					world << text("<B>[M.current.key] was [M.current.real_name]</B> [M.current.stat == 2 ? "(DEAD)" : ""]")
	check_round()
	return 1
*/

/datum/game_mode/hostile/proc/get_possible_syndicates()
	var/list/candidates = list()

	for(var/mob/new_player/player in world)
		if((player.client) &&  (player.ready))
			if(player.be_syndicate)
				candidates += player.mind

	if(candidates.len < 1)
		for(var/mob/new_player/player in world)
			if((player.client) && (player.ready))
				candidates += player.mind

	if(candidates.len < 1)
		return null
	else
		return candidates

/datum/game_mode/hostile/proc/random_radio_frequency()
	var/f = 0

	do
		f = rand(1441, 1489)
		f = sanitize_frequency(f)
	while (f == 0 || f == 1459)

	return f

/datum/game_mode/hostile/proc/get_player_count()
	var/count = 0
	for(var/mob/new_player/P in world)
		if(P.ready)
			count++
	return count