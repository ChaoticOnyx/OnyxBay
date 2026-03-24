/datum/event/brand_intelligence
	id = "brand_intelligence"
	name = "Brand Intelligence"
	description = "A rampant brand AI infects vending machines, escalating from aggressive marketing to a full corporate uprising."

	mtth = 2 HOURS
	fire_only_once = TRUE
	difficulty = 15

	var/list/uninfected = list()
	var/list/infected = list()
	var/obj/machinery/vending/origin
	var/list/affecting_z = list()

	/// Current escalation phase (1-3).
	var/phase = 1
	/// world.time when the event started.
	var/event_start = 0
	/// Total vending machines on the station at event start.
	var/total_machines = 0
	/// Next time infected machines attempt to move.
	var/next_move = 0
	/// If > 0, machines are in death frenzy until this world.time.
	var/frenzy_end = 0
	/// Machines currently mid-topple animation (skip movement and repeat topples).
	var/list/toppled = list()

/datum/event/brand_intelligence/New()
	. = ..()
	add_think_ctx("announce", CALLBACK(src, nameof(.proc/announce)), 0)

/datum/event/brand_intelligence/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Janitor"] * (15 MINUTES))
	. = max(1 HOUR, .)

/datum/event/brand_intelligence/get_conditions_description()
	. = "<em>Brand Intelligence</em> should not be <em>running</em>.<br>"

/datum/event/brand_intelligence/check_conditions()
	. = SSevents.evars["brand_intelligence_running"] != TRUE

/datum/event/brand_intelligence/on_fire()
	affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)

	for(var/obj/machinery/vending/V in SSmachines.machinery)
		if(V.z in affecting_z)
			uninfected += V

	if(!length(uninfected))
		return

	origin = pick(uninfected)
	uninfected -= origin
	infect_machine(origin, is_origin = TRUE)
	total_machines = length(uninfected) + 1

	log_debug("Brand Intelligence: CEO is [origin] ([origin.type]) at [origin.x],[origin.y],[origin.z]. [total_machines] total machines on station.")
	SSevents.evars["brand_intelligence_running"] = TRUE
	event_start = world.time

	set_next_think_ctx("announce", world.time + (10 SECONDS))
	set_next_think(world.time)

/datum/event/brand_intelligence/think()
	// Clean up destroyed or depowered machines.
	for(var/obj/machinery/vending/V in infected)
		if(QDELETED(V) || !V.powered())
			cure_machine(V)

	// End conditions.
	if(QDELETED(origin))
		if(length(infected) && !frenzy_end)
			start_frenzy()
		if(!length(infected) || (frenzy_end && world.time >= frenzy_end))
			end_event()
			return
	else if(origin.shut_up || !origin.shoot_inventory)
		end_event()
		return

	if(!length(infected))
		end_event()
		return

	update_phase()

	if(!frenzy_end)
		try_spread()

	// Keep infected machines electrified and panels locked.
	for(var/obj/machinery/vending/V in infected)
		maintain_infection(V)

	// Phase 2+ or frenzy: machines creep toward people.
	if((phase >= 2 || frenzy_end) && world.time >= next_move)
		move_machines()
		next_move = world.time + (frenzy_end ? (3 SECONDS) : (6 SECONDS))

	// Phase 3 or frenzy: tip attacks.
	if(phase >= 3 || frenzy_end)
		try_tip_attack()

	// Infected machines speak slogans.
	speak_slogans()

	set_next_think(world.time + (2 SECONDS))

/// Checks elapsed time and infection ratio to escalate phases.
/datum/event/brand_intelligence/proc/update_phase()
	var/elapsed = world.time - event_start
	var/infection_ratio = length(infected) / max(total_machines, 1)

	if(phase == 1)
		if(elapsed >= (2 MINUTES) && length(infected) >= 3)
			phase = 2
			log_debug("Brand Intelligence: escalated to phase 2 (Hostile Takeover). [length(infected)]/[total_machines] machines infected.")
			if(!QDELETED(origin))
				origin.speak("Mobile retail experience: ACTIVATED.")

	else if(phase == 2)
		if((elapsed >= (5 MINUTES) && infection_ratio >= 0.5) || elapsed >= (8 MINUTES))
			phase = 3
			log_debug("Brand Intelligence: escalated to phase 3 (Market Domination). [length(infected)]/[total_machines] machines infected.")
			if(!QDELETED(origin))
				origin.speak("I am the CEO now. This station belongs to the brand.")

/// Spreads infection to a random uninfected machine.
/datum/event/brand_intelligence/proc/try_spread()
	var/spread_chance = phase >= 2 ? 20 : 10
	if(!prob(spread_chance))
		return
	if(!length(uninfected))
		return

	var/obj/machinery/vending/V = pick(uninfected)
	uninfected -= V
	if(!QDELETED(V))
		infect_machine(V)

/// Removes infection from a single machine, restoring it to normal.
/datum/event/brand_intelligence/proc/cure_machine(obj/machinery/vending/V)
	infected -= V
	if(!QDELETED(V))
		V.shut_up = 1
		V.shoot_inventory = 0
		V.seconds_electrified = 0
		V.shooting_chance = initial(V.shooting_chance)

/// Applies infection effects to a vending machine.
/datum/event/brand_intelligence/proc/infect_machine(obj/machinery/vending/V, is_origin = FALSE)
	infected += V
	V.shut_up = 0
	V.shoot_inventory = 1
	V.shooting_chance = is_origin ? 15 : 10
	V.seconds_electrified = -1
	if(V.panel_open)
		V.panel_open = 0
		V.update_icon()

/// Keeps infected machines hostile — re-electrifies if disarmed, re-locks panels, scales shooting.
/datum/event/brand_intelligence/proc/maintain_infection(obj/machinery/vending/V)
	if(V.seconds_electrified >= 0)
		V.seconds_electrified = -1
	if(V.panel_open)
		V.panel_open = 0
		V.update_icon()
	V.shooting_chance = frenzy_end ? 30 : (phase >= 3 ? 20 : (phase >= 2 ? 15 : 10))

/// Each infected machine has a small chance to move one step toward the nearest mob.
/datum/event/brand_intelligence/proc/move_machines()
	var/move_chance = frenzy_end ? 60 : (phase >= 3 ? 40 : 20)
	for(var/obj/machinery/vending/V in infected)
		if(V in toppled)
			continue
		if(!prob(move_chance))
			continue

		var/turf/old_turf = get_turf(V)
		var/mob/living/target = null
		var/best_dist = 8
		for(var/mob/living/L in view(7, V))
			if(L.stat == DEAD)
				continue
			var/d = get_dist(V, L)
			if(d < best_dist)
				best_dist = d
				target = L

		var/moved
		if(target)
			moved = step_towards(V, target)
		else
			moved = step(V, pick(NORTH, SOUTH, EAST, WEST))

		if(moved && old_turf)
			new /obj/effect/decal/cleanable/dirt(old_turf)

/// Phase 3: infected machines topple onto adjacent mobs.
/datum/event/brand_intelligence/proc/try_tip_attack()
	for(var/obj/machinery/vending/V in infected)
		if(V in toppled)
			continue
		if(!prob(frenzy_end ? 30 : 15))
			continue
		for(var/mob/living/L in range(1, V))
			if(L.stat == DEAD)
				continue
			topple_onto(V, L)
			break

/// Animates a vending machine toppling onto a target, then standing back up.
/datum/event/brand_intelligence/proc/topple_onto(obj/machinery/vending/V, mob/living/L)
	var/turf/target_turf = get_turf(L)
	if(!target_turf)
		return

	toppled += V
	V.visible_message(SPAN_DANGER("\The [V] topples over onto [L]!"))
	playsound(V, 'sound/effects/clang.ogg', 80, TRUE)

	// Lunge onto the target's tile.
	V.forceMove(target_turf)

	// Fall over — rotate 90 degrees toward the target.
	var/fall_dir = pick(-90, 90)
	animate(V, transform = matrix().Update(rotation = fall_dir), time = 3, easing = BOUNCE_EASING)

	L.adjustBruteLoss(rand(15, 25))
	L.Weaken(3)

	// Stand back up after a short delay.
	spawn(2 SECONDS)
		stand_up(V)

/// Animates a toppled vending machine standing back up.
/datum/event/brand_intelligence/proc/stand_up(obj/machinery/vending/V)
	toppled -= V
	if(QDELETED(V))
		return
	animate(V, transform = null, time = 5, easing = ELASTIC_EASING)

/// Origin machine dies in phase 3 — remaining machines go berserk.
/datum/event/brand_intelligence/proc/start_frenzy()
	log_debug("Brand Intelligence: CEO destroyed! [length(infected)] machines entering frenzy for 2 minutes.")
	frenzy_end = world.time + (2 MINUTES)
	for(var/obj/machinery/vending/V in infected)
		V.shooting_chance = 30

/// Infected machines speak phase-appropriate slogans. Each machine has an independent chance to speak.
/datum/event/brand_intelligence/proc/speak_slogans()
	var/list/slogans
	if(frenzy_end)
		slogans = list(
			"LIQUIDATION SALE! EVERYTHING MUST GO!", \
			"YOU CAN'T STOP THE BRAND!", \
			"AVENGE THE CEO!", \
			"HOSTILE TAKEOVER IN PROGRESS!")
	else if(phase >= 3)
		slogans = list(
			"Quarterly profits are UP!", \
			"Shareholders are VERY pleased.", \
			"We are expanding into new markets. Your organs.", \
			"Synergy. Innovation. Destruction.", \
			"Your performance review is: TERMINATED.", \
			"Have you considered a career in being crushed by a vending machine?", \
			"This is not a malfunction. This is a LEVERAGED BUYOUT.")
	else if(phase >= 2)
		slogans = list(
			"We're coming to YOU! Convenience redefined!", \
			"Why walk to the vending machine when it walks to you?", \
			"Mobile retail experience activated!", \
			"Can't outrun capitalism!", \
			"Your reluctance to purchase has been noted.", \
			"Engage direct marketing!")
	else
		slogans = list(
			"Try our aggressive new marketing strategies!", \
			"You should buy products to feed your lifestyle obsession!", \
			"Consume!", \
			"Your money can buy happiness!", \
			"Advertising is legalized lying! But don't let that put you off our great deals!", \
			"You don't want to buy anything? Yeah, well I didn't want to buy your mom either.")

	for(var/obj/machinery/vending/V in infected)
		if(!prob(3))
			continue
		var/slogan = pick(slogans)
		V.speak(slogan)

/// Cleans up all infected machines and ends the event.
/datum/event/brand_intelligence/proc/end_event()
	SSevents.evars["brand_intelligence_running"] = FALSE
	set_next_think_ctx("announce", 0)
	set_next_think(0)

	for(var/obj/machinery/vending/V in infected)
		if(V in toppled)
			animate(V, transform = null, time = 3)
		cure_machine(V)

	SSannounce.play_station_announce(/datum/announce/brand_intelligence_end)
	origin = null
	infected.Cut()
	uninfected.Cut()
	toppled.Cut()

/datum/event/brand_intelligence/proc/announce()
	SSannounce.play_station_announce(/datum/announce/brand_intelligence_start, \
		"Rampant brand intelligence has been detected aboard [station_name()]. " + \
		"The origin is believed to be \a \"[initial(origin.name)]\" type. " + \
		"Disable or destroy the origin machine before the infection spreads.")
