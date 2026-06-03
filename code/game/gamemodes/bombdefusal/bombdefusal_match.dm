// ========== BOMB DEFUSAL - MATCH INSTANCE ==========

/datum/bombdefusal_match
	var/datum/game_mode/bombdefusal/mode
	var/datum/bombdefusal_team/team_a
	var/datum/bombdefusal_team/team_b
	var/a_score = 0
	var/b_score = 0
	var/current_round_num = 0
	var/halftime_done = FALSE
	var/match_state = BOMBDEFUSAL_STATE_LOBBY

	// Arena
	var/datum/bombdefusal_map/arena_map
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
		atmos.gas = list("oxygen" = MOLES_O2_STANDARD, "nitrogen" = MOLES_N2_STANDARD)
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
	var/map_path = mode.get_selected_map_path() // also picks random map if none set
	arena_map = mode.selected_map
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
		atmos.gas = list("oxygen" = MOLES_O2_STANDARD, "nitrogen" = MOLES_N2_STANDARD)
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

	// Spawn bombsite decals (corner brackets + site letter + plant X)
	for(var/obj/effect/landmark/bombdefusal/bombsite/BS in bombsites)
		spawn_bombsite_decals(get_turf(BS), BS.site_id)



	// Clear loading screen and notify players
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(pd.owner?.current)
			pd.owner.current.clear_fullscreen("bombdefusal_loading")
			to_chat(pd.owner.current, "<span class='notice'><b>Arena ready!</b> [t_spawns.len] T spawns, [ct_spawns.len] CT spawns, [bombsites.len] bomb sites.</span>")

/datum/bombdefusal_match/proc/deferred_start()
	spawn(5)
		start_match()

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

// Save window frame and barricade positions for round reset (doors are repaired in place)
/datum/bombdefusal_match/proc/save_arena_structures()
	saved_structures = list()
	for(var/turf/T in block(locate(1, 1, arena_z_level), locate(world.maxx, world.maxy, arena_z_level)))
		for(var/obj/structure/window_frame/WF in T)
			saved_structures += list(list("kind" = "window_frame", "type" = WF.type, "x" = T.x, "y" = T.y, "dir" = WF.dir))
		for(var/obj/structure/barricade/material/B in T)
			var/mat_name = B.material ? B.material.name : MATERIAL_WOOD
			saved_structures += list(list("kind" = "barricade", "type" = B.type, "x" = T.x, "y" = T.y, "dir" = B.dir, "material" = mat_name))
	log_game("Bombdefusal save_arena_structures: z=[arena_z_level], saved [saved_structures.len] structures")
	log_debug("Bombdefusal: Saved [saved_structures.len] structures for round reset (z=[arena_z_level])")

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
		// Clean up dropped items, blood, and casings
		for(var/obj/item/I in T)
			qdel(I)
		for(var/obj/effect/decal/cleanable/C in T)
			qdel(C)

	// Replace damaged/missing structures from snapshot
	var/recreated = 0
	var/skipped = 0
	for(var/list/data in saved_structures)
		var/turf/T = locate(data["x"], data["y"], arena_z_level)
		if(!T)
			continue

		switch(data["kind"])
			if("window_frame")
				var/needs_replace = TRUE
				for(var/obj/structure/window_frame/WF in T)
					if(WF.frame_state == 1 /*FRAME_DESTROYED*/)
						continue
					if(WF.health < WF.max_health)
						continue
					if(WF.preset_outer_pane && !WF.outer_pane)
						continue
					if(WF.preset_inner_pane && !WF.inner_pane)
						continue
					needs_replace = FALSE
					break
				if(!needs_replace)
					skipped++
					continue
				for(var/obj/structure/window_frame/WF in T)
					qdel(WF)
				var/obj_type = data["type"]
				var/obj/structure/window_frame/new_frame = new obj_type(T)
				if(new_frame)
					new_frame.dir = data["dir"]
					recreated++

			if("barricade")
				// Check if barricade still exists and is undamaged
				var/needs_replace = TRUE
				for(var/obj/structure/barricade/material/B in T)
					if(B.damage <= 0)
						needs_replace = FALSE
						break
				if(!needs_replace)
					skipped++
					continue
				for(var/obj/structure/barricade/material/B in T)
					qdel(B)
				var/barricade_type = data["type"]
				var/barricade_mat = data["material"]
				var/obj/structure/barricade/material/new_barricade = new barricade_type(T, barricade_mat)
				if(new_barricade)
					new_barricade.dir = data["dir"]
					recreated++

	log_debug("Bombdefusal: Structures - [recreated] replaced, [skipped] intact (of [saved_structures.len] saved)")

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

	// Clean up old bomb(s) on this arena's z-level
	if(current_bomb && !QDELETED(current_bomb))
		qdel(current_bomb)
		current_bomb = null
	for(var/obj/item/bombdefusal_bomb/B in world)
		var/turf/T = get_turf(B)
		if(T && T.z == arena_z_level)
			qdel(B)

	// Repair arena structural damage (keeps blood/casings)
	if(current_round_num > 1)
		cleanup_arena()

	// Reset and spawn players
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

	// Defer HUD setup to give clients time to attach after mind transfer
	spawn(3)
		for(var/datum/bombdefusal_player_data/hud_pd in team_a.members + team_b.members)
			setup_player_hud(hud_pd)
		update_all_hud()
		update_all_team_markers()

/datum/bombdefusal_match/proc/spawn_player(datum/bombdefusal_player_data/pd)
	if(!pd.owner)
		return

	// Save appearance from the original station body before creating an arena mob
	if(!pd.saved_appearance && ishuman(pd.owner.current) && !istype(pd.owner.current, /mob/living/carbon/human/bombdefusal))
		pd.saved_appearance = save_human_appearance(pd.owner.current)

	// Find or recover the player's bombdefusal human body
	var/mob/living/carbon/human/bombdefusal/H = null
	var/body_is_usable = TRUE

	// Check if existing body is alive and functional
	if(pd.original_body && !QDELETED(pd.original_body))
		if(pd.original_body.stat == DEAD)
			body_is_usable = FALSE
		else
			H = pd.original_body
	if(!H && istype(pd.owner.current, /mob/living/carbon/human/bombdefusal))
		if(pd.owner.current.stat == DEAD)
			body_is_usable = FALSE
		else
			H = pd.owner.current
	if(!H && body_is_usable)
		for(var/mob/living/carbon/human/bombdefusal/body in GLOB.living_mob_list_)
			if(body.mind == pd.owner || body.ckey == pd.owner.key)
				H = body
				break

	if(!H)
		// No usable body - create a fresh one
		var/list/team_spawns = (pd.team.current_side == BOMBDEFUSAL_TEAM_T) ? t_spawns : ct_spawns
		var/turf/spawn_loc = team_spawns.len ? pick(team_spawns) : (t_spawns.len ? pick(t_spawns) : locate(1, 1, arena_z_level))
		H = new /mob/living/carbon/human/bombdefusal/simplest(spawn_loc)
		if(pd.saved_appearance)
			apply_saved_appearance(H, pd.saved_appearance)
		else if(pd.owner.name)
			H.real_name = pd.owner.name
			H.name = pd.owner.name
		// Clean up the old damaged body so it doesn't linger
		if(pd.original_body && !QDELETED(pd.original_body) && pd.original_body != H)
			qdel(pd.original_body)
		pd.original_body = H
		// Fresh body has no gear, force re-equip
		pd.needs_reequip = TRUE

	// Transfer mind and client into the body.
	// transfer_to() skips the key assignment if mind.active == 0 (which happens
	// when a player ghostizes - Logout() on the old body sets active=0).
	// Force active=1 and also yank the key directly from whichever mob has it.
	var/mob/old_mob = pd.owner.current
	if(old_mob != H)
		pd.owner.active = 1
		pd.owner.transfer_to(H)
	// If the client is still on the old mob (ghost), move the key over
	if(old_mob && old_mob != H && old_mob.key)
		H.key = old_mob.key

	if(!H)
		return

	// Store body reference and save appearance if not yet saved
	pd.original_body = H
	if(!pd.saved_appearance)
		pd.saved_appearance = save_human_appearance(H)

	H.last_attacker_mind = null

	// Revive FIRST (sets stat = CONSCIOUS, clears stuns/weakened/paralysis)
	if(H.stat != CONSCIOUS)
		H.revive()
		// If they were crit/dead, they need a fresh loadout — body/gear is unreliable
		pd.needs_reequip = TRUE

	// Now clear all incapacitating states so update_canmove() won't set lying back to TRUE
	H.SetWeakened(0)
	H.SetStunned(0)
	H.SetParalysis(0)
	H.SetSleeping(0)
	if(LAZYLEN(H.pinned))
		H.pinned.Cut()

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

	if(current_round_num <= 1 || pd.needs_reequip)
		// First round, died last round, or halftime: full outfit + fresh random look
		equip_player(pd)
		pd.needs_reequip = FALSE
	// Surviving players keep all their purchased weapons and gear

	// Full heal regardless
	H.arena_full_heal()

	// HUD setup is deferred to start_round after all players spawn (client may not be ready yet)

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


/datum/bombdefusal_match/proc/tick()
	switch(match_state)
		if(BOMBDEFUSAL_STATE_WARMUP)
			tick_warmup()
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

/datum/bombdefusal_match/proc/begin_warmup()
	match_state = BOMBDEFUSAL_STATE_WARMUP
	phase_end_time = world.time + 300 // 30 seconds
	announce_to_match("<font size='4'><b>MATCH STARTING IN 30 SECONDS</b></font>", "#FFD700")
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(pd.owner?.current)
			sound_to(pd.owner.current, sound('sound/csgo/golosovanie.mp3', volume = 40))

/datum/bombdefusal_match/proc/tick_warmup()
	var/time_left = max(0, round((phase_end_time - world.time) / 10))
	// Announce countdown at key intervals
	if(time_left == 10 || time_left == 5 || time_left == 3 || time_left == 2 || time_left == 1)
		announce_to_match("<font size='3'><b>Starting in [time_left]...</b></font>", "#FFD700")
	if(world.time >= phase_end_time)
		start_match()

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
		// Unanchor players - round is live, close buy menu
		// Apply per-map extra freeze to one side if configured
		var/t_extra = arena_map ? arena_map.t_extra_freeze : 0
		var/ct_extra = arena_map ? arena_map.ct_extra_freeze : 0
		for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
			if(pd.owner?.current)
				sound_to(pd.owner.current, sound('sound/csgo/ok-lets-go.mp3'))
				close_browser(pd.owner.current, "window=bombdefusal_buy")
				var/extra = (pd.team.current_side == BOMBDEFUSAL_TEAM_T) ? t_extra : ct_extra
				if(extra > 0)
					// Keep frozen, unfreeze after delay via mob ref to avoid closure capture bug
					var/mob/frozen_mob = pd.owner.current
					spawn(extra)
						if(frozen_mob && !QDELETED(frozen_mob) && match_state == BOMBDEFUSAL_STATE_LIVE)
							frozen_mob.anchored = FALSE
				else
					pd.owner.current.anchored = FALSE
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

	// Both teams empty (everyone disconnected) — end match
	if(!t_has_players && !ct_has_players)
		end_match()
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
		if(current_bomb && current_bomb.planting)
			return // Bomb is being planted, don't end yet
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
	log_debug("Bombdefusal: Halftime over, starting new round [current_round_num + 1]")
	start_round()
	log_debug("Bombdefusal: Post-halftime round started, state=[match_state]")

/datum/bombdefusal_match/proc/do_halftime()
	match_state = BOMBDEFUSAL_STATE_HALFTIME
	phase_end_time = world.time + mode.cfg_halftime_delay

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
		pd.needs_reequip = TRUE // Force re-equip on next round
		// Strip gear from living players so they get fresh loadout
		if(pd.owner?.current && !pd.owner.current.stat)
			strip_dead_player(pd.owner.current)

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

	// Return players to the station after a short delay
	spawn(50)
		return_players_to_station()

/datum/bombdefusal_match/proc/return_players_to_station()
	for(var/datum/bombdefusal_player_data/pd in team_a.members + team_b.members)
		if(!pd.owner)
			continue

		// Skip disconnected players — no client means no one to return
		if(!pd.owner.current?.client)
			// Just clean up the arena body
			if(pd.original_body && !QDELETED(pd.original_body))
				qdel(pd.original_body)
				pd.original_body = null
			continue

		// Find a spawn point on the station
		var/turf/spawn_loc
		if(GLOB.latejoin_cryo?.len)
			spawn_loc = pick(GLOB.latejoin_cryo)
		else if(GLOB.latejoin?.len)
			spawn_loc = pick(GLOB.latejoin)
		if(!spawn_loc)
			continue

		// Create a fresh station body with their original appearance
		var/mob/living/carbon/human/new_body = new(spawn_loc)
		if(pd.saved_appearance)
			apply_saved_appearance(new_body, pd.saved_appearance)
		else if(pd.owner.name)
			new_body.real_name = pd.owner.name
			new_body.name = pd.owner.name

		// Transfer mind (force active so key moves too)
		var/mob/old_mob = pd.owner.current
		pd.owner.active = 1
		pd.owner.transfer_to(new_body)
		if(old_mob && old_mob != new_body && old_mob.key)
			new_body.key = old_mob.key

		// Clean up the arena body
		if(pd.original_body && !QDELETED(pd.original_body))
			qdel(pd.original_body)
			pd.original_body = null

		to_chat(new_body, "<span class='notice'><b>Match over!</b> You have been returned to the station.</span>")

/datum/bombdefusal_match/proc/get_winner()
	if(a_score > b_score)
		return team_a
	if(b_score > a_score)
		return team_b
	return null

/datum/bombdefusal_match/proc/on_player_death(mob/living/victim, datum/mind/killer_mind, gibbed = FALSE)
	var/datum/bombdefusal_player_data/victim_pd = mode.get_player_data_by_mob(victim)
	var/datum/bombdefusal_player_data/killer_pd = killer_mind ? mode.get_player_data(killer_mind) : null

	if(!victim_pd)
		return

	// Already processed — bail out (death() can re-enter via bombdefusal/death override)
	if(victim_pd.is_dead)
		return

	// Actual death — no downed state, players die normally
	victim_pd.is_dead = TRUE
	victim_pd.needs_reequip = TRUE
	victim_pd.deaths++
	strip_dead_player(victim)

	// Award killer
	if(killer_pd && killer_pd.team != victim_pd.team)
		killer_pd.kills++
		killer_pd.award_money(mode.cfg_money_kill, mode.cfg_money_max)

	// Killfeed
	var/victim_name = victim_pd.owner ? victim_pd.owner.name : "Unknown"
	if(killer_pd && killer_pd == victim_pd)
		add_killfeed_entry(victim_name, victim_name)
		announce_to_match("[victim_name] killed themselves", "#FFFFFF")
	else
		var/killer_name = killer_pd ? (killer_pd.owner ? killer_pd.owner.name : "Unknown") : "World"
		add_killfeed_entry(killer_name, victim_name)
		announce_to_match("[killer_name] > [victim_name]", "#FFFFFF")

/datum/bombdefusal_match/proc/strip_dead_player(mob/living/victim)
	if(!istype(victim, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = victim

	// Drop the bomb to the floor first so it doesn't get deleted with the backpack
	var/turf/drop_loc = get_turf(H)
	for(var/obj/item/bombdefusal_bomb/B in H.get_contents())
		if(drop_loc)
			B.forceMove(drop_loc)
		else
			B.forceMove(H.loc)

	var/list/slots = list(
		slot_r_hand, slot_l_hand,
		slot_belt, slot_back,
		slot_wear_suit, slot_head,
		slot_wear_mask, slot_gloves, slot_shoes,
		slot_w_uniform
	)
	for(var/slot in slots)
		var/obj/item/I = H.get_equipped_item(slot)
		if(I)
			H.drop(I)
			qdel(I)

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
