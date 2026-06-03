// ========== BOMB DEFUSAL - BOMB & LANDMARKS ==========

// ===== ARENA AREA =====
// Custom area that guarantees gravity, power, and light - unlike /area/space which hardcodes has_gravity() to FALSE

/area/bombdefusal_arena
	name = "Bomb Defusal Arena"
	icon_state = "green"
	requires_power = FALSE
	always_unpowered = FALSE
	has_gravity = TRUE
	gravity_state = AREA_GRAVITY_ALWAYS
	lightswitch = TRUE
	dynamic_lighting = TRUE

// ===== LANDMARKS =====

/obj/effect/landmark/bombdefusal
	icon = 'icons/effects/csgo/landmark_icons.dmi'
	icon_state = "site_a"
	should_be_added = TRUE

/obj/effect/landmark/bombdefusal/t_spawn
	name = "Terrorist Spawn"
	icon_state = "t_spawn"

/obj/effect/landmark/bombdefusal/ct_spawn
	name = "Counter-Terrorist Spawn"
	icon_state = "ct_spawn"

/obj/effect/landmark/bombdefusal/arrow_a
	name = "Arrow to Site A"
	icon_state = "arrow_a"

/obj/effect/landmark/bombdefusal/arrow_b
	name = "Arrow to Site B"
	icon_state = "arrow_b"

/obj/effect/landmark/bombdefusal/bombsite
	name = "Bomb Site"
	var/site_id = "A"
	icon_state = "site_a"

/obj/effect/landmark/bombdefusal/bombsite/a
	site_id = "A"
	name = "Bomb Site A"
	icon_state = "site_a"

/obj/effect/landmark/bombdefusal/bombsite/b
	site_id = "B"
	name = "Bomb Site B"
	icon_state = "site_b"

// ===== BOMBSITE DECALS =====

/obj/effect/decal/bombdefusal
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	layer = TURF_LAYER + 0.1

/obj/effect/decal/bombdefusal/border
	name = "bomb site border"
	icon = 'icons/effects/csgo/bombsite.dmi'
	icon_state = "border"

/obj/effect/decal/bombdefusal/plant_x
	name = "bomb plant spot"
	icon = 'icons/effects/csgo/bombsite.dmi'
	icon_state = "plant_x"

/obj/effect/decal/bombdefusal/site_a
	name = "bomb site A"
	icon = 'icons/effects/csgo/site_markers.dmi'
	icon_state = "site_a"

/obj/effect/decal/bombdefusal/site_b
	name = "bomb site B"
	icon = 'icons/effects/csgo/site_markers.dmi'
	icon_state = "site_b"

/obj/effect/decal/bombdefusal/t_spawn
	name = "T spawn"
	icon = 'icons/effects/csgo/site_markers.dmi'
	icon_state = "t_spawn"

/obj/effect/decal/bombdefusal/ct_spawn
	name = "CT spawn"
	icon = 'icons/effects/csgo/site_markers.dmi'
	icon_state = "ct_spawn"

/obj/effect/decal/bombdefusal/arrow_a
	name = "arrow to site A"
	icon = 'icons/effects/csgo/arrows.dmi'
	icon_state = "arrow_a"

/obj/effect/decal/bombdefusal/arrow_b
	name = "arrow to site B"
	icon = 'icons/effects/csgo/arrows.dmi'
	icon_state = "arrow_b"

// Spawn corner borders + center X + site letter around a bombsite landmark
/proc/spawn_bombsite_decals(turf/T, site_id = "A")
	if(!T)
		return
	// Plant X on center
	new /obj/effect/decal/bombdefusal/plant_x(T)
	// Corner brackets at the 4 corners of a 5x5 zone (±2 from center)
	// border dirs: N=top-left, S=bottom-right, E=top-right, W=bottom-left
	var/list/corners = list(
		list("dx"=-2, "dy"= 2, "dir"=NORTH), // top-left
		list("dx"= 2, "dy"= 2, "dir"=EAST),  // top-right
		list("dx"=-2, "dy"=-2, "dir"=WEST),  // bottom-left
		list("dx"= 2, "dy"=-2, "dir"=SOUTH)  // bottom-right
	)
	for(var/list/c in corners)
		var/turf/CT = locate(T.x + c["dx"], T.y + c["dy"], T.z)
		if(!CT)
			continue
		var/obj/effect/decal/bombdefusal/border/B = new(CT)
		B.dir = c["dir"]


// ===== BOMB =====

/obj/item/bombdefusal_bomb
	name = "C4 explosive"
	desc = "A timed explosive device. Plant it at a bomb site."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	w_class = ITEM_SIZE_NORMAL
	var/armed = FALSE
	var/defused = FALSE
	var/planting = FALSE
	var/defusing = FALSE
	var/mob/living/planter
	var/datum/bombdefusal_match/match
	var/detonate_at  // world.time when bomb will detonate

/obj/item/bombdefusal_bomb/attack_self(mob/user)
	if(armed || planting)
		return

	// Check if user is on T team
	if(!match || !match.mode)
		return
	var/datum/bombdefusal_player_data/pd = match.mode.get_player_data_by_mob(user)
	if(!pd || pd.team.current_side != BOMBDEFUSAL_TEAM_T)
		to_chat(user, "<span class='warning'>Only terrorists can plant the bomb!</span>")
		return

	// Check if near a bomb site (same z-level, within 2 tiles)
	var/near_site = FALSE
	var/turf/user_turf = get_turf(user)
	for(var/obj/effect/landmark/bombdefusal/bombsite/BS in match.bombsites)
		var/turf/bs_turf = get_turf(BS)
		if(bs_turf && user_turf && bs_turf.z == user_turf.z && get_dist(user, BS) <= 2)
			near_site = TRUE
			break

	if(!near_site)
		to_chat(user, "<span class='warning'>You must be near a bomb site to plant!</span>")
		return

	planting = TRUE
	to_chat(user, "<span class='notice'>Planting the bomb...</span>")
	if(do_after(user, match.mode.cfg_plant_time, src))
		if(QDELETED(src) || armed)
			planting = FALSE
			return
		// Plant the bomb
		armed = TRUE
		planter = user
		anchored = TRUE
		icon_state = "plastic-explosive2"
		user.drop(src)
		// Notify match
		match.on_bomb_planted()
		// Start blinking
		start_blink()
		// Start fuse timer and beeping
		detonate_at = world.time + match.mode.cfg_bomb_fuse
		start_beeping()
		spawn(match.mode.cfg_bomb_fuse)
			detonate()
	planting = FALSE

/obj/item/bombdefusal_bomb/attackby(obj/item/W, mob/user)
	if(!armed || defused || defusing)
		return ..()

	// Check if user is on CT team
	if(!match || !match.mode)
		return
	var/datum/bombdefusal_player_data/pd = match.mode.get_player_data_by_mob(user)
	if(!pd || pd.team.current_side != BOMBDEFUSAL_TEAM_CT)
		to_chat(user, "<span class='warning'>Only counter-terrorists can defuse the bomb!</span>")
		return

	defusing = TRUE
	var/has_kit = istype(W, /obj/item/wirecutters)
	var/defuse_time = match.mode.cfg_defuse_time
	if(has_kit)
		defuse_time = round(defuse_time / 2)
		to_chat(user, "<span class='notice'>Defusing with kit... ([defuse_time / 10]s)</span>")
	else
		to_chat(user, "<span class='notice'>Defusing without kit... ([defuse_time / 10]s)</span>")
	// Audible defuse sound - alerts nearby Ts
	playsound(src, 'sound/items/Wirecutter.ogg', 80, FALSE)
	// Announce to match that defuse is in progress
	match.announce_to_match("<font color='#4444FF'><b>The bomb is being defused!</b></font>", "#4444FF")
	start_defuse_beeping(defuse_time)
	if(do_after(user, defuse_time, src))
		if(QDELETED(src) || defused)
			defusing = FALSE
			return
		defused = TRUE
		match.on_bomb_defused(user)
	defusing = FALSE

/obj/item/bombdefusal_bomb/attack_hand(mob/user)
	if(armed && !defused)
		// CT trying to defuse with bare hands
		if(!match || !match.mode)
			return
		var/datum/bombdefusal_player_data/pd = match.mode.get_player_data_by_mob(user)
		if(pd && pd.team.current_side == BOMBDEFUSAL_TEAM_CT)
			attackby(null, user)
			return
	// Only Ts can pick up the bomb
	if(!armed && match?.mode)
		var/datum/bombdefusal_player_data/pd = match.mode.get_player_data_by_mob(user)
		if(!pd || pd.team.current_side != BOMBDEFUSAL_TEAM_T)
			to_chat(user, "<span class='warning'>Only terrorists can carry the bomb!</span>")
			return
	..()

/obj/item/bombdefusal_bomb/proc/start_blink()
	set waitfor = FALSE
	var/blink_on = TRUE
	while(!QDELETED(src) && armed && !defused)
		icon_state = blink_on ? "plastic-explosive2" : "plastic-explosive0"
		blink_on = !blink_on
		var/time_left = detonate_at - world.time
		if(time_left <= 0)
			return
		// Blink faster as time runs out
		var/fuse_total = match ? match.mode.cfg_bomb_fuse : 400
		var/fraction_left = clamp(time_left / fuse_total, 0, 1)
		var/blink_delay = max(2, fraction_left * 10) // 1s down to 0.2s
		sleep(blink_delay)

/obj/item/bombdefusal_bomb/proc/start_defuse_beeping(defuse_time)
	set waitfor = FALSE
	var/end_time = world.time + defuse_time
	while(!QDELETED(src) && defusing && !defused && world.time < end_time)
		playsound(src, 'sound/items/Wirecutter.ogg', 60, TRUE)
		sleep(15) // every 1.5 seconds

/obj/item/bombdefusal_bomb/proc/start_beeping()
	set waitfor = FALSE
	while(!QDELETED(src) && armed && !defused)
		var/time_left = detonate_at - world.time
		if(time_left <= 0)
			return
		// Beep interval: starts at 2s, goes down to 0.2s in the last few seconds
		var/fuse_total = match ? match.mode.cfg_bomb_fuse : 400
		var/fraction_left = clamp(time_left / fuse_total, 0, 1)
		var/interval = max(2, fraction_left * 20) // 20 ticks (2s) down to 2 ticks (0.2s)
		playsound(src, 'sound/machines/twobeep.ogg', 80, FALSE)
		sleep(interval)

/obj/item/bombdefusal_bomb/proc/detonate()
	if(defused || QDELETED(src))
		return
	var/turf/T = get_turf(src)
	if(T && match)
		// Visual flash + screen shake, kill nearby players only
		playsound(T, 'sound/effects/explosions/explosion1.ogg', 100, FALSE, 30)
		for(var/datum/bombdefusal_player_data/pd in match.team_a.members + match.team_b.members)
			if(pd.owner?.current)
				var/dist = get_dist(pd.owner.current, T)
				if(dist <= 20)
					shake_camera(pd.owner.current, 10, 5)
				// Kill players within blast radius
				if(dist <= 6 && isliving(pd.owner.current) && pd.owner.current.stat != DEAD)
					pd.owner.current.death()
		// Visual explosion effect (no structural damage)
		new /obj/effect/overlay/temp/explosion(T)
	// Notify match
	if(match)
		match.on_bomb_detonated()
