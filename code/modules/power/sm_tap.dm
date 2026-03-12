#define SM_TAP_CONVERSION_FACTOR 10000 // 10 kW produced per SM power unit drained per tick

/obj/machinery/power/sm_resonance_tap
	name = "Supermatter Resonance Tap"
	desc = "A device that siphons resonance energy directly from a supermatter crystal, converting it to electrical power. Higher tap levels increase output but drain the crystal faster."
	icon = 'icons/obj/turrets.dmi'
	icon_state = "tesla2"
	anchored = 0
	density = 1
	req_access = list(access_engine_equip)

	var/active = FALSE
	var/locked = FALSE
	var/tap_level = 3 // 1-5, adjusted with screwdriver when inactive
	var/last_power = 0
	var/last_power_new = 0
	var/health = 100  // degrades under resonance stress; repairable with welder before full failure
	var/melted = FALSE // permanent failure state, not repairable
	var/list/my_cracks = list() // resonance fractures spawned by this tap

/obj/machinery/power/sm_resonance_tap/Destroy()
	fade_cracks() // clean up any lingering resonance cracks before the tap is gone
	. = ..()

/obj/machinery/power/sm_resonance_tap/Process()
	if((stat & BROKEN) || melted)
		return

	last_power = last_power_new
	last_power_new = 0

	if(!active)
		return

	var/obj/machinery/power/supermatter/SM = locate(/obj/machinery/power/supermatter) in view(25, src)

	if(!SM || SM.power <= 0)
		return

	var/power_drained = SM.power * (tap_level * 0.005) // 0.5% to 2.5% per tap level
	SM.power = max(0, SM.power - power_drained)

	var/power_produced = power_drained * SM_TAP_CONVERSION_FACTOR
	add_avail(power_produced)
	last_power_new = power_produced

	// Arc visual from tap to SM — chaotic branching arcs
	// tap1/SM250 (drained≈1.25) → ~53 dmg; tap3/SM250 (≈3.75) → ~58 dmg
	// tap3/SM2000 (≈30) → ~110 dmg;  tap5/SM2000 (≈50) → 150 dmg (max)
	var/arc_state = tap_level >= 5 ? "sm_arc_supercharged" : "sm_arc"
	var/shock_damage = clamp(round(50 + power_drained * 2), 50, 150)
	do_arc_visuals(SM, arc_state, shock_damage)

	// Per-crack effects triggered on each tap shot
	var/crack_damage = clamp(round(shock_damage * 0.4), 20, 60)
	var/crack_arcs_fired = 0
	var/crack_effects_fired = 0
	for(var/obj/effect/decal/resonance_crack/C in my_cracks)
		if(QDELETED(C))
			my_cracks -= C
			continue
		var/turf/crack_turf = get_turf(C)

		// Arc discharge — max 2 per shot
		if(crack_arcs_fired < 2 && prob(20))
			crack_arcs_fired++
			var/turf/arc_target = sm_arc_endpoint(C, locate(clamp(crack_turf.x + rand(-3, 3), 1, world.maxx), clamp(crack_turf.y + rand(-3, 3), 1, world.maxy), z))
			if(arc_target && arc_target != crack_turf)
				INVOKE_ASYNC(C, /atom.proc/Beam, arc_target, arc_state, 'icons/effects/beam.dmi', 4, 10)
				for(var/turf/T in get_line(C, arc_target))
					for(var/mob/living/carbon/M in T)
						playsound(T, pick('sound/effects/electric/medium_spark1.ogg', 'sound/effects/electric/medium_spark2.ogg'), 60, 1)
						M.visible_message(SPAN_DANGER("A resonance fracture discharges at \the [M]!"), \
							SPAN_DANGER("A crack in the floor arcs through you!"))
						M.electrocute_act(crack_damage, src)
						break

		// Ambient effect — at most 2 cracks trigger one random effect per shot
		if(crack_effects_fired < 2 && prob(25))
			crack_effects_fired++
			switch(rand(1, 3))
				if(1) // Gravimetric micro-bleed
					for(var/obj/O in range(2, C))
						if(!O.anchored && !istype(O, /obj/machinery) && !istype(O, /obj/effect) && !ismob(O))
							O.throw_at_random(FALSE, 2, 1)
							break
				if(2) // Crystal fever trace
					for(var/mob/living/carbon/H in range(2, C))
						H.adjust_hallucination(3, 1)
				if(3) // Resonance sparks
					var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
					sparks.set_up(2, 0, C)
					sparks.start()

	// --- Resonance side-effects, all scaled by power_drained ---

	// Resonance Cracks: only at tap level 5, spread outward from the tap into adjacent floor tiles
	// Hard cap: at most 20 cracks per tap to bound damage_tick() loops and Process() iteration
	if(tap_level >= 5 && my_cracks.len < 50 && prob(clamp(round(power_drained * 1.5), 1, 75)))
		var/list/frontier = list()
		// First priority: cardinal tiles directly adjacent to the tap (no diagonals, no wall-hopping)
		var/turf/src_turf = get_turf(src)
		for(var/turf/simulated/floor/F in list(locate(src_turf.x+1,src_turf.y,src_turf.z), locate(src_turf.x-1,src_turf.y,src_turf.z), locate(src_turf.x,src_turf.y+1,src_turf.z), locate(src_turf.x,src_turf.y-1,src_turf.z)))
			if(!F || (locate(/obj/effect/decal/resonance_crack) in F))
				continue
			if(!F.density && !F.opacity)
				frontier += F
		// Once the immediate area is saturated, spread one cardinal step from existing cracks
		if(!frontier.len)
			for(var/obj/effect/decal/resonance_crack/C in my_cracks)
				if(QDELETED(C))
					continue
				var/turf/CT = get_turf(C)
				for(var/turf/simulated/floor/F in list(locate(CT.x+1,CT.y,CT.z), locate(CT.x-1,CT.y,CT.z), locate(CT.x,CT.y+1,CT.z), locate(CT.x,CT.y-1,CT.z)))
					if(!F || (locate(/obj/effect/decal/resonance_crack) in F) || (F in frontier))
						continue
					if(!F.density && !F.opacity)
						frontier += F
		if(frontier.len)
			var/obj/effect/decal/resonance_crack/crack = new(pick(frontier))
			crack.parent_tap = src
			my_cracks += crack

	// Gravimetric Bleed: resonance warps local gravity, flinging loose items
	// tap3/SM250: ~3% chance, range 3; tap5/SM2000: ~40% chance, range 15
	if(prob(clamp(round(power_drained * 0.8), 1, 40)))
		var/grav_range = clamp(round(3 + power_drained * 0.24), 3, 15)
		for(var/obj/O in range(grav_range, src))
			if(!O.anchored && !istype(O, /obj/machinery) && !istype(O, /obj/effect) && !ismob(O))
				O.throw_at_random(FALSE, grav_range, 1)
				break // one item per tick to avoid cascade

	// Crystal Fever: resonance field induces hallucinations in nearby unshielded personnel
	// tap3/SM250: ~4% chance, ~11 tick duration; tap5/SM2000: ~50% chance, ~150 tick duration
	if(prob(clamp(round(power_drained * 0.75), 1, 50)))
		for(var/mob/living/carbon/H in range(3, src))
			H.adjust_hallucination(round(power_drained * 3), round(power_drained * 0.5))

	// Backfire Sparks: arcing instability from the tap coil itself
	// tap3/SM250: ~2% chance; tap5/SM2000: ~25% chance
	if(prob(clamp(round(power_drained * 0.5), 1, 25)))
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(pick(2, 3, 4), 0, src)
		sparks.start()

	// Resonance stress when SM is already damaged — scales with how hard you're draining it
	// tap3/SM250: ~0.075/tick degradation; tap5/SM2000: ~1.0/tick (~100 ticks to failure)
	if(SM.damage > SM.warning_point)
		health -= power_drained * 0.02

	if(health <= 0)
		tap_break()

/obj/machinery/power/sm_resonance_tap/attack_hand(mob/user)
	if(anchored)
		if((stat & BROKEN) || melted)
			to_chat(user, SPAN_WARNING("The [src] is completely destroyed!"))
			return
		if(!locked)
			toggle_power()
			user.visible_message("[user.name] turns the [name] [active ? "on" : "off"].", \
				"You turn the [name] [active ? "on" : "off"].")
			return
		else
			to_chat(user, SPAN_WARNING("The controls are locked!"))
			return

/obj/machinery/power/sm_resonance_tap/attackby(obj/item/W, mob/user)
	if(isWrench(W))
		if(active)
			to_chat(user, SPAN_WARNING("Deactivate [src] before moving it."))
			return 1
		for(var/obj/machinery/power/sm_resonance_tap/R in get_turf(src))
			if(R != src)
				to_chat(user, SPAN_WARNING("You cannot install more than one resonance tap on the same spot."))
				return 1
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
		anchored = !anchored
		user.visible_message("[user.name] [anchored ? "secures" : "unsecures"] the [name].", \
			"You [anchored ? "secure" : "undo"] the external bolts.", \
			"You hear a ratchet")
		if(anchored && !(stat & BROKEN))
			connect_to_network()
		else
			disconnect_from_network()
		return 1
	else if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = W
		if(!welder.welding)
			to_chat(user, SPAN_WARNING("The welding tool must be lit to repair [src]."))
			return 1
		if(melted)
			to_chat(user, SPAN_WARNING("[src] is burned out beyond repair."))
			return 1
		if(health >= 100)
			to_chat(user, SPAN_NOTICE("[src] doesn't need repairs."))
			return 1
		if(welder.remove_fuel(1, user))
			health = min(100, health + 25)
			to_chat(user, SPAN_NOTICE("You repair [src]. Integrity: [health]%"))
			update_icon()
		return 1
	else if(istype(W, /obj/item/screwdriver))
		if(active)
			to_chat(user, SPAN_WARNING("Cannot adjust the tap level while active."))
			return 1
		tap_level = (tap_level % 5) + 1
		to_chat(user, SPAN_NOTICE("Tap level set to [tap_level]/5."))
		return 1
	else if(istype(W, /obj/item/card/id) || istype(W, /obj/item/device/pda))
		if(allowed(user))
			if(active)
				locked = !locked
				to_chat(user, "The controls are now [locked ? "locked." : "unlocked."]")
			else
				locked = 0
				to_chat(user, SPAN_WARNING("The controls can only be locked when [src] is active."))
		else
			to_chat(user, SPAN_WARNING("Access denied!"))
		return 1
	return ..()

/obj/machinery/power/sm_resonance_tap/examine(mob/user, infix)
	. = ..()
	if(get_dist(user, src) > 3 || (stat & BROKEN))
		return
	. += "Sensor readings:"
	. += "Power output: [fmt_siunit(last_power, "W", 3)]"
	. += "Tap level: [tap_level]/5"
	. += "Integrity: [health]%"

/obj/machinery/power/sm_resonance_tap/proc/do_arc_visuals(obj/machinery/power/supermatter/SM, arc_state, shock_damage)
	// Each concurrent Beam call from the same source deletes the other's overlays every tick.
	// Fix: use a temporary relay object as the midpoint source so every segment has a unique source.
	// Relay is picked from the middle third of the actual clear path between src and SM,
	// so the two beam segments never cross a wall.
	var/list/arc_path = get_line(src, SM)
	var/path_len = arc_path.len
	var/turf/mid_turf = arc_path[clamp(round(path_len * rand(30, 70) / 100), 2, max(path_len - 1, 2))]
	var/obj/effect/sm_arc_relay/relay = new(mid_turf)

	// src → relay (seg 1), relay → SM (seg 2): two segments, two unique sources, zigzag arc
	INVOKE_ASYNC(src, /atom.proc/Beam, relay, arc_state, 'icons/effects/beam.dmi', 5, 30)
	INVOKE_ASYNC(relay, /atom.proc/Beam, SM, arc_state, 'icons/effects/beam.dmi', 5, 30)

	// Corona discharge from SM — always uses a relay to avoid source conflict with other taps' coronas
	var/obj/effect/sm_arc_relay/relay_corona = new(get_turf(SM))
	var/turf/corona = sm_arc_endpoint(SM, locate(clamp(SM.x + rand(-4, 4), 1, world.maxx), clamp(SM.y + rand(-4, 4), 1, world.maxy), z))
	if(corona && corona != get_turf(SM))
		INVOKE_ASYNC(relay_corona, /atom.proc/Beam, corona, arc_state, 'icons/effects/beam.dmi', 3, 10)
	else
		corona = null // null it out so the damage path below is skipped too
	spawn(7) qdel(relay_corona)

	// At tap 3+ a second corona branch fires from its own relay
	var/turf/corona2_target
	if(tap_level >= 3)
		var/obj/effect/sm_arc_relay/relay2 = new(get_turf(SM))
		corona2_target = sm_arc_endpoint(SM, locate(clamp(SM.x + rand(-3, 3), 1, world.maxx), clamp(SM.y + rand(-3, 3), 1, world.maxy), z)) // shorter than corona1
		if(corona2_target && corona2_target != get_turf(SM))
			INVOKE_ASYNC(relay2, /atom.proc/Beam, corona2_target, arc_state, 'icons/effects/beam.dmi', 3, 10)
		else
			corona2_target = null
		spawn(7) qdel(relay2)

	spawn(7) qdel(relay)

	// Damage anyone caught on any arc path (zigzag main arc + corona branches)
	var/list/already_shocked = list()
	var/list/paths = list(arc_path) // reuse the already-computed full path src→SM
	if(corona)
		paths += list(get_line(SM, corona))
	if(corona2_target)
		paths += list(get_line(SM, corona2_target))
	for(var/list/path in paths)
		for(var/turf/T in path)
			for(var/mob/living/carbon/M in T)
				if(M in already_shocked)
					continue
				if(!can_see(M, src, 35)) // don't shock mobs behind walls — mob LOS is reliable
					continue
				already_shocked += M
				playsound(T, pick('sound/effects/electric/medium_spark1.ogg', 'sound/effects/electric/medium_spark2.ogg'), 75, 1)
				M.visible_message(SPAN_DANGER("\The [src]'s resonance arc lashes out at [M]!"), \
					SPAN_DANGER("A resonance arc burns through you!"))
				M.electrocute_act(shock_damage, src)

/obj/machinery/power/sm_resonance_tap/proc/toggle_power()
	active = !active
	if(!active)
		fade_cracks()
	update_icon()

/obj/machinery/power/sm_resonance_tap/proc/fade_cracks()
	// Farthest cracks fade first, retreating back toward the tap
	// Stagger scales with spread: 12s at 3 tiles, up to ~2 minutes at large spreads
	var/max_dist = 0
	for(var/obj/effect/decal/resonance_crack/C in my_cracks)
		if(!QDELETED(C))
			max_dist = max(max_dist, get_dist(src, C))
	var/stagger_window = max_dist > 0 ? clamp(round(max_dist / 3 * 120), 120, 1200) : 0
	for(var/obj/effect/decal/resonance_crack/C in my_cracks)
		if(QDELETED(C))
			continue
		var/delay = max_dist > 0 ? round((max_dist - get_dist(src, C)) / max_dist * stagger_window) : 0
		spawn(delay) if(!QDELETED(C)) C.start_fading()
	// my_cracks is cleared immediately — spawn closures hold their own C references,
	// so clearing the list before the timers fire is intentional and not a race condition
	my_cracks = list()

/obj/machinery/power/sm_resonance_tap/proc/tap_break()
	fade_cracks()
	disconnect_from_network()
	stat |= BROKEN
	melted = TRUE
	anchored = FALSE
	active = FALSE
	desc += " It has been burned out by resonance feedback."
	explosion(get_turf(src), -1, 0, 1)
	update_icon()

/obj/machinery/power/sm_resonance_tap/on_update_icon()
	if(melted)
		icon_state = "tesla1" // burnt-out static coil
		return
	if(active)
		icon_state = "tesla3" // 5-frame discharge animation: 15t idle + quick flash
	else
		icon_state = "tesla2" // static coil, unpowered

/obj/machinery/power/sm_resonance_tap/ex_act(severity)
	switch(severity)
		if(1, 2)
			tap_break()
		if(3)
			health -= 40
			if(health <= 0)
				tap_break()
			else
				update_icon()
		if(4)
			health -= 15
			if(health <= 0)
				tap_break()
			else
				update_icon()

// Resonance fracture — SM energy bleeding through the floor, fades on its own
/obj/effect/decal/resonance_crack
	name = "resonance fracture"
	desc = "A crack where resonance energy has bled through the floor. Standing on it is probably a bad idea."
	icon = 'icons/mob/psychic_glitch.dmi'
	icon_state = "rift1"
	density = 0
	anchored = 1
	mouse_opacity = 0
	layer = DECAL_PLATING_LAYER
	var/obj/machinery/power/sm_resonance_tap/parent_tap
	var/fading = FALSE

/obj/effect/decal/resonance_crack/Initialize()
	. = ..()
	set_light(0.3, 0.2, 1)
	INVOKE_ASYNC(src, .proc/damage_tick)

/obj/effect/decal/resonance_crack/proc/damage_tick()
	while(!QDELETED(src))
		sleep(20) // every 2 seconds
		var/turf/T = get_turf(src)

		// Burn anyone standing directly on the crack
		var/list/mobs_here = list()
		for(var/mob/living/M in T)
			mobs_here += M
		if(mobs_here.len)
			playsound(T, 'sound/effects/weapons/energy/resonator_fire.ogg', 50, 1)
		for(var/mob/living/M in mobs_here)
			M.adjustFireLoss(10)
			M.visible_message(SPAN_DANGER("\The [M] is seared by resonance energy!"), \
				SPAN_DANGER("The fracture is burning through your body!"))

/obj/effect/decal/resonance_crack/proc/start_fading()
	if(fading) return
	fading = TRUE
	INVOKE_ASYNC(src, .proc/fade)

/obj/effect/decal/resonance_crack/proc/fade()
	if(QDELETED(src)) return
	sleep(120) // ~12 seconds after tap deactivates
	if(QDELETED(src)) return
	if(parent_tap && !QDELETED(parent_tap) && parent_tap.active)
		// tap was re-enabled — stay alive and re-register so we're tracked again
		parent_tap.my_cracks |= src
		fading = FALSE
		return
	qdel(src)

// Walks the line from A toward B and returns the last unblocked turf.
// The arc visual is clipped at the first wall/closed door rather than disappearing entirely.
/proc/sm_arc_endpoint(atom/A, atom/B)
	var/turf/last = get_turf(A)
	for(var/turf/T in get_line(A, B))
		if(T.opacity)
			return last
		var/obj/machinery/door/D = locate(/obj/machinery/door) in T
		if(D && D.opacity)
			return last
		last = T
	return last

// Invisible relay object used as an intermediate beam source to avoid the single-source
// cleanup conflict in /atom/proc/Beam — one relay per arc segment, deleted after ~0.7s
/obj/effect/sm_arc_relay
	name = "arc relay"
	anchored = 1
	mouse_opacity = 0
	alpha = 0
