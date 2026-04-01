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

	// Register team radio channels so headsets can connect
	GLOB.radio_channels["Terrorists"] = BOMBDEFUSAL_FREQ_T
	GLOB.radio_channels["Counter-Terrorists"] = BOMBDEFUSAL_FREQ_CT
	// Map :h (department) shortcut to show in headset description
	department_radio_keys[":t"] = "Terrorists"
	department_radio_keys[":T"] = "Terrorists"
	department_radio_keys[":s"] = "Counter-Terrorists"
	department_radio_keys[":S"] = "Counter-Terrorists"

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
			sound_to(M.current, sound('sound/csgo/golosovanie.mp3', volume = 40))

/mob/living/verb/bombdefusal_lobby()
	set name = "Bomb Defusal Lobby"
	set category = "OOC"

	var/datum/game_mode/bombdefusal/mode = SSticker.mode
	if(!istype(mode))
		to_chat(src, "<span class='warning'>Bomb Defusal is not active.</span>")
		return
	if(!mode.lobby_active)
		to_chat(src, "<span class='warning'>The lobby has already closed.</span>")
		return
	mode.show_lobby_ui(src)

/datum/game_mode/bombdefusal/process()
	if(lobby_active)
		process_lobby()
		return

	// Tick all active matches
	for(var/datum/bombdefusal_match/match in matches)
		if(match.match_state != BOMBDEFUSAL_STATE_GAMEOVER)
			match.tick()

/datum/game_mode/bombdefusal/handle_latejoin(mob/living/carbon/human/character)
	if(lobby_active && character?.client)
		show_lobby_ui(character)
	return ..()

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

	// Step 1: Collect unassigned in-game players
	var/list/datum/mind/unassigned = list()
	for(var/datum/mind/M in SSticker.minds)
		if(!M.current || !M.current.client)
			continue
		if(!isliving(M.current))
			continue
		if(!get_player_data(M))
			unassigned += M

	// Step 2: Fill existing teams up to cfg_team_size
	for(var/datum/bombdefusal_team/T in teams)
		while(unassigned.len && T.members.len < cfg_team_size)
			var/datum/mind/M = pick_n_take(unassigned)
			var/datum/bombdefusal_player_data/pd = new(M, T)
			T.add_member(pd)
			all_players += pd

	// Step 3: Merge solo players (teams of 1) into other small teams
	// Only merge teams with 1 member — deliberate teams of 2+ are kept intact
	var/merging = TRUE
	while(merging)
		merging = FALSE
		for(var/i = 1 to teams.len)
			var/datum/bombdefusal_team/solo = teams[i]
			if(solo.members.len != 1)
				continue
			for(var/j = teams.len to i + 1 step -1)
				var/datum/bombdefusal_team/other = teams[j]
				if(other.members.len < cfg_team_size)
					for(var/datum/bombdefusal_player_data/pd in solo.members)
						pd.team = other
						other.add_member(pd)
					solo.members.Cut()
					teams -= solo
					merging = TRUE
					break

	// Step 4: Create new teams for remaining unassigned players
	var/team_num = teams.len + 1
	while(unassigned.len)
		var/datum/bombdefusal_team/new_team = new("Team [team_num]", null)
		team_num++
		while(unassigned.len && new_team.members.len < cfg_team_size)
			var/datum/mind/M = pick_n_take(unassigned)
			var/datum/bombdefusal_player_data/pd = new(M, new_team)
			new_team.add_member(pd)
			all_players += pd
		if(new_team.members.len)
			if(!new_team.captain)
				var/datum/bombdefusal_player_data/first = new_team.members[1]
				new_team.captain = first.owner
			teams += new_team

	// Step 5: Pair teams into matches (prefer similar sizes, max 1 diff)
	var/list/available_teams = teams.Copy()
	var/list/match_pairs = list()
	while(available_teams.len >= 2)
		var/datum/bombdefusal_team/ta = pick_n_take(available_teams)
		var/datum/bombdefusal_team/best = null
		var/best_diff = INFINITY
		for(var/datum/bombdefusal_team/candidate in available_teams)
			var/diff = abs(ta.members.len - candidate.members.len)
			if(diff < best_diff)
				best = candidate
				best_diff = diff
		if(best)
			available_teams -= best
			match_pairs += list(list(ta, best))
		else
			break

	// Step 6: Create matches and arenas
	for(var/list/pair in match_pairs)
		var/datum/bombdefusal_team/ta = pair[1]
		var/datum/bombdefusal_team/tb = pair[2]
		var/datum/bombdefusal_match/match = new(src, ta, tb)
		matches += match
		for(var/datum/bombdefusal_player_data/pd in ta.members + tb.members)
			if(pd.owner?.current)
				pd.owner.current.anchored = TRUE
		match.initialize_arena()
		// Defer start_match via the match datum itself to avoid spawn() closure bug
		match.deferred_start()

	// Unpaired teams become observers
	for(var/datum/bombdefusal_team/T in available_teams)
		for(var/datum/bombdefusal_player_data/pd in T.members)
			if(pd.owner?.current)
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

	// Create team / Leave team buttons
	if(!my_pd)
		html += "<p><a class='btn btn-create' href='?src=\ref[src];action=create_team'>Create Team</a></p>"
	else
		html += "<p><a class='btn' style='background:#a00;' href='?src=\ref[src];action=leave_team'>Leave Team</a></p>"

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
				html += " - [pd.owner ? pd.owner.name : "???"]<br>"
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
	if(!(action in list("create_team", "join_team", "leave_team", "approve_join", "deny_join", "refresh_lobby", "buy_item", "set_role", "admin_config", "ghost_join", "ghost_join_refresh")))
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

		if("leave_team")
			if(!lobby_active)
				return TRUE
			var/datum/bombdefusal_player_data/pd = get_player_data_by_mob(user)
			if(!pd)
				to_chat(user, "<span class='warning'>You are not on a team!</span>")
				show_lobby_ui(user)
				return TRUE
			var/datum/bombdefusal_team/old_team = pd.team
			old_team.remove_member(pd)
			all_players -= pd
			to_chat(user, "<span class='notice'>You left <b>[old_team.name]</b>.</span>")
			// If captain left, assign new captain or disband
			if(old_team.captain == user.mind)
				if(old_team.members.len)
					var/datum/bombdefusal_player_data/new_cap = old_team.members[1]
					old_team.captain = new_cap.owner
					if(new_cap.owner?.current)
						to_chat(new_cap.owner.current, "<span class='notice'>You are now the captain of <b>[old_team.name]</b>!</span>")
				else
					teams -= old_team
			// Remove empty teams
			else if(!old_team.members.len)
				teams -= old_team
			show_lobby_ui(user)

		if("refresh_lobby")
			show_lobby_ui(user)

		if("buy_item")
			handle_buy_topic(user, href_list)

		if("set_role")
			handle_set_role(user, href_list)

		if("admin_config")
			handle_admin_config_topic(user, href_list)

		if("ghost_join")
			var/datum/bombdefusal_match/match = locate(href_list["match"])
			handle_ghost_join(user, match, href_list["side"])

		if("ghost_join_refresh")
			show_ghost_join_ui(user)

	return TRUE

// ===== GHOST JOIN =====

/mob/observer/ghost/verb/join_bombdefusal()
	set name = "Join Bomb Defusal"
	set category = "Ghost"

	var/datum/game_mode/bombdefusal/mode = SSticker.mode
	if(!istype(mode))
		to_chat(src, "<span class='warning'>Bomb Defusal is not active.</span>")
		return

	if(mode.lobby_active)
		to_chat(src, "<span class='warning'>The lobby is still open. Wait for matches to start.</span>")
		return

	if(mode.get_player_data_by_mob(src))
		to_chat(src, "<span class='warning'>You are already in a match!</span>")
		return

	// Show available matches
	mode.show_ghost_join_ui(src)

/datum/game_mode/bombdefusal/proc/show_ghost_join_ui(mob/user)
	var/list/html = list()
	html += "<html><head><meta charset='utf-8'><title>Join Match</title>"
	html += "<style>"
	html += "body { background: #1a1a2e; color: #eee; font-family: 'Courier New', monospace; margin: 10px; }"
	html += "h1 { color: #FFD700; text-align: center; }"
	html += ".match-box { background: #16213e; border: 1px solid #e94560; padding: 10px; margin: 5px 0; }"
	html += ".btn { background: #e94560; color: white; padding: 5px 15px; border: none; cursor: pointer; font-size: 14px; margin: 2px; text-decoration: none; }"
	html += ".btn:hover { background: #ff6b6b; }"
	html += ".btn-create { background: #0f3460; }"
	html += ".info { color: #a8a8a8; font-size: 12px; }"
	html += "</style></head><body>"
	html += "<h1>JOIN MATCH</h1>"

	var/has_matches = FALSE
	for(var/datum/bombdefusal_match/match in matches)
		if(match.match_state == BOMBDEFUSAL_STATE_GAMEOVER)
			continue
		has_matches = TRUE
		var/t_name = match.current_t_team == match.team_a ? match.team_a.name : match.team_b.name
		var/ct_name = match.current_ct_team == match.team_a ? match.team_a.name : match.team_b.name
		var/t_count = match.current_t_team.members.len
		var/ct_count = match.current_ct_team.members.len
		html += "<div class='match-box'>"
		html += "<b>[match.team_a.name] vs [match.team_b.name]</b>"
		if(match.match_state == BOMBDEFUSAL_STATE_LOBBY)
			html += " — <font color='#FFD700'>Waiting for players</font>"
		else if(match.match_state == BOMBDEFUSAL_STATE_WARMUP)
			var/warmup_left = max(0, round((match.phase_end_time - world.time) / 10))
			html += " — <font color='#FFD700'>Starting in [warmup_left]s</font>"
		else
			html += " — Round [match.current_round_num]"
		html += "<br>"
		html += "<font color='#ff4444'>T: [t_name] ([t_count])</font> | <font color='#4488ff'>CT: [ct_name] ([ct_count])</font><br>"
		if(match.match_state != BOMBDEFUSAL_STATE_LOBBY)
			html += "Score: [match.a_score] - [match.b_score]<br>"
		if(t_count <= ct_count && t_count < cfg_team_size)
			html += "<a class='btn' href='?src=\ref[src];action=ghost_join;match=\ref[match];side=t'>Join T ([t_count] players)</a> "
		if(ct_count <= t_count && ct_count < cfg_team_size)
			html += "<a class='btn' style='background:#0044cc;' href='?src=\ref[src];action=ghost_join;match=\ref[match];side=ct'>Join CT ([ct_count] players)</a> "
		if(t_count >= cfg_team_size && ct_count >= cfg_team_size)
			html += "<span class='info'>Teams full</span>"
		html += "</div>"

	if(!has_matches)
		html += "<p class='info'>No active matches to join.</p>"

	// Option to create a new match if there are enough unmatched ghosts
	html += "<br><p class='info'>If no matches are available, ask an admin to start a new one.</p>"
	html += "<a class='btn' href='?src=\ref[src];action=ghost_join_refresh'>Refresh</a>"
	html += "</body></html>"
	show_browser(user, html.Join(""), "window=bombdefusal_ghost_join;size=450x400")

/datum/game_mode/bombdefusal/proc/handle_ghost_join(mob/user, datum/bombdefusal_match/match, side)
	if(!user || !user.client)
		return
	if(!match || match.match_state == BOMBDEFUSAL_STATE_GAMEOVER)
		to_chat(user, "<span class='warning'>That match is no longer active.</span>")
		return
	if(get_player_data_by_mob(user))
		to_chat(user, "<span class='warning'>You are already in a match!</span>")
		return

	// Determine which team to join
	var/datum/bombdefusal_team/join_team
	if(side == "t")
		join_team = match.current_t_team
	else
		join_team = match.current_ct_team

	if(join_team.members.len >= cfg_team_size)
		to_chat(user, "<span class='warning'>That team is full!</span>")
		show_ghost_join_ui(user)
		return

	// Create a mind if the ghost doesn't have one
	if(!user.mind)
		user.mind = new /datum/mind(user.key)
		user.mind.set_current(user)

	// Add to team
	var/datum/bombdefusal_player_data/pd = new(user.mind, join_team)
	join_team.add_member(pd)
	all_players += pd
	pd.match = match
	pd.money = cfg_money_start
	pd.needs_reequip = TRUE

	close_browser(user, "window=bombdefusal_ghost_join")

	// If match hasn't started yet (empty arena or warmup)
	if(match.match_state == BOMBDEFUSAL_STATE_LOBBY)
		if(pd.owner?.current)
			to_chat(pd.owner.current, "<span class='notice'><b>You joined [join_team.name]!</b></span>")
		match.announce_to_match("<font color='#FFD700'>[user.name] has joined [join_team.name]!</font>", "#FFD700")
		// Start warmup countdown when both teams have 2+ players
		if(match.team_a.members.len >= 2 && match.team_b.members.len >= 2)
			match.begin_warmup()
		return

	if(match.match_state == BOMBDEFUSAL_STATE_WARMUP)
		if(pd.owner?.current)
			to_chat(pd.owner.current, "<span class='notice'><b>You joined [join_team.name]!</b> Match starting soon...</span>")
		match.announce_to_match("<font color='#FFD700'>[user.name] has joined [join_team.name]!</font>", "#FFD700")
		return

	// Match already running — spawn into it
	match.spawn_player(pd)
	match.update_all_team_markers()

	if(pd.owner?.current)
		to_chat(pd.owner.current, "<span class='notice'><b>You have joined the match!</b> You are on the <b>[join_team.name]</b> team.</span>")
	match.announce_to_match("<font color='#FFD700'>[user.name] has joined [join_team.name]!</font>", "#FFD700")

/datum/game_mode/bombdefusal/proc/force_start_lobby()
	if(lobby_active)
		close_lobby()
