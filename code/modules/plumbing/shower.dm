/// The volume of it's internal reagents the shower applies to everything it sprays.
#define SHOWER_SPRAY_VOLUME 5
/// How much the volume of the shower's spay reagents are amplified by when it sprays something.
#define SHOWER_EXPOSURE_MULTIPLIER 2 // Showers effectively double exposed reagents
/// How long we run in TIMED mode
#define SHOWER_TIMED_LENGTH (15 SECONDS)

/// Run the shower until we run out of reagents.
#define SHOWER_MODE_UNTIL_EMPTY 0
/// Run the shower for SHOWER_TIMED_LENGTH time, or until we run out of reagents.
#define SHOWER_MODE_TIMED 1
/// Run the shower forever, pausing when we run out of liquid, and then resuming later.
#define SHOWER_MODE_FOREVER 2
/// Number of modes to cycle through
#define SHOWER_MODE_COUNT 3

GLOBAL_LIST_INIT(shower_mode_descriptions, list(
	"[SHOWER_MODE_UNTIL_EMPTY]" = "run until empty",
	"[SHOWER_MODE_TIMED]" = "run for 15 seconds or until empty",
	"[SHOWER_MODE_FOREVER]" = "keep running forever and auto turn back on",
))

/obj/machinery/plumbing/shower
	name = "shower"
	desc = "The best in class HS-451 shower unit has three temperature settings, one more than the HS-450 which preceded it."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	anchored = TRUE
	use_power = 0
	layer = ABOVE_WINDOW_LAYER
	///Does the user want the shower on or off?
	var/intended_on = FALSE
	///Is the shower actually spitting out water currently
	var/actually_on = FALSE
	///What sound will be played on loop when the shower is on and pouring water.
	var/datum/looping_sound/showering/soundloop
	///What reagent should the shower be filled with when initially built.
	var/reagent_id = /datum/reagent/water
	///Which mode the shower is operating in.
	var/mode = SHOWER_MODE_UNTIL_EMPTY
	var/reagent_capacity = 200
	var/list/temperature_settings = list("normal" = 35 CELSIUS, "boiling" = 100 CELSIUS, "freezing" = (0 CELSIUS))
	///What temperature the shower reagents are set to.
	var/current_temperature = "normal"

/obj/machinery/plumbing/shower/Initialize(mapload)
	. = ..()
	create_reagents(reagent_capacity)
	AddComponent(/datum/component/plumbing/simple_demand, extend_pipe_to_edge = TRUE)
	soundloop = new (src, FALSE)
	STOP_PROCESSING(SSmachines, src)

/obj/machinery/plumbing/shower/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel_self()
		if(EXPLODE_HEAVY)
			if(prob(50))
				if(prob(50))
					new /obj/item/shower_parts(get_turf(src))
				qdel_self()
		if(EXPLODE_LIGHT)
			if(prob(25))
				new /obj/item/shower_parts(get_turf(src))
				qdel_self()

/obj/machinery/plumbing/shower/examine(mob/user, infix)
	. = ..()
	. += SPAN_NOTICE("It looks like the thermostat has an adjustment screw.")
	. += SPAN_NOTICE("The auto shut-off is programmed to [GLOB.shower_mode_descriptions["[mode]"]].")
	. += SPAN_NOTICE("[reagents.total_volume]/[reagents.maximum_volume] liquids remaining.")

/obj/machinery/plumbing/shower/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	intended_on = !intended_on
	if(!update_actually_on(intended_on))
		show_splash_text(user, "[src] is dry!")
		return TRUE

	show_splash_text(user, "Turned [intended_on ? "on" : "off"]!")

/obj/machinery/plumbing/shower/wrenched_change()
	. = ..()
	if(!anchored)
		update_actually_on(FALSE)

/obj/machinery/plumbing/shower/proc/update_actually_on(new_on_state)
	if(new_on_state == actually_on)
		return FALSE

	if(new_on_state && reagents.total_volume < SHOWER_SPRAY_VOLUME)
		STOP_PROCESSING(SSplumbing, src)
		return FALSE

	actually_on = new_on_state

	update_icon()
	//handle_mist()
	if(new_on_state)
		START_PROCESSING(SSplumbing, src)
		soundloop.start()
		set_next_think(world.time + SHOWER_TIMED_LENGTH)
	else
		soundloop.stop()
		var/turf/simulated/floor/F = loc
		if(istype(F))
			F.wet_floor(50)
	return TRUE

/obj/machinery/plumbing/shower/Process()
	if(actually_on && reagents.total_volume < SHOWER_SPRAY_VOLUME)
		update_actually_on(FALSE)
		if(mode != SHOWER_MODE_FOREVER)
			intended_on = FALSE

		return PROCESS_KILL

	else
		update_actually_on(intended_on)

	for(var/atom/movable/target as anything in loc)
		if(isliving(target))
			var/mob/living/L = target
			L.ExtinguishMob()
			L.adjust_wet_stacks(20, reagents)

		if(isitem(target))
			var/obj/item/I = target
			I.clean_blood()

		if(isturf(loc))
			var/turf/tile = loc
			for(var/obj/effect/E in tile)
				if(istype(E,/obj/effect/rune) || istype(E,/obj/effect/decal/cleanable) || istype(E,/obj/effect/overlay))
					qdel(E)

		reagents.trans_to(target, SHOWER_SPRAY_VOLUME)

	reagents.remove_any(SHOWER_SPRAY_VOLUME)

/obj/machinery/plumbing/shower/attackby(obj/item/I as obj, mob/user as mob)
	if(isScrewdriver(I))
		if(is_processing)
			to_chat(user, SPAN("warning", "The first thing to do is to turn off the water."))
			return

		playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
		new /obj/item/shower_parts(get_turf(src))
		qdel_self()

	if(I.type == /obj/item/device/analyzer)
		to_chat(user, SPAN_NOTICE("The water temperature seems to be [current_temperature]."))
		return

	return ..()

/obj/machinery/plumbing/shower/on_update_icon()
	ClearOverlays()

	if(is_processing)
		AddOverlays(image('icons/obj/watercloset.dmi', src, "water", MOB_LAYER + 1, dir))


/obj/machinery/plumbing/shower/proc/process_heat(mob/living/M)
	if(!is_processing || !istype(M))
		return

	var/temperature = temperature_settings[current_temperature]
	var/temp_adj = between(BODYTEMP_COOLING_MAX, temperature - M.bodytemperature, BODYTEMP_HEATING_MAX)
	M.bodytemperature += temp_adj

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(temperature >= H.species.heat_level_1)
			to_chat(H, SPAN_DANGER("The water is searing hot!"))
		else if(temperature <= H.species.cold_level_1)
			to_chat(H, SPAN_WARNING("The water is freezing cold!"))

/obj/item/shower_parts
	name = "shower parts"
	desc = "It has everything you need to assemble your own shower. Isn't it beautiful?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower_parts"
	can_get_wet = FALSE
	can_be_wrung_out = FALSE

/obj/item/shower_parts/attack_self(mob/user)
	add_fingerprint(user)

	if(!isturf(user.loc))
		return

	place_shower(user)

/obj/item/shower_parts/proc/place_shower(mob/user)
	if(!in_use)
		to_chat(user, SPAN("notice", "Assembling shower..."))
		in_use = TRUE
		if(!do_after(user, 1 SECOND))
			in_use = FALSE
			return

		var/obj/machinery/plumbing/shower/S = new /obj/machinery/plumbing/shower(user.loc)
		to_chat(user, SPAN("notice", "You assemble a shower"))
		in_use = FALSE
		S.add_fingerprint(user)
		qdel_self()
	return
