// ========== BOMB DEFUSAL - MATCH INSTANCE ==========

/datum/bombdefusal_match
	var/datum/game_mode/bombdefusal/mode
	var/datum/bombdefusal_team/team_a
	var/datum/bombdefusal_team/team_b
	var/a_score = 0
	var/b_score = 0
	var/current_round_num = 0
	var/halftime_done = FALSE
	var/halftime_just_happened = FALSE
	var/match_state = BOMBDEFUSAL_STATE_LOBBY

	// Arena
	var/arena_z_level = 0
	var/list/arena_atoms = list()
	var/list/turf/t_spawns = list()
	var/list/turf/ct_spawns = list()
	var/list/obj/effect/landmark/bombdefusal/bombsite/bombsites = list()
	var/list/saved_structures = list() // Snapshot of destructible objects for round reset

	// Current round
	var/round_start_time = 0
	var/phase_end_time = 0
	var/bomb_planted = FALSE
	var/bomb_detonated = FALSE
	var/bomb_defused = FALSE
	var/obj/item/bombdefusal_bomb/current_bomb

	// Which team is T and CT this half
	var/datum/bombdefusal_team/current_t_team
	var/datum/bombdefusal_team/current_ct_team

/datum/bombdefusal_match/New(datum/game_mode/bombdefusal/game_mode, datum/bombdefusal_team/ta, datum/bombdefusal_team/tb)
	..()
	mode = game_mode
	team_a = ta
	team_b = tb
	// Team A starts as T, Team B as CT
	current_t_team = team_a
	current_ct_team = team_b
	team_a.current_side = BOMBDEFUSAL_TEAM_T
	team_b.current_side = BOMBDEFUSAL_TEAM_CT

/datum/bombdefusal_match/proc/initialize_arena()
	// Pre-register z-levels with the map system BEFORE loading
	// load_new_z() will create world.maxz+1, and turfs init immediately which calls get_external_air()
	var/expected_z = world.maxz + 1
	while(GLOB.using_map.map_levels.len < expected_z)
		// Create a space level with breathable atmosphere
		var/datum/space_level/arena_level = new()
		arena_level.traits = list("[ZTRAIT_SEALED]" = TRUE)
		var/datum/gas_mixture/atmos = new()
		atmos.gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
		atmos.temperature = 20 CELSIUS
		arena_level.exterior_atmosphere = atmos
		GLOB.using_map.map_levels += arena_level

	// Show fullscreen loading overlay
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(pd.owner?.current)
			var/mob/M = pd.owner.current
			M.overlay_fullscreen("bombdefusal_loading", /atom/movable/screen/fullscreen/bombdefusal_loading)
			var/atom/movable/screen/fullscreen/S = M.screens["bombdefusal_loading"]
			if(S)
				S.maptext = {"<div style="text-align:center;font-size:24px;color:#FFD700;font-family:'Courier New',monospace;margin-top:12px;"><b>LOADING ARENA...</b></div>"}

	// Load arena map on new z-level
	var/map_path = mode.get_selected_map_path()
	var/datum/map_template/bombdefusal_arena/arena_template = new()
	arena_template.mappaths = list(map_path)
	var/turf/center = arena_template.load_new_z()
	if(!center)
		CRASH("Failed to load bombdefusal arena map: [map_path]")

	arena_z_level = center.z
	arena_atoms = arena_template.created_atoms ? arena_template.created_atoms.Copy() : list()

	// Ensure map_levels covers the actual z if it went higher than expected
	while(GLOB.using_map.map_levels.len < arena_z_level)
		var/datum/space_level/extra_level = new()
		extra_level.traits = list("[ZTRAIT_SEALED]" = TRUE)
		var/datum/gas_mixture/atmos = new()
		atmos.gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
		atmos.temperature = 20 CELSIUS
		extra_level.exterior_atmosphere = atmos
		GLOB.using_map.map_levels += extra_level

	// Reassign all turfs on this z-level to a custom arena area
	// This is needed because /area/space/has_gravity() is hardcoded to return FALSE
	var/area/bombdefusal_arena/arena_area = new()
	for(var/turf/T in block(locate(1, 1, arena_z_level), locate(world.maxx, world.maxy, arena_z_level)))
		var/area/A = T.loc
		if(istype(A, /area/space))
			arena_area.contents += T

	// Force power, lighting, and gravity on all areas on this z-level
	var/list/processed_areas = list()
	for(var/turf/T in block(locate(1, 1, arena_z_level), locate(world.maxx, world.maxy, arena_z_level)))
		var/area/A = T.loc
		if(A && !(A in processed_areas))
			processed_areas += A
			A.requires_power = FALSE
			A.always_unpowered = FALSE
			A.power_light = TRUE
			A.power_equip = TRUE
			A.power_environ = TRUE
			A.has_gravity = TRUE
			A.gravity_state = AREA_GRAVITY_ALWAYS
			A.lightswitch = TRUE
			A.power_change()

	// Strip access from all doors on the arena
	for(var/obj/machinery/door/airlock/D in SSmachines.machinery)
		if(D.z == arena_z_level)
			D.req_access = list()
			D.req_one_access = list()

	// Force all light fixtures on the z-level to turn on
	for(var/obj/machinery/light/L in SSmachines.machinery)
		if(L.z == arena_z_level)
			L.stat &= ~NOPOWER
			L.on = TRUE
			L.update(TRUE)

	// Find spawn landmarks - scan the z-level directly
	for(var/obj/effect/landmark/bombdefusal/L in GLOB.landmarks_list)
		if(L.z != arena_z_level)
			continue
		if(istype(L, /obj/effect/landmark/bombdefusal/t_spawn))
			t_spawns += get_turf(L)
		else if(istype(L, /obj/effect/landmark/bombdefusal/ct_spawn))
			ct_spawns += get_turf(L)
		else if(istype(L, /obj/effect/landmark/bombdefusal/bombsite))
			bombsites += L

	// Fallback: scan created_atoms
	if(!t_spawns.len || !ct_spawns.len)
		for(var/atom/A in arena_atoms)
			if(istype(A, /obj/effect/landmark/bombdefusal/t_spawn))
				t_spawns |= get_turf(A)
			else if(istype(A, /obj/effect/landmark/bombdefusal/ct_spawn))
				ct_spawns |= get_turf(A)
			else if(istype(A, /obj/effect/landmark/bombdefusal/bombsite))
				bombsites |= A

	// Last resort: brute-force scan every turf
	if(!t_spawns.len || !ct_spawns.len)
		for(var/turf/T in block(locate(1, 1, arena_z_level), locate(world.maxx, world.maxy, arena_z_level)))
			for(var/obj/effect/landmark/bombdefusal/L in T)
				if(istype(L, /obj/effect/landmark/bombdefusal/t_spawn))
					t_spawns |= T
				else if(istype(L, /obj/effect/landmark/bombdefusal/ct_spawn))
					ct_spawns |= T
				else if(istype(L, /obj/effect/landmark/bombdefusal/bombsite))
					bombsites |= L

	log_game("Bombdefusal arena loaded on z=[arena_z_level]: [t_spawns.len] T spawns, [ct_spawns.len] CT spawns, [bombsites.len] bombsites")

	// Clear loading screen and notify players
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(pd.owner?.current)
			pd.owner.current.clear_fullscreen("bombdefusal_loading")
			to_chat(pd.owner.current, "<span class='notice'><b>Arena ready!</b> [t_spawns.len] T spawns, [ct_spawns.len] CT spawns, [bombsites.len] bomb sites.</span>")

/datum/bombdefusal_match/proc/start_match()
	// Save snapshot of structures now that atoms are fully initialized
	if(!saved_structures.len)
		save_arena_structures()
		log_game("Bombdefusal: Saved [saved_structures.len] structures for round reset")

	// Reset all player data
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		pd.reset_for_match(mode.cfg_money_start)
		pd.match = src

	current_round_num = 0
	a_score = 0
	b_score = 0
	start_round()

// Save window frame positions for round reset (doors are repaired in place)
/datum/bombdefusal_match/proc/save_arena_structures()
	saved_structures = list()
	for(var/turf/T in block(locate(1, 1, arena_z_level), locate(world.maxx, world.maxy, arena_z_level)))
		for(var/obj/structure/window_frame/WF in T)
			saved_structures += list(list("type" = WF.type, "x" = T.x, "y" = T.y, "dir" = WF.dir))
	log_game("Bombdefusal save_arena_structures: z=[arena_z_level], saved [saved_structures.len] window frames")
	announce_to_match("<span class='debug'>DEBUG: Saved [saved_structures.len] window frames for round reset (z=[arena_z_level])</span>", "#FFAA00")

/datum/bombdefusal_match/proc/cleanup_arena()
	for(var/turf/T in block(locate(1, 1, arena_z_level), locate(world.maxx, world.maxy, arena_z_level)))
		// Repair broken/damaged turfs
		if(istype(T, /turf/simulated/floor))
			var/turf/simulated/floor/F = T
			if(F.broken || F.burnt)
				F.make_plating(TRUE)
		if(istype(T, /turf/simulated/wall))
			var/turf/simulated/wall/W = T
			W.damage = 0
			W.update_icon()
		// Clean up dropped items (keep blood/casings)
		for(var/obj/item/I in T)
			if(istype(I, /obj/item/ammo_casing))
				continue
			qdel(I)

	// Replace damaged/missing window frames from snapshot
	var/recreated = 0
	var/skipped = 0
	for(var/list/data in saved_structures)
		var/turf/T = locate(data["x"], data["y"], arena_z_level)
		if(!T)
			continue
		// Check if the window frame still exists and is undamaged
		var/needs_replace = TRUE
		for(var/obj/structure/window_frame/WF in T)
			if(WF.frame_state == 1 /*FRAME_DESTROYED*/)
				continue // Destroyed frame, needs replacing
			if(WF.health < WF.max_health)
				continue // Damaged frame, needs replacing
			// Check if panes that should exist are missing
			if(WF.preset_outer_pane && !WF.outer_pane)
				continue // Missing outer pane
			if(WF.preset_inner_pane && !WF.inner_pane)
				continue // Missing inner pane
			// Frame is intact
			needs_replace = FALSE
			break
		if(!needs_replace)
			skipped++
			continue
		// Delete any damaged remnants on the tile
		for(var/obj/structure/window_frame/WF in T)
			qdel(WF)
		// Recreate fresh from snapshot
		var/obj_type = data["type"]
		var/obj/structure/window_frame/new_frame = new obj_type(T)
		if(new_frame)
			new_frame.dir = data["dir"]
			recreated++
		else
			log_game("Bombdefusal cleanup: FAILED to recreate [obj_type] at [data["x"]],[data["y"]]")
	announce_to_match("<span class='debug'>DEBUG: Window frames - [recreated] replaced, [skipped] intact (of [saved_structures.len] saved)</span>", "#FFAA00")

	// Repair doors in place (don't delete/recreate - avoids wide door crash)
	for(var/obj/machinery/door/D in SSmachines.machinery)
		if(D.z != arena_z_level)
			continue
		// Skip blast doors, shutters, and fire doors - they animate slowly and cause problems
		if(istype(D, /obj/machinery/door/blast) || istype(D, /obj/machinery/door/firedoor))
			continue
		D.health = D.maxhealth
		if(istype(D, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/A = D
			A.welded = FALSE
			A.locked = FALSE
		if(!D.density)
			// Force closed without animation to avoid slow cascade
			D.density = TRUE
			D.opacity = initial(D.opacity)
			D.update_icon()
			D.layer = D.closed_layer

/datum/bombdefusal_match/proc/start_round()
	current_round_num++
	bomb_planted = FALSE
	bomb_detonated = FALSE
	bomb_defused = FALSE

	// Set state FIRST to avoid getting stuck in ROUNDOVER if something below crashes
	match_state = BOMBDEFUSAL_STATE_FREEZE
	phase_end_time = world.time + mode.cfg_freeze_time
	round_start_time = world.time

	// Clean up old bomb(s) - delete ALL bombdefusal bombs on the arena z-level and in player inventories
	if(current_bomb && !QDELETED(current_bomb))
		qdel(current_bomb)
		current_bomb = null
	for(var/obj/item/bombdefusal_bomb/B in world)
		qdel(B)

	// Repair arena structural damage (keeps blood/casings)
	if(current_round_num > 1)
		cleanup_arena()

	// Reset players
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		pd.reset_for_round()
		spawn_player(pd)

	// Give bomb to random T
	var/list/t_members = current_t_team.get_alive_members()
	if(t_members.len)
		var/datum/bombdefusal_player_data/bomber = pick(t_members)
		if(bomber.owner && bomber.owner.current)
			current_bomb = new /obj/item/bombdefusal_bomb(get_turf(bomber.owner.current))
			current_bomb.match = src
			bomber.owner.current.put_in_hands(current_bomb)

	// Anchor all players to prevent movement (but allow item interaction)
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(pd.owner?.current)
			pd.owner.current.anchored = TRUE

	announce_to_match("<font size='4'><b>ROUND [current_round_num]</b></font>", "#FFD700")
	update_all_hud()

/datum/bombdefusal_match/proc/spawn_player(datum/bombdefusal_player_data/pd)
	if(!pd.owner)
		return

	// Find or recover the player's human body
	var/mob/living/carbon/human/H = null

	// Find the ghost if the player is ghosted
	var/mob/observer/ghost/player_ghost
	for(var/mob/observer/ghost/G in GLOB.player_list)
		if(G.ckey == pd.owner.key)
			player_ghost = G
			break

	if(ishuman(pd.owner.current) && pd.owner.current.client)
		H = pd.owner.current
	else
		// Player is ghosted or has no client on their body - find/reclaim the body
		if(pd.original_body && !QDELETED(pd.original_body))
			H = pd.original_body
		else if(ishuman(pd.owner.current))
			H = pd.owner.current
		else
			for(var/mob/living/carbon/human/body in GLOB.living_mob_list_ + GLOB.dead_mob_list_)
				if(body.mind == pd.owner || body.ckey == pd.owner.key)
					H = body
					break

		if(!H)
			// No body found - create a new one and restore saved appearance
			var/turf/spawn_loc = t_spawns.len ? pick(t_spawns) : locate(1, 1, arena_z_level)
			H = new /mob/living/carbon/human(spawn_loc)
			if(pd.saved_appearance)
				apply_saved_appearance(H, pd.saved_appearance)
			else if(pd.owner.name)
				H.real_name = pd.owner.name
				H.name = pd.owner.name

		// Force the player back into the body (same as reenter_corpse)
		if(player_ghost)
			H.key = player_ghost.key
			H.teleop = null
			qdel(player_ghost)
		else if(!H.mind || H.mind != pd.owner)
			pd.owner.transfer_to(H)

	if(!H)
		return

	// Store original body reference and save appearance on first spawn
	if(!pd.original_body || QDELETED(pd.original_body))
		pd.original_body = H
	if(!pd.saved_appearance)
		pd.saved_appearance = save_human_appearance(H)

	// Track if this player died last round BEFORE reviving (needs fresh equip)
	var/was_dead = pd.is_dead || (H.stat == DEAD)

	// Revive if dead (full revive happens later in arena_full_heal)
	if(H.stat == DEAD)
		H.revive()

	// Enable arena mode
	H.bombdefusal_arena_mode = TRUE

	// Initialize component lookup if missing (prevents signal errors on fresh/transferred mobs)
	if(!H.comp_lookup)
		H.comp_lookup = list()
	if(!H.signal_procs)
		H.signal_procs = list()

	// Teleport to team spawn FIRST
	var/list/spawns = (pd.team.current_side == BOMBDEFUSAL_TEAM_T) ? t_spawns : ct_spawns
	if(spawns.len)
		var/turf/spawn_turf = pick(spawns)
		H.forceMove(spawn_turf)
	else
		to_chat(H, "<span class='warning'>No spawn points found for your team!</span>")

	if(was_dead || current_round_num <= 1)
		// Dead players or first round: full re-equip with base outfit
		equip_player(pd)
	// Surviving players keep their purchased weapons between rounds

	// Full heal regardless
	H.arena_full_heal()

	// Setup HUD
	setup_player_hud(pd)

// Copy appearance (hair, skin, eyes, name, gender, species, body build) from one human to another
/proc/save_human_appearance(mob/living/carbon/human/H)
	if(!H)
		return null
	var/list/data = list()
	data["real_name"] = H.real_name
	data["name"] = H.name
	data["gender"] = H.gender
	data["h_style"] = H.h_style
	data["r_hair"] = H.r_hair
	data["g_hair"] = H.g_hair
	data["b_hair"] = H.b_hair
	data["r_s_hair"] = H.r_s_hair
	data["g_s_hair"] = H.g_s_hair
	data["b_s_hair"] = H.b_s_hair
	data["f_style"] = H.f_style
	data["r_facial"] = H.r_facial
	data["g_facial"] = H.g_facial
	data["b_facial"] = H.b_facial
	data["r_eyes"] = H.r_eyes
	data["g_eyes"] = H.g_eyes
	data["b_eyes"] = H.b_eyes
	data["s_tone"] = H.s_tone
	data["s_base"] = H.s_base
	data["r_skin"] = H.r_skin
	data["g_skin"] = H.g_skin
	data["b_skin"] = H.b_skin
	data["body_build"] = H.body_build
	data["body_height"] = H.body_height
	data["size_multiplier"] = H.size_multiplier
	data["species_name"] = H.species?.name
	data["lip_style"] = H.lip_style
	return data

/proc/apply_saved_appearance(mob/living/carbon/human/target, list/data)
	if(!target || !data)
		return
	target.real_name = data["real_name"]
	target.name = data["name"]
	target.gender = data["gender"]
	target.h_style = data["h_style"]
	target.r_hair = data["r_hair"]
	target.g_hair = data["g_hair"]
	target.b_hair = data["b_hair"]
	target.r_s_hair = data["r_s_hair"]
	target.g_s_hair = data["g_s_hair"]
	target.b_s_hair = data["b_s_hair"]
	target.f_style = data["f_style"]
	target.r_facial = data["r_facial"]
	target.g_facial = data["g_facial"]
	target.b_facial = data["b_facial"]
	target.r_eyes = data["r_eyes"]
	target.g_eyes = data["g_eyes"]
	target.b_eyes = data["b_eyes"]
	target.s_tone = data["s_tone"]
	target.s_base = data["s_base"]
	target.r_skin = data["r_skin"]
	target.g_skin = data["g_skin"]
	target.b_skin = data["b_skin"]
	target.body_build = data["body_build"]
	target.body_height = data["body_height"]
	target.size_multiplier = data["size_multiplier"]
	if(data["species_name"])
		target.set_species(data["species_name"])
	target.lip_style = data["lip_style"]
	target.update_body()
	target.update_hair()
	target.update_icons()

/proc/copy_human_appearance(mob/living/carbon/human/source, mob/living/carbon/human/target)
	if(!source || !target)
		return
	// Name
	target.real_name = source.real_name
	target.name = source.name
	target.gender = source.gender
	// Hair
	target.h_style = source.h_style
	target.r_hair = source.r_hair
	target.g_hair = source.g_hair
	target.b_hair = source.b_hair
	target.r_s_hair = source.r_s_hair
	target.g_s_hair = source.g_s_hair
	target.b_s_hair = source.b_s_hair
	// Facial hair
	target.f_style = source.f_style
	target.r_facial = source.r_facial
	target.g_facial = source.g_facial
	target.b_facial = source.b_facial
	// Eyes
	target.r_eyes = source.r_eyes
	target.g_eyes = source.g_eyes
	target.b_eyes = source.b_eyes
	// Skin
	target.s_tone = source.s_tone
	target.s_base = source.s_base
	target.r_skin = source.r_skin
	target.g_skin = source.g_skin
	target.b_skin = source.b_skin
	// Body
	target.body_build = source.body_build
	target.body_height = source.body_height
	target.size_multiplier = source.size_multiplier
	// Species
	if(source.species)
		target.set_species(source.species.name)
	// Lipstick
	target.lip_style = source.lip_style
	// Update appearance
	target.update_body()
	target.update_hair()
	target.update_icons()

/datum/bombdefusal_match/proc/tick()
	switch(match_state)
		if(BOMBDEFUSAL_STATE_FREEZE)
			tick_freeze()
		if(BOMBDEFUSAL_STATE_BUY)
			tick_buy()
		if(BOMBDEFUSAL_STATE_LIVE)
			tick_live()
		if(BOMBDEFUSAL_STATE_ROUNDOVER)
			tick_roundover()
		if(BOMBDEFUSAL_STATE_HALFTIME)
			tick_halftime()

/datum/bombdefusal_match/proc/tick_freeze()
	if(world.time >= phase_end_time)
		// Transition to buy phase
		match_state = BOMBDEFUSAL_STATE_BUY
		phase_end_time = world.time + mode.cfg_buy_time
		announce_to_match("<b>BUY PHASE</b> - Purchase your equipment!", "#00FF00")
		// Open buy menu for all
		for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
			if(pd.owner && pd.owner.current && pd.owner.current.client)
				mode.show_buy_menu(pd.owner.current, pd)
	update_all_hud()

/datum/bombdefusal_match/proc/tick_buy()
	if(world.time >= phase_end_time)
		// Transition to live
		match_state = BOMBDEFUSAL_STATE_LIVE
		phase_end_time = world.time + mode.cfg_round_time
		announce_to_match("<font size='4'><b>GO! GO! GO!</b></font>", "#FF4444")
		// Unanchor all players - round is live
		for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
			if(pd.owner?.current)
				pd.owner.current.anchored = FALSE
				sound_to(pd.owner.current, sound('sound/csgo/ok-lets-go.mp3'))
	update_all_hud()

/datum/bombdefusal_match/proc/tick_live()
	// Check win conditions
	var/t_alive = current_t_team.get_alive_count()
	var/ct_alive = current_ct_team.get_alive_count()
	var/t_has_players = current_t_team.members.len > 0
	var/ct_has_players = current_ct_team.members.len > 0

	if(bomb_detonated)
		end_round(BOMBDEFUSAL_TEAM_T, "Bomb detonated!")
		return

	if(bomb_defused)
		end_round(BOMBDEFUSAL_TEAM_CT, "Bomb defused!")
		return

	// Only check elimination if the team actually has players
	if(t_has_players && t_alive <= 0)
		end_round(BOMBDEFUSAL_TEAM_CT, "Terrorists eliminated!")
		return

	if(ct_has_players && ct_alive <= 0)
		if(!bomb_planted)
			end_round(BOMBDEFUSAL_TEAM_T, "Counter-Terrorists eliminated!")
		// If bomb is planted and CTs dead, wait for bomb to detonate
		return

	// Timer expired
	if(world.time >= phase_end_time)
		if(bomb_planted)
			return // Bomb is still ticking, don't end yet
		end_round(BOMBDEFUSAL_TEAM_CT, "Time's up!")
		return

	update_all_hud()

/datum/bombdefusal_match/proc/end_round(winning_side, reason)
	match_state = BOMBDEFUSAL_STATE_ROUNDOVER
	phase_end_time = world.time + mode.cfg_roundover_delay

	// Update scores
	var/datum/bombdefusal_team/winning_team
	if(winning_side == BOMBDEFUSAL_TEAM_T)
		if(current_t_team == team_a)
			a_score++
			winning_team = team_a
		else
			b_score++
			winning_team = team_b
	else
		if(current_ct_team == team_a)
			a_score++
			winning_team = team_a
		else
			b_score++
			winning_team = team_b

	// Award money
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(pd.team == winning_team)
			pd.award_money(mode.cfg_money_round_win, mode.cfg_money_max)
			pd.loss_streak = 0
		else
			var/loss_bonus = min(pd.loss_streak, 4) * mode.cfg_money_loss_bonus
			pd.award_money(mode.cfg_money_round_loss + loss_bonus, mode.cfg_money_max)
			pd.loss_streak++

	var/win_text = winning_side == BOMBDEFUSAL_TEAM_T ? "TERRORISTS WIN" : "COUNTER-TERRORISTS WIN"
	var/win_color = winning_side == BOMBDEFUSAL_TEAM_T ? "#FF4444" : "#4444FF"
	var/win_sound = winning_side == BOMBDEFUSAL_TEAM_T ? 'sound/csgo/t-win.mp3' : 'sound/csgo/ct-win.mp3'
	announce_to_match("<font size='5'><b>[win_text]</b></font><br>[reason]", win_color)
	announce_to_match("Score: [team_a.name] [a_score] - [b_score] [team_b.name]", "#FFD700")
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(pd.owner?.current)
			sound_to(pd.owner.current, sound(win_sound))

/datum/bombdefusal_match/proc/tick_roundover()
	if(world.time < phase_end_time)
		return

	// Check for game over
	if(a_score >= mode.cfg_rounds_to_win || b_score >= mode.cfg_rounds_to_win)
		end_match()
		return

	// Check for halftime
	if(!halftime_done && current_round_num >= mode.cfg_rounds_per_half)
		do_halftime()
		return

	// Next round
	start_round()

/datum/bombdefusal_match/proc/tick_halftime()
	if(world.time < phase_end_time)
		return
	halftime_done = TRUE
	start_round()
	halftime_just_happened = FALSE

/datum/bombdefusal_match/proc/do_halftime()
	match_state = BOMBDEFUSAL_STATE_HALFTIME
	phase_end_time = world.time + mode.cfg_halftime_delay
	halftime_just_happened = TRUE

	// Swap sides
	var/temp = current_t_team
	current_t_team = current_ct_team
	current_ct_team = temp
	team_a.current_side = (team_a == current_t_team) ? BOMBDEFUSAL_TEAM_T : BOMBDEFUSAL_TEAM_CT
	team_b.current_side = (team_b == current_t_team) ? BOMBDEFUSAL_TEAM_T : BOMBDEFUSAL_TEAM_CT

	// Reset money and mark all players for re-equip (like a fresh half)
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		pd.money = mode.cfg_money_start
		pd.loss_streak = 0
		pd.is_dead = TRUE // Force re-equip on next round

	announce_to_match("<font size='4'><b>HALFTIME - SWITCHING SIDES</b></font>", "#FFD700")

/datum/bombdefusal_match/proc/end_match()
	match_state = BOMBDEFUSAL_STATE_GAMEOVER
	var/datum/bombdefusal_team/winner = get_winner()
	if(winner)
		announce_to_match("<font size='5'><b>[winner.name] WINS THE MATCH!</b></font><br>Final Score: [team_a.name] [a_score] - [b_score] [team_b.name]", "#FFD700")
	else
		announce_to_match("<font size='5'><b>MATCH OVER - DRAW!</b></font><br>Final Score: [team_a.name] [a_score] - [b_score] [team_b.name]", "#FFD700")

	// Clean up bomb
	if(current_bomb)
		qdel(current_bomb)
		current_bomb = null

/datum/bombdefusal_match/proc/get_winner()
	if(a_score > b_score)
		return team_a
	if(b_score > a_score)
		return team_b
	return null

/datum/bombdefusal_match/proc/on_player_death(mob/living/victim, mob/living/killer)
	var/datum/bombdefusal_player_data/victim_pd = mode.get_player_data_by_mob(victim)
	var/datum/bombdefusal_player_data/killer_pd = killer ? mode.get_player_data_by_mob(killer) : null

	if(!victim_pd)
		return

	// Check if team has a living medic for downed state
	var/has_medic = FALSE
	for(var/datum/bombdefusal_player_data/pd in victim_pd.team.members)
		if(pd == victim_pd)
			continue
		if(pd.role == BOMBDEFUSAL_ROLE_MEDIC && !pd.is_dead && !pd.is_downed)
			has_medic = TRUE
			break

	if(has_medic && !victim_pd.is_downed)
		// Enter downed state instead of dying
		victim_pd.is_downed = TRUE
		if(istype(victim, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = victim
			H.arena_full_heal()
			H.SetWeakened(9999)
			H.lying = TRUE
		to_chat(victim, "<span class='danger'><font size='4'>YOU ARE DOWN!</font> A medic can revive you. Bleedout in [mode.cfg_bleedout_time / 10] seconds.</span>")
		// Use spawn for delayed bleedout - track via downed_timer_id as world.time deadline
		victim_pd.downed_timer_id = world.time + mode.cfg_bleedout_time
		spawn(mode.cfg_bleedout_time)
			bleedout_player(victim_pd)
	else
		// Actual death
		victim_pd.is_dead = TRUE
		victim_pd.deaths++

	// Award killer
	if(killer_pd && killer_pd.team != victim_pd.team)
		killer_pd.kills++
		killer_pd.award_money(mode.cfg_money_kill, mode.cfg_money_max)

	// Killfeed
	var/killer_name = killer_pd ? (killer_pd.owner ? killer_pd.owner.name : "Unknown") : "World"
	var/victim_name = victim_pd.owner ? victim_pd.owner.name : "Unknown"
	add_killfeed_entry(killer_name, victim_name)
	announce_to_match("[killer_name] > [victim_name]", "#FFFFFF")

/datum/bombdefusal_match/proc/bleedout_player(datum/bombdefusal_player_data/pd)
	if(!pd || !pd.is_downed)
		return
	pd.is_downed = FALSE
	pd.is_dead = TRUE
	pd.deaths++
	pd.downed_timer_id = null

	if(pd.owner && pd.owner.current)
		to_chat(pd.owner.current, "<span class='danger'><font size='4'>You have bled out!</font></span>")
		var/mob/living/L = pd.owner.current
		if(istype(L))
			L.death()

/datum/bombdefusal_match/proc/revive_player(datum/bombdefusal_player_data/pd)
	if(!pd || !pd.is_downed)
		return FALSE
	pd.is_downed = FALSE
	pd.downed_timer_id = null // Clears the timer reference so spawn'd bleedout won't fire

	if(pd.owner && pd.owner.current && istype(pd.owner.current, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = pd.owner.current
		H.arena_full_heal()
		to_chat(H, "<span class='notice'><font size='4'>You have been revived!</font></span>")
	return TRUE

/datum/bombdefusal_match/proc/on_bomb_planted()
	bomb_planted = TRUE
	phase_end_time = world.time + mode.cfg_bomb_fuse
	// Big announcement + chat + sound
	show_announcement("THE BOMB HAS BEEN PLANTED", "#FF4444", 40)
	announce_to_match("<font size='4'><b>THE BOMB HAS BEEN PLANTED!</b></font>", "#FF4444")
	// Play CS:GO bomb planted sound to all players
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(pd.owner?.current)
			sound_to(pd.owner.current, sound('sound/csgo/bomb-has-been-planted.mp3'))
	// Award plant money
	if(current_bomb && current_bomb.planter)
		var/datum/bombdefusal_player_data/pd = mode.get_player_data_by_mob(current_bomb.planter)
		if(pd)
			pd.award_money(mode.cfg_money_bomb_plant, mode.cfg_money_max)

/datum/bombdefusal_match/proc/on_bomb_defused(mob/defuser)
	bomb_defused = TRUE
	show_announcement("BOMB DEFUSED", "#4444FF", 40)
	announce_to_match("<font size='4'><b>THE BOMB HAS BEEN DEFUSED!</b></font>", "#4444FF")
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(pd.owner?.current)
			sound_to(pd.owner.current, sound('sound/csgo/bomb-has-been-defused.mp3'))
	var/datum/bombdefusal_player_data/pd = mode.get_player_data_by_mob(defuser)
	if(pd)
		pd.award_money(mode.cfg_money_bomb_defuse, mode.cfg_money_max)

/datum/bombdefusal_match/proc/on_bomb_detonated()
	bomb_detonated = TRUE
	show_announcement("BOMB DETONATED", "#FF0000", 40)

/datum/bombdefusal_match/proc/announce_to_match(text, color = "#FFFFFF")
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(pd.owner && pd.owner.current)
			to_chat(pd.owner.current, "<font color='[color]'>[text]</font>")

