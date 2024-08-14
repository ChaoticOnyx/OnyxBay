/datum/ghost_arena_menu
	var/mob/observer/ghost/owner

/datum/ghost_arena_menu/New(mob/observer/ghost/new_owner)
	if(!istype(new_owner))
		qdel(src)

	owner = new_owner

/datum/ghost_arena_menu/Destroy()
	owner = null
	return ..()

/datum/ghost_arena_menu/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/ghost_arena_menu/tgui_interact(mob/user, datum/tgui/ui)
	if(SSarena.arena_state == ARENA_STATE_DISABLED)
		to_chat(user, SPAN_NOTICE("Ghost arena is disabled."))
		return

	if(user.client in SSarena.players)
		SSarena.tgui_interact(user)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GhostArena", "Ghost Arena Menu")
		ui.open()

/datum/ghost_arena_menu/tgui_static_data(mob/user)
	var/list/data = list()

	if(SSarena.gamemode)
		data["gamemode"] = SSarena.gamemode.name
		data["round_counter"] = SSarena.gamemode.round_counter
		data["round_maxnumber"] = SSarena.gamemode.max_rounds
	else
		data["gamemode"] = "offline"

	if(SSarena.map)
		data["map_name"] = SSarena.map
	else
		data["map_name"] = "offline"

	data["teams"] = list()

	if(istype(SSarena.gamemode, /datum/ghost_arena_gamemode/ffa) || !istype(SSarena.gamemode))
		var/list/ffa_data = list()
		ffa_data["name"] = "FFA"
		ffa_data["players"] = SSarena.players.len
		data["teams"] += list(ffa_data)
	else
		var/list/sec_data = list()
		sec_data["name"] = "Security"
		sec_data["players"] = SSarena.security_players.len
		data["teams"] += list(sec_data)

		var/list/grey_data = list()
		grey_data["name"] = "Greytide"
		grey_data["players"] = SSarena.greytide_players.len
		data["teams"] += list(grey_data)

	return data

/datum/ghost_arena_menu/tgui_act(action, params, datum/tgui/ui)
	. = ..()

	if(.)
		return

	switch(action)
		if("join")
			SSarena.add_player(owner.client, params["team_name"])
			ui.close()
		if("leave")
			SSarena.remove_player(owner.client)
			ui.close()
