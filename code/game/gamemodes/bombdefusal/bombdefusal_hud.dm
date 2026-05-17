// ========== BOMB DEFUSAL - HUD SCREEN OBJECTS ==========
// Layout: centered scoreboard at top, money top-right, killfeed right, announcements center

// ===== ACTION BUTTONS =====

/datum/action/innate/bombdefusal_lobby
	name = "Bomb Defusal Lobby"
	button_icon_state = "default"
	check_flags = 0

/datum/action/innate/bombdefusal_lobby/Activate()
	var/datum/game_mode/bombdefusal/mode = SSticker.mode
	if(!istype(mode) || !mode.lobby_active)
		to_chat(owner, "<span class='warning'>The lobby is not open.</span>")
		return
	mode.show_lobby_ui(owner)

/datum/action/innate/bombdefusal_lobby/IsAvailable()
	var/datum/game_mode/bombdefusal/mode = SSticker.mode
	return istype(mode) && mode.lobby_active

/datum/action/innate/bombdefusal_buy
	name = "Buy Menu"
	button_icon_state = "default"
	check_flags = 0

/datum/action/innate/bombdefusal_buy/Activate()
	var/datum/game_mode/bombdefusal/mode = SSticker.mode
	if(!istype(mode))
		return
	var/datum/bombdefusal_player_data/pd = mode.get_player_data_by_mob(owner)
	if(!pd?.match)
		return
	if(pd.match.match_state != BOMBDEFUSAL_STATE_BUY && pd.match.match_state != BOMBDEFUSAL_STATE_FREEZE)
		to_chat(owner, "<span class='warning'>Buy phase is over!</span>")
		return
	mode.show_buy_menu(owner, pd)

/datum/action/innate/bombdefusal_buy/IsAvailable()
	var/datum/game_mode/bombdefusal/mode = SSticker.mode
	if(!istype(mode))
		return FALSE
	var/datum/bombdefusal_player_data/pd = mode.get_player_data_by_mob(owner)
	if(!pd?.match)
		return FALSE
	return pd.match.match_state == BOMBDEFUSAL_STATE_BUY || pd.match.match_state == BOMBDEFUSAL_STATE_FREEZE

// Loading screen overlay
/atom/movable/screen/fullscreen/bombdefusal_loading
	icon = 'icons/hud/screen.dmi'
	icon_state = "black"
	screen_loc = ui_entire_screen
	layer = BLIND_LAYER + 1
	allstate = TRUE
	maptext_width = 480
	maptext_height = 64
	screen_loc = "CENTER-7:0,CENTER-1:0"

/atom/movable/screen/bombdefusal
	plane = HUD_PLANE
	layer = HUD_BASE_LAYER + 1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = null

// Scoreboard - single centered element: "T 0  |  0:54  |  0 CT"
/atom/movable/screen/bombdefusal/scoreboard
	name = "Scoreboard"
	screen_loc = "CENTER-3:0,NORTH-1:8"
	maptext_width = 224
	maptext_height = 32

// Money display - far right
/atom/movable/screen/bombdefusal/money
	name = "Money"
	screen_loc = "EAST-2:0,NORTH-1:8"
	maptext_width = 96
	maptext_height = 32

// Kill feed - right side
/atom/movable/screen/bombdefusal/killfeed
	name = "Kill Feed"
	screen_loc = "EAST-4:0,NORTH-3:0"
	maptext_width = 200
	maptext_height = 128

// Round announcement - center screen
/atom/movable/screen/bombdefusal/announce
	name = "Announcement"
	screen_loc = "CENTER-3:0,CENTER+1:0"
	maptext_width = 256
	maptext_height = 64

// ===== HUD MANAGEMENT =====

/datum/bombdefusal_match/proc/setup_player_hud(datum/bombdefusal_player_data/pd)
	if(!pd.owner || !pd.owner.current || !pd.owner.current.client)
		return

	// Clean up any existing HUD first to prevent layering
	cleanup_player_hud(pd)

	var/client/C = pd.owner.current.client

	pd.money_display = new /atom/movable/screen/bombdefusal/money()
	pd.timer_display = new /atom/movable/screen/bombdefusal/scoreboard()
	pd.killfeed_display = new /atom/movable/screen/bombdefusal/killfeed()
	pd.announce_display = new /atom/movable/screen/bombdefusal/announce()

	C.screen += pd.money_display
	C.screen += pd.timer_display
	C.screen += pd.killfeed_display
	C.screen += pd.announce_display

	// Remove lobby action, grant buy action
	var/mob/living/M = pd.owner.current
	if(isliving(M))
		for(var/datum/action/innate/bombdefusal_lobby/old in M.actions)
			old.Remove(M)
			qdel(old)
		// Only grant buy action once
		var/has_buy = FALSE
		for(var/datum/action/innate/bombdefusal_buy/existing in M.actions)
			has_buy = TRUE
		if(!has_buy)
			var/datum/action/innate/bombdefusal_buy/buy_action = new()
			buy_action.Grant(M)

	update_player_hud(pd)

/datum/bombdefusal_match/proc/cleanup_player_hud(datum/bombdefusal_player_data/pd)
	var/client/C
	if(pd.owner?.current?.client)
		C = pd.owner.current.client

	var/list/to_clean = list(
		"money_display", "timer_display", "killfeed_display", "announce_display"
	)
	for(var/varname in to_clean)
		var/atom/movable/screen/obj = pd.vars[varname]
		if(obj)
			if(C)
				C.screen -= obj
			qdel(obj)
			pd.vars[varname] = null

	// Clean up team markers
	if(pd.owner?.current)
		for(var/image/I in pd.team_marker_images)
			pd.owner.current.remove_client_image(I)
	pd.team_marker_images.Cut()

/datum/bombdefusal_match/proc/update_player_hud(datum/bombdefusal_player_data/pd)
	if(!pd)
		return

	// Money
	if(pd.money_display)
		var/money_color = pd.money >= 3000 ? "#4cff4c" : (pd.money >= 1000 ? "#ffd700" : "#ff4444")
		pd.money_display.maptext = MAPTEXT("<span style='font-size: 14px; font-family: monospace; color: [money_color]; text-align: right; -dm-text-outline: 1px #000;'>$[pd.money]</span>")

	// Scoreboard: "T 0  |  0:54  |  0 CT"
	if(pd.timer_display)
		var/time_left = max(0, (phase_end_time - world.time) / 10)
		var/minutes = round(time_left / 60)
		var/seconds = round(time_left) % 60
		var/timer_color = time_left <= 10 ? "#ff4444" : "#ffffff"

		var/t_score = (team_a.current_side == BOMBDEFUSAL_TEAM_T) ? a_score : b_score
		var/ct_score = (team_a.current_side == BOMBDEFUSAL_TEAM_CT) ? a_score : b_score

		var/timer_text = "[minutes]:[seconds < 10 ? "0" : ""][seconds]"

		pd.timer_display.maptext = MAPTEXT({"<span style='font-size: 14px; font-family: monospace; text-align: center; -dm-text-outline: 1px #000;'><font color='#ff4444'>T [t_score]</font> <font color='#888'>|</font> <font color='[timer_color]'>[timer_text]</font> <font color='#888'>|</font> <font color='#6666ff'>[ct_score] CT</font></span>"})

/datum/bombdefusal_match/proc/update_all_hud()
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		update_player_hud(pd)

// ===== TEAM MARKERS =====
// Colored triangles above teammates' heads, visible only to same-team players

/datum/bombdefusal_match/proc/update_team_markers(datum/bombdefusal_player_data/pd)
	if(!pd.owner?.current?.client)
		return

	var/mob/viewer = pd.owner.current

	// Clear old markers
	for(var/image/I in pd.team_marker_images)
		viewer.remove_client_image(I)
	pd.team_marker_images.Cut()

	// Determine marker icon based on the viewer's current side
	var/marker_state = (pd.team.current_side == BOMBDEFUSAL_TEAM_T) ? "hudoperative" : "hudloyalist"

	// Add markers on all living teammates (not self)
	for(var/datum/bombdefusal_player_data/teammate in pd.team.members)
		if(teammate == pd)
			continue
		if(!teammate.owner?.current || teammate.is_dead)
			continue
		var/image/marker = image('icons/mob/huds/antag_hud.dmi', loc = teammate.owner.current, icon_state = marker_state, layer = ABOVE_HUMAN_LAYER)
		pd.team_marker_images += marker
		viewer.add_client_image(marker)

/datum/bombdefusal_match/proc/update_all_team_markers()
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		update_team_markers(pd)

// ===== KILLFEED =====

/datum/bombdefusal_match/var/list/killfeed_entries = list()

/datum/bombdefusal_match/proc/add_killfeed_entry(killer_name, victim_name)
	killfeed_entries += "[killer_name] \u25B8 [victim_name]"
	if(killfeed_entries.len > 5)
		killfeed_entries.Cut(1, 2)

	var/feed_text = killfeed_entries.Join("<br>")
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(pd.killfeed_display)
			pd.killfeed_display.maptext = MAPTEXT("<span style='font-size: 9px; font-family: monospace; color: #cccccc; text-align: right; -dm-text-outline: 1px #000;'>[feed_text]</span>")

	spawn(50)
		clear_oldest_killfeed()

/datum/bombdefusal_match/proc/clear_oldest_killfeed()
	if(killfeed_entries.len)
		killfeed_entries.Cut(1, 2)
		var/feed_text = killfeed_entries.Join("<br>")
		for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
			if(pd.killfeed_display)
				pd.killfeed_display.maptext = MAPTEXT("<span style='font-size: 9px; font-family: monospace; color: #cccccc; text-align: right; -dm-text-outline: 1px #000;'>[feed_text]</span>")

// ===== ANNOUNCEMENTS =====

/datum/bombdefusal_match/proc/show_announcement(text, color = "#ffd700", duration = 30)
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(pd.announce_display)
			pd.announce_display.maptext = MAPTEXT("<span style='font-size: 16px; font-family: monospace; color: [color]; text-align: center; -dm-text-outline: 2px #000;'>[text]</span>")
	spawn(duration)
		clear_announcement()

/datum/bombdefusal_match/proc/clear_announcement()
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(pd.announce_display)
			pd.announce_display.maptext = ""
