SUBSYSTEM_DEF(arena)
	name = "Arena"
	priority = SS_PRIORITY_ARENA
	flags = SS_BACKGROUND
	wait = 1 SECOND

	var/arena_state = ARENA_STATE_DISABLED

	var/list/players = list()
	var/list/security_players = list()
	var/list/greytide_players = list()

	var/datum/ghost_arena_gamemode/gamemode = null // Current gamemode (CTF/FFA/DE)
	var/map = null // Current map
	var/ghost_arena_centerX
	var/ghost_arena_centerY
	var/ghost_arena_centerZ

	var/list/ghost_arena_turfs = list() // List of turfs that will be cleaned on roundend
	var/list/cleanable_items = list(/obj/item/ammo_magazine, /obj/effect/decal/cleanable, /obj/item/ammo_casing, /obj/item/gun, /obj/item/storage, /obj/item/clothing, /mob/living) // Items that will NOT be deleted on clean()

	var/list/ghost_arena_items = list()
	var/list/ghost_arena_gamemodes = list()

	var/list/ghost_arena_spawns= list()
	var/list/ghost_arena_spawns_sec = list()
	var/list/ghost_arena_spawns_grey = list()

	var/list/gamemode_votes = list()
	var/list/map_votes = list()
	var/boot_start_time = 0

	var/list/categories = list(/datum/ghost_arena_item/pistol,
								/datum/ghost_arena_item/heavy,
								/datum/ghost_arena_item/melee,
								/datum/ghost_arena_item/utility,
								/datum/ghost_arena_item/armor
							)
	var/list/pistols = list()
	var/list/rifles = list()
	var/list/melee = list()
	var/list/utilities = list()
	var/list/armors = list()

	var/sound/t_win = 'sound/ghost_arena/t_win.ogg'
	var/sound/ct_win = 'sound/ghost_arena/ct_win.ogg'
	var/sound/draw = 'sound/ghost_arena/rounddraw.ogg'
	var/list/sound/roundstart = list('sound/ghost_arena/ct_inpos.ogg', 'sound/ghost_arena/locknload.ogg', 'sound/ghost_arena/letsgo.ogg', 'sound/ghost_arena/ok.ogg', )

/datum/controller/subsystem/arena/Initialize()
	. = ..()

	ghost_arena_items = get_ghost_arena_items()

/datum/controller/subsystem/arena/fire()
	if(arena_state != ARENA_STATE_BOOT)
		suspend()
		can_fire = FALSE
		return

	if(boot_start_time + ARENA_BOOT_DURATION <= world.time)
		boot_end()
		suspend()
		can_fire = FALSE
		return

	tgui_update()

/datum/controller/subsystem/arena/proc/get_ghost_arena_items()
	for(var/category in categories)
		var/datum/ghost_arena_item/instance = new category()
		categories -= category
		categories += instance
		categories[instance] = image(instance.icon, instance.icon_state)

		for(var/item in subtypesof(instance))
			var/datum/ghost_arena_item/I = new item()
			if(!I.item_path)
				continue

			var/image/image = image(I.icon, I.icon_state)
			image.maptext = MAPTEXT(I.price)

			switch(instance.type)
				if(/datum/ghost_arena_item/pistol)
					pistols += I
					pistols[I] = image
				if(/datum/ghost_arena_item/heavy)
					rifles += I
					rifles[I] = image
				if(/datum/ghost_arena_item/melee)
					melee += I
					melee[I] = image
				if(/datum/ghost_arena_item/utility)
					utilities += I
					utilities[I] = image
				if(/datum/ghost_arena_item/armor)
					armors += I
					armors[I] = image

/datum/controller/subsystem/arena/proc/get_ghost_arena_gamemodes()
	if(ghost_arena_gamemodes.len)
		return ghost_arena_gamemodes

	for(var/gamemode in subtypesof(/datum/ghost_arena_gamemode))
		var/datum/ghost_arena_gamemode/G = new gamemode()
		ghost_arena_gamemodes += G

	return ghost_arena_gamemodes

/datum/controller/subsystem/arena/proc/load_map(map)
	var/datum/map_template/template = SSmapping.ghost_arena_templates[map]
	ASSERT(template)

	//var/obj/effect/landmark/ghost_arena_center/center = pick(SSarena.ghost_arena_center)
	//ASSERT(center)

	var/turf/T = locate(ghost_arena_centerX, ghost_arena_centerY, ghost_arena_centerZ)
	ASSERT(T)

	if(template.load(T, centered = TRUE, clear_contents = TRUE))
		return template.name

	else
		CRASH("Ghost arena failed loading map. Contact coders.")

/datum/controller/subsystem/arena/proc/toggle()
	if(arena_state == ARENA_STATE_DISABLED) // Starting up
		arena_state = ARENA_STATE_ENABLED
	else // Disabling
		arena_state = ARENA_STATE_DISABLED
		arena_shutdown()

/datum/controller/subsystem/arena/proc/arena_shutdown()
	for(var/client/player in players)
		remove_player(player)

/datum/controller/subsystem/arena/proc/boot_start() //Start of boot phase, players can vote for next map&gamemode
	can_fire = TRUE
	wake()
	arena_state = ARENA_STATE_BOOT
	boot_start_time = world.time

	for(var/datum/ghost_arena_gamemode/G in get_ghost_arena_gamemodes())
		gamemode_votes += G.name

	for(var/map in SSmapping.ghost_arena_templates)
		map_votes += map

	for(var/client/player in players)
		tgui_interact(player.mob)

/datum/controller/subsystem/arena/proc/boot_end() //End of boot phase, checking results
	var/chosen_gamemode = poll(gamemode_votes)
	var/chosen_map = poll(map_votes)

	if(chosen_map == map) // No, we won't load the same map twice
		clean_turfs()
	else
		map = load_map(poll(map_votes))

	for(var/datum/ghost_arena_gamemode/G in get_ghost_arena_gamemodes())
		//if(players.len == 1 && istype(G, /datum/ghost_arena_gamemode/ffa))
		//	gamemode = G
		//	break

		if(G.name == chosen_gamemode) //&/& players.len > 1)
			gamemode = G
			break

	for(var/client/player in players)
		var/datum/ghost_arena_player/P = players[player]
		if(isnull(P))
			continue

		P.map_voted = FALSE
		P.gamemode_voted = FALSE

	start_game()

	QDEL_LIST(gamemode_votes)
	QDEL_LIST(map_votes)

/datum/controller/subsystem/arena/proc/poll(list/votes)
	var/list/winners = list()
	var/highest_vote = 0
	for(var/choice in votes)
		var/vote_count = votes[choice]
		if(!length(winners))
			if(vote_count > 0)
				winners += choice
				highest_vote = vote_count
			continue
		if(vote_count > highest_vote)
			winners.Cut()
			winners += choice
			highest_vote = vote_count
		else if(vote_count == highest_vote)
			winners += choice
	if(!winners.len)
		return pick(votes)
	else if(winners.len > 1)
		return pick(winners)
	else
		return winners[1]

/datum/controller/subsystem/arena/proc/on_player_join(client/player)
	if(arena_state == ARENA_STATE_ENABLED) // Enabled but not running, starting up for the first time.
		boot_start()
	else if(arena_state == ARENA_STATE_BOOT)
		tgui_interact(player.mob)
	else if (arena_state == ARENA_STATE_RUNNING)
		gamemode.on_player_join()

/datum/controller/subsystem/arena/proc/start_game() //To start game
	reset_datums()
	arena_state = ARENA_STATE_RUNNING
	gamemode.start_game()

/datum/controller/subsystem/arena/proc/reset_datums()
	for(var/player in players)
		players[player] = new /datum/ghost_arena_player()

/datum/controller/subsystem/arena/proc/end_game() //To end game
	boot_start()

/datum/controller/subsystem/arena/proc/shuffle_players()
	var/player_count = round(players.len)

	var/list/players_ = players.Copy()

	security_players = clearlist(security_players)
	greytide_players = clearlist(greytide_players)
	security_players = new()
	greytide_players = new()

	for(var/i = 1 to player_count)
		if((i % 2) == 0)
			security_players.Add(pick_n_take(players_))
		else
			greytide_players.Add(pick_n_take(players_))

/// Handles adding player.
/datum/controller/subsystem/arena/proc/add_player(client/owner, team_name)
	if(!owner || !team_name)
		return FALSE

	if(owner in players)
		to_chat(owner, SPAN_DANGER("You can't enter ghost arena twice!"))
		return

	switch(team_name)
		if("FFA")
			players.Add(owner)
			players[owner] = new /datum/ghost_arena_player()
			on_player_join(owner)
		if("Security")
			if(security_players <= greytide_players)
				players |= owner
				players[owner] = new /datum/ghost_arena_player()
				security_players |= owner
				on_player_join(owner)
			else
				to_chat(owner, SPAN_WARNING("[team_name] is full!"))
				return FALSE

		if("Greytide")
			if(greytide_players <= security_players)
				players |= owner
				players[owner] = new /datum/ghost_arena_player()
				greytide_players |= owner
				on_player_join(owner)
			else
				to_chat(owner, SPAN_WARNING("[team_name] is full!"))
				return FALSE

// Removes player from arena
/datum/controller/subsystem/arena/proc/remove_player(client/player)
	if(!player)
		return FALSE

	if(player in security_players)
		security_players -= player
	else if(player in greytide_players)
		greytide_players -= player

	players.Remove(player)
	player.mob.ghostize()
	player.mob.death()

/datum/controller/subsystem/arena/proc/create_body(client/player, list/spawns, should_freeze = FALSE)
	if(arena_state != ARENA_STATE_RUNNING)
		return

	if(player in players)
		var/obj/effect/landmark/ghost_arena_spawn/spawnpoint = pick(spawns)

		var/mob/living/carbon/human/arenahuman/body = new /mob/living/carbon/human/arenahuman(spawnpoint.loc)
		body.key = player.key
		body.name = player.key
		body.real_name = player.key
		if(should_freeze)
			body.status_flags ^= GODMODE
			body.anchored = TRUE

		return body

/datum/controller/subsystem/arena/proc/clean_turfs()
	for(var/turf/T in ghost_arena_turfs)
		if(!isturf(T))
			continue

		for(var/atom/A in T.contents)
			if(isliving(A))
				var/mob/living/my_mob = A
				if(!my_mob.is_ic_dead())
					continue

			if(is_type_in_list(A, cleanable_items))
				qdel(A)

/datum/controller/subsystem/arena/proc/change_player_money(client/player, value)
	var/datum/ghost_arena_player/player_datum = players[player]
	if(!player_datum)
		return

	player_datum.money += value
	to_chat(player, SPAN_WARNING("+[value]$!"))

/datum/controller/subsystem/arena/proc/change_money(list/players_list, value)
	for(var/player in players_list)
		var/datum/ghost_arena_player/player_datum = players[player]
		if(!istype(player_datum))
			continue

		player_datum.money += value
		to_chat(player, SPAN_WARNING("+[value]$!"))

/datum/controller/subsystem/arena/proc/get_best_player()
	var/highest_kills = 0
	var/deaths = 0
	var/best_killer = null
	for(var/player in players)
		var/datum/ghost_arena_player/player_datum = players[player]
		if(player_datum.kills == 0)
			continue

		if(player_datum.kills > highest_kills || (player_datum.kills == highest_kills && player_datum.deaths < deaths))
			best_killer = player
			highest_kills = player_datum.kills
			highest_kills = player_datum.deaths

	if(isnull(best_killer))
		return

	return ("[best_killer] had most kills this game!")

/datum/controller/subsystem/arena/proc/get_winner()
	if(!istype(gamemode, /datum/ghost_arena_gamemode/coop))
		return get_best_player()

	else
		var/datum/ghost_arena_gamemode/coop/game = gamemode
		if(game.grey_score > game.sec_score)
			return "Greytide wins!"

		else if(game.sec_score > game.grey_score)
			return "Shitcurity wins!"

		else
			return "Draw!"

/datum/controller/subsystem/arena/proc/play_sound(list/players2play, sound)
	var/roundstart_sound = pick(roundstart)
	for(var/client/player in players2play)
		if(!player.mob)
			return

		switch(sound)
			if("ct_win")
				player.mob.playsound_local(get_turf(player.mob), ct_win, 75)
			if("t_win")
				player.mob.playsound_local(get_turf(player.mob), t_win, 75)
			if("draw")
				player.mob.playsound_local(get_turf(player.mob), draw, 75)
			if("roundstart")
				player.mob.playsound_local(get_turf(player.mob), roundstart_sound, 75)

/datum/controller/subsystem/arena/tgui_state()
	return GLOB.tgui_always_state

/datum/controller/subsystem/arena/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GhostArenaEndround")
		ui.open()

/datum/controller/subsystem/arena/tgui_data(mob/user)
	var/list/data = list()

	for(var/client/player in players)
		var/list/player_data = list()
		var/datum/ghost_arena_player/player_datum = players[player]
		if(isnull(player_datum))
			continue

		player_data["name"] = player.key
		player_data["kills"] = player_datum.kills
		player_data["deaths"] = player_datum.deaths
		if(player in security_players)
			player_data["color"] = "red"
		else if(player in greytide_players)
			player_data["color"] = "grey"
		else
			player_data["color"] = "green"
		data["players"] += list(player_data)

	var/list/gamemodes = list()
	for(var/datum/ghost_arena_gamemode/G in get_ghost_arena_gamemodes())
		gamemodes += G.name
	data["gamemodeVote"] += gamemodes

	var/list/maps = list()
	for(var/map in SSmapping.ghost_arena_templates)
		maps += map

	data["mapVote"] += maps

	if(arena_state != ARENA_STATE_RUNNING)
		data["timeRemaining"] = round((boot_start_time - world.time + ARENA_BOOT_DURATION)/10)
	else
		data["timeRemaining"] = round((gamemode.round_start_time + gamemode.round_duration - world.time)/10)

	data["winner"] = get_winner()

	if(arena_state != ARENA_STATE_RUNNING)
		data["roundend"] = TRUE
	else
		data["roundend"] = FALSE

	return data

/datum/controller/subsystem/arena/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/ghost_arena_player/player

	for(var/client/C in players)
		if(C != usr.client)
			continue
		player = SSarena.players[C]

	switch(action)
		if("gamemode_vote")
			if(player.gamemode_voted)
				return

			var/gamemode = params["gamemode"]
			gamemode_votes[gamemode] += 1
			player.gamemode_voted = TRUE

		if("map_vote")
			if(player.map_voted)
				return

			var/map = params["map_name"]
			map_votes[map] += 1
			player.map_voted = TRUE
