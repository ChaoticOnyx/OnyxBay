/datum/ghost_arena_gamemode
	var/name = "Gamemode"
	var/gamemode_stage = GA_GAMEMODE_ROUNDSTART
	var/round_start_time = 0
	var/round_duration = 0
	var/max_rounds = 6
	var/round_counter = 0
	var/score = 0
	var/respawn_delay = ARENA_RESPAWN_DELAY
	var/freezetime = ARENA_FREEZETIME_DEFAULT
	var/greet_text = "Winner winner chicken dinner!!"

/datum/ghost_arena_gamemode/proc/can_buy(mob/user)
	return TRUE

/datum/ghost_arena_gamemode/proc/check_round_completion(result)
	end_round(result)

/datum/ghost_arena_gamemode/proc/start_game()
	round_counter = 0

	gamemode_stage = GA_GAMEMODE_ROUNDSTART

	if(freezetime != 0)
		gamemode_stage = GA_GAMEMODE_FREEZETIME

	start_round()
	greet_players()

/datum/ghost_arena_gamemode/proc/greet_players()
	for(var/client/player in SSarena.players)
		greet_player(player)

/datum/ghost_arena_gamemode/proc/greet_player(client/player)
	to_chat(player, SPAN_INFO("<B>Current gamemode is [name].</B>"))
	to_chat(player, SPAN_INFO("</B>[greet_text]</B>"))

/datum/ghost_arena_gamemode/proc/end_game() //To end game
	SSarena.end_game()

/datum/ghost_arena_gamemode/proc/start_round()
	spawn_players()
	SSarena.play_sound(SSarena.players)
	round_start_time = world.time
	if(freezetime == 0)
		gamemode_stage = GA_GAMEMODE_RUNNING
		set_next_think(round_start_time + round_duration)
	else
		gamemode_stage = GA_GAMEMODE_FREEZETIME
		set_next_think(round_start_time + freezetime) // God is dead

	SSarena.play_sound(SSarena.players, "roundstart")

/datum/ghost_arena_gamemode/think() // Gott ist tot, ich hab ihm umgebracht
	switch(gamemode_stage)
		if(GA_GAMEMODE_ROUNDSTART)
			return
		if(GA_GAMEMODE_FREEZETIME)
			end_freezetime()
		if(GA_GAMEMODE_RUNNING)
			check_round_completion()
		if(GA_GAMEMODE_POSTROUND)
			postend()

/datum/ghost_arena_gamemode/proc/end_freezetime()
	gamemode_stage = GA_GAMEMODE_RUNNING
	set_next_think(round_start_time + round_duration)

	for(var/client/player in SSarena.players)
		if(!isarenamob(player.mob))
			continue

		player.mob.status_flags ^= GODMODE
		player.mob.anchored = FALSE

/datum/ghost_arena_gamemode/proc/end_round(result)
	gamemode_stage = GA_GAMEMODE_POSTROUND
	set_next_think(world.time + freezetime)

/datum/ghost_arena_gamemode/proc/postend()
	round_counter += 1
	if(round_counter >= max_rounds)
		end_game()
	else
		SSarena.clean_turfs()
		start_round()

/datum/ghost_arena_gamemode/proc/on_player_join(client/player)
	SSarena.change_money(player, GA_FFA_MONEY_START)
	SSarena.create_body(player, SSarena.ghost_arena_spawns, gamemode_stage)

/datum/ghost_arena_gamemode/proc/on_death(client/player)
	check_mid_round_completion()
	return

/datum/ghost_arena_gamemode/proc/check_mid_round_completion()
	return FALSE

/datum/ghost_arena_gamemode/proc/spawn_players()
	if(!SSarena.ghost_arena_spawns)
		to_chat(usr, SPAN_WARNING("No spawn points are available. Something went wrong. Contact coders, for fuck's sake."))
		return

	for(var/client/player in SSarena.players)
		SSarena.create_body(player, SSarena.ghost_arena_spawns, gamemode_stage)

///Handles post-spawn (equips mob e.t.c.) in case it should be gamemode-specific
/datum/ghost_arena_gamemode/proc/handle_post_spawn(mob/living/carbon/human/arenahuman/my_mob)
	generate_random_body(my_mob)
	equip_mob(my_mob)
	give_spawn_protection(my_mob)

/datum/ghost_arena_gamemode/proc/generate_random_body(mob/living/carbon/human/arenahuman/my_mob)
	my_mob.gender = pick(MALE, FEMALE)
	my_mob.randomize_skin_color()

/datum/ghost_arena_gamemode/proc/equip_mob(mob/living/carbon/human/arenahuman/my_mob)
	my_mob.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(src), slot_w_uniform)
	my_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(src), slot_shoes)
	my_mob.equip_to_slot_or_del(new /obj/item/clothing/gloves/thick/swat(src), slot_gloves)
	my_mob.equip_to_slot_or_del(new /obj/item/storage/backpack/security(src), slot_back)
	my_mob.equip_to_slot_or_del(new /obj/item/storage/belt/military(src), slot_belt)

/datum/ghost_arena_gamemode/proc/give_spawn_protection(mob/living/carbon/human/arenahuman/my_mob)
	//status_flags ^= GODMODE
	//alpha = 127
	//animate(src, alpha = 255, time = SPAWN_PROTECTION_TIME, flags = ANIMATION_PARALLEL)
	//addtimer(CALLBACK(src, .proc/lift_spawn_protection), SPAWN_PROTECTION_TIME)

/datum/ghost_arena_gamemode/proc/lift_spawn_protection()
	//status_flags ^= GODMODE
	//revive()
	//to_chat(src, SPAN_DANGER("You are respawned!"))
