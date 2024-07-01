#define ONE_LOG_BURN_TIME (2 MINUTES)

/obj/structure/bonfire
	name = "bonfire"
	desc = "For grilling, broiling, charring, smoking, heating, roasting, toasting, simmering, searing, melting, and occasionally burning things."
	icon = 'icons/obj/bonfire.dmi'
	icon_state = "bonfire"
	light_color = LIGHT_COLOR_FIRE
	density = FALSE
	anchored = TRUE
	buckle_lying = 0
	var/burning = 0
	var/grill = FALSE
	var/fire_stack_strength = 5
	var/atom/movable/particle_emitter/fire_smoke/smoke_particles

/obj/structure/bonfire/Destroy()
	QDEL_NULL(smoke_particles)
	return ..()

/obj/structure/bonfire/dense
	density = TRUE

/obj/structure/bonfire/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_TABLE)
		return TRUE

	if(istype(mover) && mover.throwing)
		return TRUE

	return ..()

/obj/structure/bonfire/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/rods) && !can_buckle && !grill)
		var/obj/item/stack/rods/R = W
		R.use(1)
		can_buckle = TRUE
		buckle_require_restraints = TRUE
		show_splash_text(user, "Rod added", SPAN_NOTICE("You add a rod to \the [src]."))
		var/image/stake = image('icons/obj/bonfire.dmi', "bonfire_rod")
		stake.pixel_y = 16
		stake.layer = layer + 0.1
		dir = 2
		underlays += stake
		return

	if(W.get_temperature_as_from_ignitor())
		start_burning()
		return

	return ..()

/obj/structure/bonfire/proc/onDismantle()
	if(can_buckle || grill)
		new /obj/item/stack/rods(loc, 1)

/obj/structure/bonfire/attack_hand(mob/user)
	if(burning)
		show_splash_text(user, "Extinguish first!", SPAN_WARNING("You need to extinguish [src] before removing it!"))
		return

	if(do_after(user, 50, target = src) && !QDELETED(src))
		onDismantle()
		qdel_self()
		return

	return ..()

/obj/structure/bonfire/proc/CheckOxygen()
	var/datum/gas_mixture/G = loc.return_air()
	if(G.get_by_flag(XGM_GAS_OXIDIZER) > 1)
		return TRUE

	return FALSE

/obj/structure/bonfire/proc/start_burning()
	if(burning || !CheckOxygen())
		return

	icon_state = "bonfire_on_fire"
	burning = TRUE
	set_light(1, 0.1, 3, 2, LIGHT_COLOR_FIRE)
	particles = new /particles/bonfire()
	new /atom/movable/particle_emitter/fire_smoke(get_turf(src))
	burn()
	set_next_think(world.time + 1 SECOND)

/obj/structure/bonfire/fire_act()
	start_burning()
	return ..()

/obj/structure/bonfire/Crossed(atom/movable/AM)
	. = ..()
	if(burning & !grill)
		burn()

/obj/structure/bonfire/proc/burn()
	var/turf/current_location = get_turf(src)
	current_location.hotspot_expose(1000, 500)
	for(var/A in current_location)
		if(A == src)
			continue

		if(isobj(A))
			var/obj/O = A
			O.fire_act(1000, 500)
		else if (iscarbon(A))
			var/mob/living/carbon/C = A
			if(prob(20) && C.can_feel_pain())
				C.emote("scream_long")
			C.adjust_fire_stacks(fire_stack_strength)
			C.IgniteMob()
		else if(isliving(A))
			var/mob/living/L = A
			if(prob(20))
				L.emote("scream")
			L.adjust_fire_stacks(fire_stack_strength)
			L.IgniteMob()

/obj/structure/bonfire/think()
	if(!CheckOxygen())
		extinguish()
		return

	burn()
	set_next_think(world.time + 1 SECOND)

/obj/structure/bonfire/proc/extinguish()
	if(burning)
		icon_state = "bonfire"
		burning = FALSE
		set_light(0)
		QDEL_NULL(particles)
		QDEL_NULL(smoke_particles)
		set_next_think(0)

/obj/structure/bonfire/post_buckle_mob(mob/living/M)
	if(buckled_mob == M)
		M.pixel_y = 13
		M.layer = ABOVE_HUMAN_LAYER
	else
		if(M.pixel_y == 13)
			M.pixel_y = M.default_pixel_y
		M.layer = ABOVE_HUMAN_LAYER

/obj/structure/bonfire/dynamic
	desc = "For grilling, broiling, charring, smoking, heating, roasting, toasting, simmering, searing, melting, and occasionally burning things."
	var/last_time_smoke = 0
	var/logs = 10
	var/time_log_burned_out = 0

/obj/structure/bonfire/dynamic/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/material/wood))
		var/obj/item/stack/material/wood/G = W
		if(G.amount > 0)
			G.use(1)
			logs++
			show_splash_text(user, "Log added", SPAN_NOTICE("You have added log to the bonfire. Now it has [logs] logs."))
			if(logs > 0 && burning && icon_state != "bonfire_on_fire")
				icon_state = "bonfire_on_fire"
		return

	return ..()

/obj/structure/bonfire/dynamic/burn()
	var/turf/current_location = get_turf(src)
	var/datum/gas_mixture/GM = current_location.return_air()
	current_location.assume_gas("oxygen", -0.5)
	if(GM.temperature >= 393)
		current_location.assume_gas("carbon_dioxide", 0.5)
	else
		current_location.assume_gas("carbon_dioxide", 0.5, (GM.temperature + 200))
	current_location.hotspot_expose(1000, 500)
	return ..()

/obj/structure/bonfire/dynamic/onDismantle()
	new /obj/item/stack/material/wood(loc, logs)
	return ..()

/obj/structure/bonfire/dynamic/extinguish()
	..()
	if(logs == 0)
		new /obj/effect/decal/cleanable/ash(loc)
		qdel_self()

/obj/structure/bonfire/dynamic/think()
	if(logs < 1 && icon_state != "bonfire_warm")
		icon_state = "bonfire_warm"
	if(world.time > time_log_burned_out)
		if (logs > 0)
			logs--
			if(prob(40))
				new /obj/effect/decal/cleanable/ash(loc)
			time_log_burned_out = world.time + ONE_LOG_BURN_TIME
		else
			extinguish()

	return ..()

/obj/structure/bonfire/dynamic/examine(mob/user, infix)
	. = ..()
	if(get_dist(src, user) <= 2)
		. += SPAN_NOTICE("There [logs == 1 ? "is" : "are"] [logs] log[logs == 1 ? "" : "s"] in [src]")

#undef ONE_LOG_BURN_TIME
