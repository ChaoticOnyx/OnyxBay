// ========== BOMB DEFUSAL - CORE GAME MODE ==========

/datum/game_mode/bombdefusal
	name = "Bomb defusal"
	round_description = "Terrorists vs Counter-Terrorists! Plant or defuse the bomb!"
	extended_round_description = "Teams of 5 face off in round-based bomb defusal. \
		Terrorists must plant and detonate the bomb at a bomb site. \
		Counter-Terrorists must prevent the plant or defuse the bomb. \
		Earn money for kills and round wins to buy better equipment."
	config_tag = "bombdefusal"
	votable = 1
	required_players = 0 // Allow solo testing
	required_enemies = 0
	end_on_antag_death = 0
	deny_respawn = 1
	ert_disabled = 1

	// ===== ADMIN-CONFIGURABLE SETTINGS =====

	// Economy
	var/cfg_money_start       = 800
	var/cfg_money_max         = 16000
	var/cfg_money_kill        = 300
	var/cfg_money_round_win   = 3250
	var/cfg_money_round_loss  = 1400
	var/cfg_money_loss_bonus  = 500
	var/cfg_money_bomb_plant  = 300
	var/cfg_money_bomb_defuse = 300

	// Timers
	var/cfg_round_time      = 2100 // 210 SECONDS = 3:30
	var/cfg_buy_time        = 300  // 30 SECONDS
	var/cfg_freeze_time     = 200  // 20 SECONDS
	var/cfg_bomb_fuse       = 400  // 40 SECONDS (CS:GO standard)
	var/cfg_plant_time      = 32   // 3.2 SECONDS (CS:GO standard)
	var/cfg_defuse_time     = 100  // 10 SECONDS (5 with kit)
	var/cfg_bleedout_time   = 450  // 45 SECONDS
	var/cfg_roundover_delay = 80   // 8 SECONDS
	var/cfg_halftime_delay  = 200  // 20 SECONDS
	var/cfg_lobby_time      = 1800 // 180 SECONDS = 3 min

	// Match structure
	var/cfg_team_size       = 5
	var/cfg_rounds_to_win   = 8
	var/cfg_rounds_per_half = 7

	// Medical
	var/cfg_medkit_charges  = 3
	var/cfg_medkit_cooldown = 100  // 10 SECONDS
	var/cfg_medkit_heal     = 60
	var/cfg_injector_heal   = 25

	// ===== RUNTIME STATE =====

	var/list/datum/bombdefusal_team/teams = list()
	var/list/datum/bombdefusal_match/matches = list()
	var/list/datum/bombdefusal_player_data/all_players = list()
	var/lobby_active = FALSE
	var/lobby_end_time = 0
	var/lobby_started = FALSE

/datum/game_mode/bombdefusal/announce()
	to_world("<h2>The current game mode is - <b>Bomb Defusal</b>!</h2>")
	to_world("<b>Terrorists vs Counter-Terrorists!</b> Form teams of [cfg_team_size], buy weapons, and fight for the bomb sites!")

/datum/game_mode/bombdefusal/pre_setup()
	// No antag setup needed - we handle teams ourselves
	return TRUE

/datum/game_mode/bombdefusal/post_setup()
	// Kill the storyteller and events - no random events during bomb defusal
	SSstoryteller.can_fire = FALSE
	SSevents.can_fire = FALSE

	lobby_active = TRUE
	lobby_started = FALSE
	// Lobby timer starts when first team is created
	// Players start in their normal spawn, lobby UI opens for them
	for(var/datum/mind/M in SSticker.minds)
		if(!M.current || !M.current.client)
			continue
		show_lobby_ui(M.current)

	to_world("<h3><font color='#FFD700'>BOMB DEFUSAL</font> - Team lobby is open! Create or join a team!</h3>")
	// Play lobby music to all players
	for(var/datum/mind/M in SSticker.minds)
		if(M.current?.client)
			sound_to(M.current, sound('sound/csgo/golosovanie.mp3'))

/datum/game_mode/bombdefusal/process()
	if(lobby_active)
		process_lobby()
		return

	// Tick all active matches
	for(var/datum/bombdefusal_match/match in matches)
		if(match.match_state != BOMBDEFUSAL_STATE_GAMEOVER)
			match.tick()

/datum/game_mode/bombdefusal/check_finished()
	if(lobby_active)
		return FALSE
	// Finished when all matches are done
	for(var/datum/bombdefusal_match/match in matches)
		if(match.match_state != BOMBDEFUSAL_STATE_GAMEOVER)
			return FALSE
	return matches.len > 0

/datum/game_mode/bombdefusal/special_report()
	var/list/parts = list()
	parts += "<h2>Bomb Defusal - Tournament Results</h2>"

	for(var/datum/bombdefusal_match/match in matches)
		var/datum/bombdefusal_team/winner = match.get_winner()
		var/winner_name = winner ? winner.name : "Draw"
		parts += "<h3>Match: [match.team_a.name] vs [match.team_b.name] - Winner: [winner_name]</h3>"
		parts += "<b>Score: [match.a_score] - [match.b_score]</b><br>"

		// Per-player stats
		parts += "<table border='1' cellpadding='3'>"
		parts += "<tr><th>Player</th><th>Team</th><th>Role</th><th>K</th><th>D</th><th>A</th></tr>"
		for(var/datum/bombdefusal_player_data/pd in match.team_a.members + match.team_b.members)
			var/pname = pd.owner ? pd.owner.name : "Unknown"
			parts += "<tr><td>[pname]</td><td>[pd.team.name]</td><td>[pd.role]</td>"
			parts += "<td>[pd.kills]</td><td>[pd.deaths]</td><td>[pd.assists]</td></tr>"
		parts += "</table><br>"

	return "<div class='panel stationborder'>[parts.Join("")]</div>"

// ===== LOBBY MANAGEMENT =====

/datum/game_mode/bombdefusal/proc/process_lobby()
	if(!lobby_active)
		return

	// Check if lobby timer expired
	if(lobby_started && world.time >= lobby_end_time)
		close_lobby()
		return

	// Auto-start lobby timer when we have at least 2 teams
	if(!lobby_started && teams.len >= 2)
		lobby_started = TRUE
		lobby_end_time = world.time + cfg_lobby_time
		to_world("<h3><font color='#FFD700'>BOMB DEFUSAL</font> - Lobby timer started! [cfg_lobby_time / 10] seconds to join teams!</h3>")

/datum/game_mode/bombdefusal/proc/close_lobby()
	lobby_active = FALSE

	// Auto-assign unteamed players to incomplete teams
	var/list/unassigned = list()
	for(var/datum/mind/M in SSticker.minds)
		if(!M.current || !M.current.client)
			continue
		if(!get_player_data(M))
			unassigned += M

	for(var/datum/mind/M in unassigned)
		// Find a team that isn't full
		for(var/datum/bombdefusal_team/T in teams)
			if(!T.is_full(cfg_team_size))
				var/datum/bombdefusal_player_data/pd = new(M, T)
				T.add_member(pd)
				all_players += pd
				break

	// Pair teams and create matches
	var/list/available_teams = teams.Copy()
	while(available_teams.len >= 2)
		var/datum/bombdefusal_team/team_a = pick_n_take(available_teams)
		var/datum/bombdefusal_team/team_b = pick_n_take(available_teams)

		var/datum/bombdefusal_match/match = new(src, team_a, team_b)
		matches += match
		// Anchor all match players during map load to prevent movement
		for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
			if(pd.owner?.current)
				pd.owner.current.anchored = TRUE

		match.initialize_arena()
		// Give atoms time to finish initializing before starting the match
		spawn(5)
			match.start_match()

	// Unpaired teams / solo players become observers
	for(var/datum/bombdefusal_team/T in available_teams)
		for(var/datum/bombdefusal_player_data/pd in T.members)
			if(pd.owner && pd.owner.current)
				to_chat(pd.owner.current, "<span class='warning'>Your team could not be matched. You will spectate this event.</span>")

	to_world("<h3><font color='#FFD700'>BOMB DEFUSAL</font> - [matches.len] match(es) starting!</h3>")

/datum/game_mode/bombdefusal/proc/get_player_data(datum/mind/M)
	for(var/datum/bombdefusal_player_data/pd in all_players)
		if(pd.owner == M)
			return pd
	return null

/datum/game_mode/bombdefusal/proc/get_player_data_by_mob(mob/M)
	if(!M)
		return null
	if(M.mind)
		var/datum/bombdefusal_player_data/pd = get_player_data(M.mind)
		if(pd)
			return pd
	// Fallback: match by ckey
	if(M.ckey)
		for(var/datum/bombdefusal_player_data/pd in all_players)
			if(pd.owner?.key == M.ckey)
				return pd
	return null

// ===== LOBBY UI =====

/datum/game_mode/bombdefusal/proc/show_lobby_ui(mob/user)
	var/datum/bombdefusal_player_data/my_pd = get_player_data_by_mob(user)
	var/my_team_name = my_pd ? my_pd.team.name : "None"

	var/list/html = list()
	html += "<html><head><meta charset='utf-8'><title>Bomb Defusal - Team Lobby</title>"
	html += "<style>"
	html += "body { background: #1a1a2e; color: #eee; font-family: 'Courier New', monospace; margin: 10px; }"
	html += "h1 { color: #FFD700; text-align: center; }"
	html += "h2 { color: #e94560; }"
	html += ".team-box { background: #16213e; border: 1px solid #e94560; padding: 10px; margin: 5px 0; }"
	html += ".btn { background: #e94560; color: white; padding: 5px 15px; border: none; cursor: pointer; font-size: 14px; margin: 2px; }"
	html += ".btn:hover { background: #ff6b6b; }"
	html += ".btn-create { background: #0f3460; }"
	html += ".btn-create:hover { background: #1a5276; }"
	html += ".info { color: #a8a8a8; font-size: 12px; }"
	html += "table { border-collapse: collapse; width: 100%; }"
	html += "td, th { padding: 5px; border: 1px solid #333; }"
	html += "</style></head><body>"

	html += "<h1>BOMB DEFUSAL</h1>"
	html += "<h2>Team Lobby</h2>"

	if(lobby_started)
		var/time_left = max(0, (lobby_end_time - world.time) / 10)
		html += "<p style='color: #FFD700; font-size: 16px;'>Lobby closes in: [round(time_left)]s</p>"

	var/map_name = selected_map ? selected_map.name : "Random"
	html += "<p>Your team: <b>[my_team_name]</b> | Team size: [cfg_team_size]v[cfg_team_size] | Map: <b>[map_name]</b></p>"

	// Create team button
	if(!my_pd)
		html += "<p><a class='btn btn-create' href='?src=\ref[src];action=create_team'>Create Team</a></p>"

	// List existing teams
	html += "<h3>Teams:</h3>"
	if(!teams.len)
		html += "<p class='info'>No teams yet. Create one!</p>"
	else
		for(var/datum/bombdefusal_team/T in teams)
			html += "<div class='team-box'>"
			html += "<b>[T.name]</b> ([T.members.len]/[cfg_team_size])"
			if(T.captain)
				html += " - Captain: [T.captain.name]"
			// Member list
			html += "<br>"
			for(var/datum/bombdefusal_player_data/pd in T.members)
				html += " - [pd.owner.name]<br>"
			// Pending requests (visible to captain)
			if(T.pending_requests.len && user.mind == T.captain)
				html += "<br><span style='color: #FFD700;'>Pending requests:</span><br>"
				for(var/datum/mind/req in T.pending_requests)
					var/req_name = req.current ? req.current.name : req.name
					html += " [req_name] <a class='btn' style='font-size:10px;' href='?src=\ref[src];action=approve_join;team=\ref[T];player=\ref[req]'>OK</a> <a class='btn btn-disabled' style='font-size:10px; background:#a00;' href='?src=\ref[src];action=deny_join;team=\ref[T];player=\ref[req]'>X</a><br>"
			// Join button
			if(!my_pd && !T.is_full(cfg_team_size))
				if(user.mind in T.pending_requests)
					html += "<span class='info'>Request pending...</span>"
				else
					html += "<a class='btn' href='?src=\ref[src];action=join_team;team=\ref[T]'>Request to Join</a>"
			html += "</div>"

	html += "<br><p class='info'>Matches start when lobby timer expires. Unpaired players spectate.</p>"
	html += "<a class='btn' href='?src=\ref[src];action=refresh_lobby'>Refresh</a>"
	html += "</body></html>"

	show_browser(user, html.Join(""), "window=bombdefusal_lobby;size=450x600")

/datum/game_mode/bombdefusal/Topic(href, href_list)
	var/mob/user = usr
	if(!user || !user.client)
		return TRUE

	var/action = href_list["action"]

	// Allow bombdefusal actions for all players, not just admins
	if(!(action in list("create_team", "join_team", "approve_join", "deny_join", "refresh_lobby", "buy_item", "set_role", "admin_config")))
		if(..())
			return TRUE

	switch(action)
		if("create_team")
			if(!lobby_active)
				return TRUE
			if(get_player_data_by_mob(user))
				to_chat(user, "<span class='warning'>You are already on a team!</span>")
				show_lobby_ui(user)
				return TRUE
			var/team_name = input(user, "Enter team name:", "Create Team") as text|null
			if(!team_name || !lobby_active)
				return TRUE
			team_name = sanitize(team_name, max_length = 32, encode = 0)
			if(!team_name)
				return TRUE
			var/datum/bombdefusal_team/new_team = new(team_name, user.mind)
			var/datum/bombdefusal_player_data/pd = new(user.mind, new_team)
			new_team.add_member(pd)
			teams += new_team
			all_players += pd
			to_world("<font color='#FFD700'>BOMB DEFUSAL</font> - Team <b>[team_name]</b> created by [user.name]!")
			show_lobby_ui(user)

		if("join_team")
			if(!lobby_active)
				return TRUE
			if(get_player_data_by_mob(user))
				to_chat(user, "<span class='warning'>You are already on a team!</span>")
				show_lobby_ui(user)
				return TRUE
			var/datum/bombdefusal_team/target = locate(href_list["team"])
			if(!target || target.is_full(cfg_team_size))
				to_chat(user, "<span class='warning'>Team is full or invalid!</span>")
				show_lobby_ui(user)
				return TRUE
			if(user.mind in target.pending_requests)
				to_chat(user, "<span class='warning'>Your request is already pending!</span>")
				show_lobby_ui(user)
				return TRUE
			// Send join request to captain
			target.pending_requests += user.mind
			to_chat(user, "<span class='notice'>Join request sent to captain of <b>[target.name]</b>. Waiting for approval...</span>")
			// Notify captain
			if(target.captain?.current)
				to_chat(target.captain.current, "<span class='notice'><b>[user.name]</b> wants to join your team! <a href='?src=\ref[src];action=approve_join;team=\ref[target];player=\ref[user.mind]'>APPROVE</a> | <a href='?src=\ref[src];action=deny_join;team=\ref[target];player=\ref[user.mind]'>DENY</a></span>")
			show_lobby_ui(user)

		if("approve_join")
			if(!lobby_active)
				return TRUE
			var/datum/bombdefusal_team/target = locate(href_list["team"])
			var/datum/mind/requester = locate(href_list["player"])
			if(!target || !requester)
				return TRUE
			// Only captain can approve
			if(!user.mind || user.mind != target.captain)
				to_chat(user, "<span class='warning'>Only the team captain can approve requests!</span>")
				return TRUE
			if(!(requester in target.pending_requests))
				to_chat(user, "<span class='warning'>This request is no longer pending.</span>")
				return TRUE
			if(target.is_full(cfg_team_size))
				to_chat(user, "<span class='warning'>Team is full!</span>")
				return TRUE
			// Check if requester already joined another team
			if(get_player_data(requester))
				target.pending_requests -= requester
				to_chat(user, "<span class='warning'>This player already joined a team.</span>")
				return TRUE
			target.pending_requests -= requester
			var/datum/bombdefusal_player_data/pd = new(requester, target)
			target.add_member(pd)
			all_players += pd
			var/requester_name = requester.current ? requester.current.name : requester.name
			to_world("<font color='#FFD700'>BOMB DEFUSAL</font> - [requester_name] joined team <b>[target.name]</b>!")
			if(requester.current)
				to_chat(requester.current, "<span class='notice'>You have been approved to join <b>[target.name]</b>!</span>")
				show_lobby_ui(requester.current)
			show_lobby_ui(user)

		if("deny_join")
			if(!lobby_active)
				return TRUE
			var/datum/bombdefusal_team/target = locate(href_list["team"])
			var/datum/mind/requester = locate(href_list["player"])
			if(!target || !requester)
				return TRUE
			if(!user.mind || user.mind != target.captain)
				to_chat(user, "<span class='warning'>Only the team captain can deny requests!</span>")
				return TRUE
			target.pending_requests -= requester
			if(requester.current)
				to_chat(requester.current, "<span class='warning'>Your request to join <b>[target.name]</b> was denied.</span>")
			to_chat(user, "<span class='notice'>Request denied.</span>")

		if("refresh_lobby")
			show_lobby_ui(user)

		if("buy_item")
			handle_buy_topic(user, href_list)

		if("set_role")
			handle_set_role(user, href_list)

		if("admin_config")
			handle_admin_config_topic(user, href_list)

	return TRUE

/datum/game_mode/bombdefusal/proc/force_start_lobby()
	if(lobby_active)
		close_lobby()
