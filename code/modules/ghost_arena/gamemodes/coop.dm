/datum/ghost_arena_gamemode/coop/
	name = "Coop gamemode"
	round_duration = GA_ROUND_COOP_DURATION + ARENA_FREEZETIME_DEFAULT
	freezetime = ARENA_FREEZETIME_DEFAULT
	var/sec_score = 0
	var/grey_score = 0

/datum/ghost_arena_gamemode/coop/start_game()
	sec_score = 0
	grey_score = 0

	SSarena.shuffle_players()
	SSarena.change_money(SSarena.players, GA_COOP_MONEY_START)
	return ..()

/datum/ghost_arena_gamemode/coop/start_round()
	return ..()

/datum/ghost_arena_gamemode/coop/spawn_players()
	for(var/client/player in SSarena.security_players)
		if(isarenamob(player.mob) && !player.mob.is_ic_dead())
			var/obj/effect/landmark/ghost_arena_spawn/security/spawn_area = pick(SSarena.ghost_arena_spawns_sec)
			var/mob/living/carbon/human/arenahuman/player_mob = player.mob
			player_mob.revive()
			player_mob.forceMove(spawn_area.loc)
			player_mob.anchored = TRUE
			player_mob.status_flags ^= GODMODE
			continue

		var/body = SSarena.create_body(player, SSarena.ghost_arena_spawns_sec, TRUE)
		equip_sec(body)

	for(var/client/player in SSarena.greytide_players)
		if(isarenamob(player.mob) && !player.mob.is_ic_dead())
			var/obj/effect/landmark/ghost_arena_spawn/greytide/spawn_area = pick(SSarena.ghost_arena_spawns_grey)
			var/mob/living/carbon/human/arenahuman/player_mob = player.mob
			player_mob.revive()
			player_mob.forceMove(spawn_area.loc)
			player_mob.anchored = TRUE
			player_mob.status_flags ^= GODMODE
			continue

		var/body = SSarena.create_body(player, SSarena.ghost_arena_spawns_grey, TRUE)
		equip_grey(body)

/datum/ghost_arena_gamemode/coop/on_player_join(client/player)
	SSarena.change_player_money(player, GA_COOP_MONEY_START)
	to_chat(player, SPAN_DANGER("Welcome. You will be spawned next round."))
	return

/datum/ghost_arena_gamemode/coop/end_round(result)
	var/message = null
	switch(result)
		if(SECURITY_WINS)
			SSarena.change_money(SSarena.security_players, GA_COOP_WIN_MONEY)
			SSarena.change_money(SSarena.greytide_players, GA_COOP_LOOSE_MONEY)
			message = "Security wins!"
			sec_score += 1
			SSarena.play_sound(SSarena.players, "ct_win")
		if(GREYTIDE_WINS)
			SSarena.change_money(SSarena.security_players, GA_COOP_LOOSE_MONEY)
			SSarena.change_money(SSarena.greytide_players, GA_COOP_WIN_MONEY)
			message = "Greytide wins!"
			grey_score += 1
			SSarena.play_sound(SSarena.players, "t_win")
		if(GHOST_ARENA_TIE, GHOST_ARENA_TIMEOUT)
			SSarena.change_money(SSarena.security_players, GA_COOP_DRAW_MONEY)
			SSarena.change_money(SSarena.greytide_players, GA_COOP_DRAW_MONEY)
			message = "Draw!"
			SSarena.play_sound(SSarena.players, "draw")

	for(var/player in SSarena.players)
		to_chat(player, SPAN_DANGER(message))

	return ..()

/datum/ghost_arena_gamemode/coop/check_round_completion()
	var/sec_counter = 0
	var/grey_counter = 0
	for(var/client/sec in SSarena.security_players)
		if(!isarenamob(sec.mob) || sec.mob.is_ic_dead())
			continue

		sec_counter += 1

	for(var/client/grey in SSarena.greytide_players)
		if(!isarenamob(grey.mob) || grey.mob.is_ic_dead())
			continue

		grey_counter += 1

	if(sec_counter > grey_counter)
		end_round(SECURITY_WINS)
		return SECURITY_WINS

	else if(sec_counter < grey_counter)
		end_round(GREYTIDE_WINS)
		return GREYTIDE_WINS

	else
		end_round(GHOST_ARENA_TIE)
		return GHOST_ARENA_TIE

/datum/ghost_arena_gamemode/coop/check_mid_round_completion()
	var/sec_counter = 0
	var/grey_counter = 0
	for(var/client/sec in SSarena.security_players)
		if(!isarenamob(sec.mob) || sec.mob.is_ic_dead())
			continue

		sec_counter += 1

	for(var/client/grey in SSarena.greytide_players)
		if(!isarenamob(grey.mob) || grey.mob.is_ic_dead())
			continue

		grey_counter += 1

	if(grey_counter <= 0)
		end_round(SECURITY_WINS)
		return SECURITY_WINS

	else if(sec_counter <= 0)
		end_round(GREYTIDE_WINS)
		return GREYTIDE_WINS

	else if(sec_counter <= 0 && grey_counter <= 0)
		end_round(GHOST_ARENA_TIE)
		return GHOST_ARENA_TIE

/datum/ghost_arena_gamemode/coop/equip_mob(mob/living/carbon/human/arenahuman/my_mob)
	my_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(src), slot_shoes)
	my_mob.equip_to_slot_or_del(new /obj/item/storage/belt/military(src), slot_belt)

/datum/ghost_arena_gamemode/coop/proc/equip_sec(mob/living/carbon/human/arenahuman/my_mob)
	my_mob.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security/arenasec(src), slot_w_uniform)
	my_mob.equip_to_slot_or_del(new /obj/item/clothing/gloves/thick/combat(src), slot_gloves)
	my_mob.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/sec(src), slot_back)

/datum/ghost_arena_gamemode/coop/proc/equip_grey(mob/living/carbon/human/arenahuman/my_mob)
	my_mob.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(src), slot_w_uniform)
	my_mob.equip_to_slot_or_del(new /obj/item/clothing/gloves/thick/swat(src), slot_gloves)
	my_mob.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/grey(src), slot_back)

/obj/item/clothing/under/rank/security/arenasec
	armor = 0
