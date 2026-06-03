// ========== BOMB DEFUSAL - ADMIN & DEBUG PANEL ==========

/datum/admins/proc/bombdefusal_config()
	set name = "Bomb Defusal Config"
	set category = "Fun"

	if(!check_rights(R_FUN))
		return

	var/datum/game_mode/bombdefusal/mode = SSticker.mode
	if(!istype(mode))
		to_chat(usr, "<span class='warning'>Bomb Defusal mode is not active!</span>")
		return

	mode.show_admin_panel(usr)

// ===== SOLO DEBUG: quick-start a match with just yourself =====
/datum/admins/proc/bombdefusal_solo_start()
	set name = "Bomb Defusal Solo Test"
	set category = "Fun"

	if(!check_rights(R_FUN))
		return

	var/datum/game_mode/bombdefusal/mode = SSticker.mode
	if(!istype(mode))
		to_chat(usr, "<span class='warning'>Bomb Defusal mode is not active!</span>")
		return

	if(mode.matches.len)
		to_chat(usr, "<span class='warning'>Matches already running. Use the debug panel.</span>")
		return

	mode.solo_debug_start(usr)

/datum/game_mode/bombdefusal/proc/solo_debug_start(mob/user)
	if(!user || !user.mind)
		return

	// Close lobby if active
	lobby_active = FALSE

	// Create two teams - put the player on team A, team B gets a dummy name
	var/datum/bombdefusal_team/team_a = new("Debug Team T", user.mind)
	var/datum/bombdefusal_player_data/pd = new(user.mind, team_a)
	team_a.add_member(pd)
	teams += team_a
	all_players += pd

	var/datum/bombdefusal_team/team_b = new("Debug Team CT", null)
	teams += team_b

	// Create match
	var/datum/bombdefusal_match/match = new(src, team_a, team_b)
	matches += match

	to_chat(user, "<span class='notice'>Loading arena map... You can chill while it loads.</span>")

	// Anchor player during load to prevent movement/signal errors
	user.anchored = TRUE

	match.initialize_arena()

	// Give atoms a few ticks to finish initializing before starting the match
	spawn(5)
		match.start_match()
		to_chat(user, "<span class='notice'>Solo debug match started! You are on T side. Use the debug panel for controls.</span>")
		show_admin_panel(user)

/datum/game_mode/bombdefusal/proc/bot_match_start(mob/user)
	if(!user || !user.mind)
		return

	var/num_matches = input(user, "How many matches (team pairs)?", "Bot Match", 1) as num|null
	if(!num_matches || num_matches < 1)
		return
	var/bot_count = input(user, "How many bots per team?", "Bot Match", 3) as num|null
	if(!bot_count || bot_count < 1)
		return
	bot_count = min(bot_count, cfg_team_size)

	lobby_active = FALSE

	// First match: admin player on Team T + bots
	var/datum/bombdefusal_team/first_t = new("Bot Team T1", user.mind)
	var/datum/bombdefusal_player_data/admin_pd = new(user.mind, first_t)
	first_t.add_member(admin_pd)
	teams += first_t
	all_players += admin_pd

	for(var/i = 1 to bot_count)
		create_bot(first_t, "t1_[i]", get_turf(user))

	var/datum/bombdefusal_team/first_ct = new("Bot Team CT1", null)
	teams += first_ct
	for(var/i = 1 to bot_count + 1) // +1 to match admin's team (admin + bot_count T vs bot_count+1 CT)
		create_bot(first_ct, "ct1_[i]", get_turf(user))

	var/datum/bombdefusal_match/first_match = new(src, first_t, first_ct)
	matches += first_match

	// Additional bot-only matches
	for(var/m = 2 to num_matches)
		var/datum/bombdefusal_team/ta = new("Bot Team T[m]", null)
		teams += ta
		for(var/i = 1 to bot_count)
			create_bot(ta, "t[m]_[i]", get_turf(user))

		var/datum/bombdefusal_team/tb = new("Bot Team CT[m]", null)
		teams += tb
		for(var/i = 1 to bot_count)
			create_bot(tb, "ct[m]_[i]", get_turf(user))

		var/datum/bombdefusal_match/match = new(src, ta, tb)
		matches += match

	to_chat(user, "<span class='notice'>Loading [matches.len] bot match(es) ([bot_count + 1]v[bot_count + 1] first, [bot_count]v[bot_count] rest)...</span>")
	user.anchored = TRUE

	for(var/datum/bombdefusal_match/match in matches)
		match.initialize_arena()
		match.deferred_start()

	to_chat(user, "<span class='notice'>[matches.len] bot match(es) starting!</span>")
	show_admin_panel(user)

/datum/game_mode/bombdefusal/proc/create_bot(datum/bombdefusal_team/team, suffix, turf/spawn_loc)
	var/bot_name = random_name(pick(MALE, FEMALE))
	var/mob/living/carbon/human/bot = new(spawn_loc)
	bot.real_name = bot_name
	bot.name = bot_name
	var/datum/mind/bot_mind = new("[bot_name]_bot_[suffix]")
	bot_mind.set_current(bot)
	bot.mind = bot_mind
	if(!team.captain)
		team.captain = bot_mind
	var/datum/bombdefusal_player_data/pd = new(bot_mind, team)
	team.add_member(pd)
	all_players += pd

/datum/game_mode/bombdefusal/proc/empty_match_start(mob/user)
	if(!user)
		return

	var/num_matches = input(user, "How many empty arenas to create?", "Empty Match", 1) as num|null
	if(!num_matches || num_matches < 1)
		return

	lobby_active = FALSE

	for(var/m = 1 to num_matches)
		var/datum/bombdefusal_team/ta = new("Team T[m]", null)
		teams += ta
		var/datum/bombdefusal_team/tb = new("Team CT[m]", null)
		teams += tb

		var/datum/bombdefusal_match/match = new(src, ta, tb)
		matches += match
		match.initialize_arena()

	to_chat(user, "<span class='notice'>[num_matches] empty arena(s) created. Ghosts can join via 'Join Bomb Defusal' verb.</span>")
	to_world("<h3><font color='#FFD700'>BOMB DEFUSAL</font> - [num_matches] arena(s) open for ghost joining!</h3>")
	show_admin_panel(user)

// ===== MAIN ADMIN PANEL =====

/datum/game_mode/bombdefusal/proc/show_admin_panel(mob/user)
	var/list/html = list()
	html += {"<html><head><meta charset='utf-8'><title>Bomb Defusal - Admin & Debug</title>
<style>
body { background: #1a1a2e; color: #eee; font-family: 'Courier New', monospace; margin: 10px; }
h1 { color: #FFD700; margin: 5px 0; }
h2 { color: #e94560; border-bottom: 1px solid #333; padding-bottom: 3px; margin: 8px 0 4px 0; }
h3 { color: #3498db; margin: 6px 0 3px 0; }
table { border-collapse: collapse; width: 100%; margin-bottom: 8px; }
td { padding: 3px 6px; border: 1px solid #333; }
td:first-child { color: #a8a8a8; width: 180px; }
.btn { background: #e94560; color: white; padding: 4px 12px; border: none; cursor: pointer; font-size: 12px; margin: 2px; text-decoration: none; display: inline-block; }
.btn:hover { background: #ff6b6b; }
.btn-danger { background: #c0392b; }
.btn-success { background: #27ae60; }
.btn-debug { background: #8e44ad; }
.btn-debug:hover { background: #9b59b6; }
.btn-info { background: #2980b9; }
.btn-info:hover { background: #3498db; }
.section { background: #16213e; padding: 8px; margin: 4px 0; border: 1px solid #333; }
.warn { color: #e74c3c; }
.ok { color: #2ecc71; }
.tabs { display: flex; gap: 2px; margin-bottom: 5px; }
.tab { padding: 5px 15px; cursor: pointer; background: #333; color: #aaa; text-decoration: none; }
.tab.active, .tab:hover { background: #e94560; color: white; }
</style>
</head><body>"}

	html += "<h1>BOMB DEFUSAL - Admin & Debug</h1>"

	// Tab navigation
	html += "<div class='tabs'>"
	html += "<a class='tab' href='?src=\ref[src];action=admin_config;cmd=refresh;tab=debug'>DEBUG</a>"
	html += "<a class='tab' href='?src=\ref[src];action=admin_config;cmd=refresh;tab=config'>CONFIG</a>"
	html += "<a class='tab' href='?src=\ref[src];action=admin_config;cmd=refresh;tab=status'>STATUS</a>"
	html += "</div>"

	// Show all sections since browser doesn't persist tab state easily

	// ===== DEBUG TOOLS =====
	html += "<div class='section'>"
	html += "<h2>Debug Tools</h2>"

	if(!matches.len)
		html += "<p>No active match.</p>"

		// Map selector
		if(!available_maps || !available_maps.len)
			init_map_registry()
		html += "<h3>Map Selection</h3>"
		html += "<p>Current: <b>[selected_map ? selected_map.name : "Random"]</b></p>"
		for(var/datum/bombdefusal_map/M in available_maps)
			if(selected_map == M)
				html += "<span class='btn btn-disabled' style='background: #2a6;'>[M.name] (selected)</span> "
			else
				html += "<a class='btn btn-info' href='?src=\ref[src];action=admin_config;cmd=select_map;map=\ref[M]'>[M.name]</a> "
		html += "<a class='btn' href='?src=\ref[src];action=admin_config;cmd=select_map;map=random'>Random</a>"
		html += "<br><br>"

		if(lobby_active)
			html += "<a class='btn btn-success' href='?src=\ref[src];action=admin_config;cmd=force_start'>Force Start Lobby</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=solo_start'>Solo Test Start</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=bot_match'>Bot Match (NvN)</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=empty_match'>Empty Match (ghost join)</a>"
	else
		var/datum/bombdefusal_match/match = matches[1]
		var/state_name = get_state_name(match.match_state)

		html += "<h3>Match Control</h3>"
		html += "<p>State: <b>[state_name]</b> | Round: [match.current_round_num] | Score: [match.a_score]-[match.b_score]</p>"

		// Phase control
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_set_state;state=[BOMBDEFUSAL_STATE_FREEZE]'>Set FREEZE</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_set_state;state=[BOMBDEFUSAL_STATE_BUY]'>Set BUY</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_set_state;state=[BOMBDEFUSAL_STATE_LIVE]'>Set LIVE</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_skip_phase'>Skip Phase &gt;</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_next_round'>Next Round</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_halftime'>Force Halftime</a>"
		html += "<br>"

		// Score control
		html += "<h3>Score</h3>"
		html += "<a class='btn btn-info' href='?src=\ref[src];action=admin_config;cmd=dbg_score;team=a;delta=1'>Team A +1</a>"
		html += "<a class='btn btn-info' href='?src=\ref[src];action=admin_config;cmd=dbg_score;team=a;delta=-1'>Team A -1</a>"
		html += "<a class='btn btn-info' href='?src=\ref[src];action=admin_config;cmd=dbg_score;team=b;delta=1'>Team B +1</a>"
		html += "<a class='btn btn-info' href='?src=\ref[src];action=admin_config;cmd=dbg_score;team=b;delta=-1'>Team B -1</a>"
		html += "<br>"

		// Bomb debug
		html += "<h3>Bomb</h3>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_give_bomb'>Give Bomb to Me</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_plant_bomb'>Instant Plant</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_defuse_bomb'>Instant Defuse</a>"
		html += "<a class='btn btn-danger' href='?src=\ref[src];action=admin_config;cmd=dbg_detonate_bomb'>Instant Detonate</a>"
		html += "<br>"

		// Economy debug
		html += "<h3>Economy</h3>"
		html += "<a class='btn btn-info' href='?src=\ref[src];action=admin_config;cmd=dbg_money;amount=16000'>Set $16000</a>"
		html += "<a class='btn btn-info' href='?src=\ref[src];action=admin_config;cmd=dbg_money;amount=800'>Set $800</a>"
		html += "<a class='btn btn-info' href='?src=\ref[src];action=admin_config;cmd=dbg_money;amount=0'>Set $0</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_open_shop'>Open Buy Menu</a>"
		html += "<br>"

		// Player state debug
		html += "<h3>Player State</h3>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_full_heal'>Full Heal</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_take_damage'>Take 50 Damage</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_down_me'>Down Me (downed state)</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_revive_me'>Revive Me</a>"
		html += "<a class='btn btn-danger' href='?src=\ref[src];action=admin_config;cmd=dbg_kill_me'>Kill Me</a>"
		html += "<br>"

		// Team side debug
		html += "<h3>Team Side</h3>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_swap_side'>Swap My Side (T/CT)</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_tp_t_spawn'>TP to T Spawn</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_tp_ct_spawn'>TP to CT Spawn</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_tp_bombsite_a'>TP to Site A</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_tp_bombsite_b'>TP to Site B</a>"
		html += "<br>"

		// Item spawning
		html += "<h3>Spawn Items</h3>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_spawn;type=medkit'>Arena Medkit</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_spawn;type=injector'>Arena Injector</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_spawn;type=defib'>Combat Defib</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_spawn;type=rifle'>Assault Rifle</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_spawn;type=shotgun'>Shotgun</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_spawn;type=sniper'>Sniper</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_spawn;type=vest'>Armor Vest</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_spawn;type=frag'>Frag Grenade</a>"
		html += "<br>"

		// Match end
		html += "<h3>Match</h3>"
		html += "<a class='btn btn-danger' href='?src=\ref[src];action=admin_config;cmd=dbg_end_round_t'>T Wins Round</a>"
		html += "<a class='btn btn-danger' href='?src=\ref[src];action=admin_config;cmd=dbg_end_round_ct'>CT Wins Round</a>"
		html += "<a class='btn btn-danger' href='?src=\ref[src];action=admin_config;cmd=force_end_all'>End All Matches</a>"
		html += "<a class='btn btn-debug' href='?src=\ref[src];action=admin_config;cmd=dbg_restart_match'>Restart Match</a>"


	html += "</div>"

	// ===== CONFIGURATION =====
	html += "<div class='section'>"
	html += "<h2>Configuration</h2>"

	// Economy
	html += "<h3>Economy</h3>"
	html += "<table>"
	html += config_row("Starting Money", "cfg_money_start", cfg_money_start)
	html += config_row("Max Money", "cfg_money_max", cfg_money_max)
	html += config_row("Kill Reward", "cfg_money_kill", cfg_money_kill)
	html += config_row("Round Win Reward", "cfg_money_round_win", cfg_money_round_win)
	html += config_row("Round Loss Reward", "cfg_money_round_loss", cfg_money_round_loss)
	html += config_row("Loss Bonus (per streak)", "cfg_money_loss_bonus", cfg_money_loss_bonus)
	html += config_row("Bomb Plant Reward", "cfg_money_bomb_plant", cfg_money_bomb_plant)
	html += config_row("Bomb Defuse Reward", "cfg_money_bomb_defuse", cfg_money_bomb_defuse)
	html += "</table>"

	// Timers
	html += "<h3>Timers (seconds)</h3>"
	html += "<table>"
	html += config_row("Round Time", "cfg_round_time", cfg_round_time / 10, 10)
	html += config_row("Buy Time", "cfg_buy_time", cfg_buy_time / 10, 10)
	html += config_row("Freeze Time", "cfg_freeze_time", cfg_freeze_time / 10, 10)
	html += config_row("Bomb Fuse", "cfg_bomb_fuse", cfg_bomb_fuse / 10, 10)
	html += config_row("Plant Time", "cfg_plant_time", cfg_plant_time / 10, 10)
	html += config_row("Defuse Time", "cfg_defuse_time", cfg_defuse_time / 10, 10)
	html += config_row("Round Over Delay", "cfg_roundover_delay", cfg_roundover_delay / 10, 10)
	html += config_row("Halftime Delay", "cfg_halftime_delay", cfg_halftime_delay / 10, 10)
	html += config_row("Lobby Time", "cfg_lobby_time", cfg_lobby_time / 10, 10)
	html += "</table>"

	// Match structure
	html += "<h3>Match Structure</h3>"
	html += "<table>"
	html += config_row("Team Size", "cfg_team_size", cfg_team_size)
	html += config_row("Rounds to Win", "cfg_rounds_to_win", cfg_rounds_to_win)
	html += config_row("Rounds per Half", "cfg_rounds_per_half", cfg_rounds_per_half)
	html += "</table>"

	// Medical
	html += "<h3>Medical</h3>"
	html += "<table>"
	html += config_row("Medkit Charges", "cfg_medkit_charges", cfg_medkit_charges)
	html += config_row("Medkit Cooldown (sec)", "cfg_medkit_cooldown", cfg_medkit_cooldown / 10, 10)
	html += config_row("Injector Heal Amount", "cfg_injector_heal", cfg_injector_heal)
	html += "</table>"
	html += "</div>"

	// ===== MATCH STATUS =====
	html += "<div class='section'>"
	html += "<h2>Match Status</h2>"
	if(!matches.len)
		html += "<p>No active matches.</p>"
	for(var/datum/bombdefusal_match/match in matches)
		var/state_name = get_state_name(match.match_state)
		html += "<p><b>[match.team_a.name] vs [match.team_b.name]</b></p>"
		html += "<p>Round [match.current_round_num] | State: [state_name] | Score: [match.a_score]-[match.b_score]</p>"
		html += "<p>T side: [match.current_t_team.name] | CT side: [match.current_ct_team.name]</p>"
		html += "<p>Bomb planted: [match.bomb_planted ? "<span class='warn'>YES</span>" : "No"] | Defused: [match.bomb_defused] | Detonated: [match.bomb_detonated]</p>"
		// Player list
		html += "<table><tr><th>Player</th><th>Team</th><th>Side</th><th>$</th><th>K/D/A</th><th>State</th></tr>"
		for(var/datum/bombdefusal_player_data/ppd in match.team_a.members + match.team_b.members)
			var/pname = ppd.owner ? ppd.owner.name : "Empty"
			var/side = ppd.team.current_side == BOMBDEFUSAL_TEAM_T ? "<font color='#FF4444'>T</font>" : "<font color='#4444FF'>CT</font>"
			var/pstate = ppd.is_dead ? "<span class='warn'>DEAD</span>" : "<span class='ok'>ALIVE</span>"
			html += "<tr><td>[pname]</td><td>[ppd.team.name]</td><td>[side]</td><td>$[ppd.money]</td><td>[ppd.kills]/[ppd.deaths]/[ppd.assists]</td><td>[pstate]</td></tr>"
		html += "</table>"
	html += "</div>"

	html += "<br><a class='btn' href='?src=\ref[src];action=admin_config;cmd=refresh'>Refresh</a>"
	html += "</body></html>"

	show_browser(user, html.Join(""), "window=bombdefusal_admin;size=600x850")

/datum/game_mode/bombdefusal/proc/get_state_name(state)
	switch(state)
		if(BOMBDEFUSAL_STATE_LOBBY)
			return "Lobby"
		if(BOMBDEFUSAL_STATE_FREEZE)
			return "Freeze"
		if(BOMBDEFUSAL_STATE_BUY)
			return "Buy"
		if(BOMBDEFUSAL_STATE_LIVE)
			return "Live"
		if(BOMBDEFUSAL_STATE_ROUNDOVER)
			return "Round Over"
		if(BOMBDEFUSAL_STATE_HALFTIME)
			return "Halftime"
		if(BOMBDEFUSAL_STATE_WARMUP)
			return "Warmup"
		if(BOMBDEFUSAL_STATE_GAMEOVER)
			return "Game Over"
	return "Unknown"

/datum/game_mode/bombdefusal/proc/config_row(label, var_name, display_value, multiplier = 1)
	return "<tr><td>[label]</td><td>[display_value]</td><td><a class='btn' href='?src=\ref[src];action=admin_config;cmd=set_var;var_name=[var_name];multiplier=[multiplier]'>Edit</a></td></tr>"

// ===== TOPIC HANDLER =====

/datum/game_mode/bombdefusal/proc/handle_admin_config_topic(mob/user, list/href_list)
	if(!user.client || !user.client.holder || !check_rights(R_ADMIN, FALSE, user))
		return

	var/cmd = href_list["cmd"]

	// Get the admin's match if they're in one, otherwise first match
	var/datum/bombdefusal_player_data/my_pd = get_player_data_by_mob(user)
	var/datum/bombdefusal_match/match = my_pd?.match || (matches.len ? matches[1] : null)

	switch(cmd)
		// ===== LOBBY/MATCH CONTROL =====
		if("force_start")
			if(lobby_active)
				force_start_lobby()
				to_chat(user, "<span class='notice'>Lobby force-started.</span>")

		if("force_end_all")
			for(var/datum/bombdefusal_match/m in matches)
				if(m.match_state != BOMBDEFUSAL_STATE_GAMEOVER)
					m.end_match()
			to_chat(user, "<span class='notice'>All matches force-ended.</span>")

		if("solo_start")
			solo_debug_start(user)
			return // solo_start shows its own panel

		if("bot_match")
			bot_match_start(user)
			return

		if("empty_match")
			empty_match_start(user)
			return

		if("select_map")
			if(href_list["map"] == "random")
				selected_map = null
				to_chat(user, "<span class='notice'>Map set to random.</span>")
			else
				var/datum/bombdefusal_map/M = locate(href_list["map"])
				if(M)
					select_map(M)
					to_chat(user, "<span class='notice'>Map set to [M.name].</span>")

		// ===== CONFIG =====
		if("set_var")
			var/var_name = href_list["var_name"]
			var/multiplier = text2num(href_list["multiplier"]) || 1
			if(!findtext(var_name, "cfg_"))
				return
			var/current_val = vars[var_name]
			if(isnull(current_val))
				return
			var/display_val = current_val / multiplier
			var/new_val = input(user, "Set [var_name] (current: [display_val]):", "Edit Config") as num|null
			if(isnull(new_val))
				show_admin_panel(user)
				return
			new_val = round(new_val * multiplier)
			if(new_val < 0)
				show_admin_panel(user)
				return
			vars[var_name] = new_val
			log_and_message_admins("[user] set bombdefusal [var_name] to [new_val]")

		// ===== PHASE/ROUND DEBUG =====
		if("dbg_set_state")
			if(!match)
				return
			var/new_state = text2num(href_list["state"])
			match.match_state = new_state
			match.phase_end_time = world.time + 9999 // Don't auto-transition
			to_chat(user, "<span class='notice'>State set to [get_state_name(new_state)].</span>")

		if("dbg_skip_phase")
			if(!match)
				return
			match.phase_end_time = world.time // Expire current phase immediately
			to_chat(user, "<span class='notice'>Phase timer expired. Will transition next tick.</span>")

		if("dbg_next_round")
			if(!match)
				return
			// Go through proper flow: check game over, halftime, then start round
			if(match.a_score >= cfg_rounds_to_win || match.b_score >= cfg_rounds_to_win)
				match.end_match()
				to_chat(user, "<span class='notice'>Match ended (score limit reached).</span>")
			else if(!match.halftime_done && match.current_round_num >= cfg_rounds_per_half)
				match.do_halftime()
				to_chat(user, "<span class='notice'>Halftime triggered at round [match.current_round_num].</span>")
			else
				match.start_round()
				to_chat(user, "<span class='notice'>Started round [match.current_round_num].</span>")

		if("dbg_halftime")
			if(!match)
				return
			match.do_halftime()
			to_chat(user, "<span class='notice'>Halftime triggered. Sides swapped.</span>")

		if("dbg_end_round_t")
			if(!match)
				return
			match.end_round(BOMBDEFUSAL_TEAM_T, "Debug: T wins")
			to_chat(user, "<span class='notice'>Round ended: T wins.</span>")

		if("dbg_end_round_ct")
			if(!match)
				return
			match.end_round(BOMBDEFUSAL_TEAM_CT, "Debug: CT wins")
			to_chat(user, "<span class='notice'>Round ended: CT wins.</span>")

		if("dbg_restart_match")
			if(!match)
				return
			match.a_score = 0
			match.b_score = 0
			match.current_round_num = 0
			match.halftime_done = FALSE
			match.match_state = BOMBDEFUSAL_STATE_LOBBY
			match.start_match()
			to_chat(user, "<span class='notice'>Match restarted.</span>")

		// ===== SCORE DEBUG =====
		if("dbg_score")
			if(!match)
				return
			var/team_key = href_list["team"]
			var/delta = text2num(href_list["delta"]) || 0
			if(team_key == "a")
				match.a_score = max(0, match.a_score + delta)
			else
				match.b_score = max(0, match.b_score + delta)
			to_chat(user, "<span class='notice'>Score: [match.a_score]-[match.b_score]</span>")

		// ===== BOMB DEBUG =====
		if("dbg_give_bomb")
			if(!match || !user)
				return
			if(match.current_bomb)
				qdel(match.current_bomb)
			var/obj/item/bombdefusal_bomb/B = new(get_turf(user))
			B.match = match
			match.current_bomb = B
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.put_in_hands(B)
			to_chat(user, "<span class='notice'>Bomb given to you.</span>")

		if("dbg_plant_bomb")
			if(!match)
				return
			if(!match.current_bomb)
				// Create bomb at first bombsite
				if(match.bombsites.len)
					var/obj/effect/landmark/bombdefusal/bombsite/site = match.bombsites[1]
					var/obj/item/bombdefusal_bomb/B = new(get_turf(site))
					B.match = match
					match.current_bomb = B
			if(match.current_bomb)
				match.current_bomb.armed = TRUE
				match.current_bomb.anchored = TRUE
				match.current_bomb.icon_state = "plastic-explosive2"
				match.current_bomb.planter = user
				if(match.current_bomb.loc != get_turf(match.current_bomb))
					// Drop from inventory if held
					if(ishuman(user))
						var/mob/living/carbon/human/H = user
						H.drop(match.current_bomb, force = TRUE)
				match.on_bomb_planted()
				// Start beeping, blinking and fuse timer
				match.current_bomb.detonate_at = world.time + match.mode.cfg_bomb_fuse
				match.current_bomb.start_beeping()
				match.current_bomb.start_blink()
				spawn(match.mode.cfg_bomb_fuse)
					if(match.current_bomb && !QDELETED(match.current_bomb))
						match.current_bomb.detonate()
				to_chat(user, "<span class='notice'>Bomb instantly planted.</span>")

		if("dbg_defuse_bomb")
			if(!match || !match.current_bomb || !match.current_bomb.armed)
				to_chat(user, "<span class='warning'>No armed bomb to defuse.</span>")
			else
				match.current_bomb.defused = TRUE
				match.on_bomb_defused(user)
				to_chat(user, "<span class='notice'>Bomb instantly defused.</span>")

		if("dbg_detonate_bomb")
			if(!match || !match.current_bomb || !match.current_bomb.armed)
				to_chat(user, "<span class='warning'>No armed bomb to detonate.</span>")
			else
				match.current_bomb.detonate()
				to_chat(user, "<span class='notice'>Bomb detonated.</span>")

		// ===== ECONOMY DEBUG =====
		if("dbg_money")
			if(!my_pd)
				return
			my_pd.money = text2num(href_list["amount"]) || 0
			to_chat(user, "<span class='notice'>Money set to $[my_pd.money].</span>")

		if("dbg_open_shop")
			if(!my_pd)
				return
			show_buy_menu(user, my_pd, force_open = TRUE)

		// ===== PLAYER STATE DEBUG =====
		if("dbg_full_heal")
			if(istype(user, /mob/living/carbon/human/bombdefusal))
				var/mob/living/carbon/human/bombdefusal/H = user
				H.arena_full_heal()
				to_chat(user, "<span class='notice'>Fully healed.</span>")

		if("dbg_take_damage")
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.adjustBruteLoss(50)
				to_chat(user, "<span class='warning'>Took 50 brute damage.</span>")

		if("dbg_revive_me")
			if(!my_pd || !match)
				return
			if(my_pd.is_dead)
				my_pd.is_dead = FALSE
				if(istype(user, /mob/living/carbon/human/bombdefusal))
					var/mob/living/carbon/human/bombdefusal/H = user
					H.arena_full_heal()
				to_chat(user, "<span class='notice'>Revived from death.</span>")
			else
				to_chat(user, "<span class='notice'>You are already alive.</span>")

		if("dbg_kill_me")
			if(!my_pd || !match)
				return
			my_pd.is_dead = TRUE
			my_pd.deaths++
			if(isliving(user))
				var/mob/living/L = user
				L.death()
			to_chat(user, "<span class='warning'>You died.</span>")


		// ===== SIDE/TELEPORT DEBUG =====
		if("dbg_swap_side")
			if(!my_pd || !match)
				return
			// Swap which team is T
			var/temp = match.current_t_team
			match.current_t_team = match.current_ct_team
			match.current_ct_team = temp
			match.team_a.current_side = (match.team_a == match.current_t_team) ? BOMBDEFUSAL_TEAM_T : BOMBDEFUSAL_TEAM_CT
			match.team_b.current_side = (match.team_b == match.current_t_team) ? BOMBDEFUSAL_TEAM_T : BOMBDEFUSAL_TEAM_CT
			to_chat(user, "<span class='notice'>Sides swapped. You are now [my_pd.team.current_side].</span>")

		if("dbg_tp_t_spawn")
			if(!match || !match.t_spawns.len)
				return
			user.forceMove(pick(match.t_spawns))
			to_chat(user, "<span class='notice'>Teleported to T spawn.</span>")

		if("dbg_tp_ct_spawn")
			if(!match || !match.ct_spawns.len)
				return
			user.forceMove(pick(match.ct_spawns))
			to_chat(user, "<span class='notice'>Teleported to CT spawn.</span>")

		if("dbg_tp_bombsite_a")
			if(!match)
				return
			for(var/obj/effect/landmark/bombdefusal/bombsite/BS in match.bombsites)
				if(BS.site_id == "A")
					user.forceMove(get_turf(BS))
					to_chat(user, "<span class='notice'>Teleported to Bomb Site A.</span>")
					break

		if("dbg_tp_bombsite_b")
			if(!match)
				return
			for(var/obj/effect/landmark/bombdefusal/bombsite/BS in match.bombsites)
				if(BS.site_id == "B")
					user.forceMove(get_turf(BS))
					to_chat(user, "<span class='notice'>Teleported to Bomb Site B.</span>")
					break

		// ===== ITEM SPAWNING =====
		if("dbg_spawn")
			if(!ishuman(user))
				return
			var/mob/living/carbon/human/H = user
			var/spawn_type = href_list["type"]
			var/obj/item/spawned
			switch(spawn_type)
				if("medkit")
					spawned = new /obj/item/bombdefusal_medkit(get_turf(H))
				if("injector")
					spawned = new /obj/item/bombdefusal_injector(get_turf(H))
				if("defib")
					spawned = new /obj/item/defibrillator/compact/combat/loaded(get_turf(H))
				if("rifle")
					spawned = new /obj/item/gun/projectile/automatic/as75(get_turf(H))
				if("shotgun")
					spawned = new /obj/item/gun/projectile/shotgun/pump/combat(get_turf(H))
				if("sniper")
					spawned = new /obj/item/gun/projectile/heavysniper(get_turf(H))
				if("vest")
					spawned = new /obj/item/clothing/suit/armor/vest(get_turf(H))
				if("frag")
					spawned = new /obj/item/grenade/frag(get_turf(H))
			if(spawned)
				H.put_in_hands(spawned)
				to_chat(user, "<span class='notice'>Spawned [spawned.name].</span>")

		if("refresh")
			. = null // Just refresh panel

	show_admin_panel(user)
