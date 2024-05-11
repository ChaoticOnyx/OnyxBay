#define WATER_UNIT_PER_TILE 5
#define TEMPERATURE_INCREMENT 10
#define STEAM_OVERLAY_ALPHA_INCREMENT 20
#define TIME_WITHOUT_WATER_UNTIL_FIRE 2 MINUTES

/obj/machinery/sauna
	name = "sauna heater"
	desc = "Electric sauna heater - turns water into steam!"
	icon = 'icons/obj/machines/sauna.dmi'
	icon_state = "sauna"
	base_icon_state = "sauna"
	obj_flags = OBJ_FLAG_ANCHORABLE
	use_power = POWER_USE_IDLE
	density = TRUE
	anchored = TRUE
	stat = POWEROFF // Disabled at roundstart

	component_types = list(
		/obj/item/circuitboard/sauna,
		/obj/item/reagent_containers/vessel/beaker/large = 1,
		/obj/item/stock_parts/capacitor = 1
	)

	/// Container storing reagents for steam
	var/obj/item/reagent_containers/container

	var/static/image/container_overlay = image(icon = 'icons/obj/machines/sauna.dmi', icon_state = "container")
	var/static/image/on_bad = image(icon = 'icons/obj/machines/sauna.dmi', icon_state = "on_bad")
	var/static/image/on_good = image(icon = 'icons/obj/machines/sauna.dmi', icon_state = "on_good")

	var/static/image/radial_detach = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_detach")
	var/static/image/radial_add = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_add")
	var/static/image/radial_subtract = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_subtract")
	var/static/image/radial_use = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_use")

	var/image/emissive

	/// Determines how fast it heats air
	var/heating_power = 80 KILO WATTS
	/// Sauna will try to maintain this temperature
	var/target_temperature = 40 CELSIUS
	/// Sauna can't heat more than this
	var/max_temperature = 130 CELSIUS
	/// Sauna esssentialy can't act as a freezer
	var/min_temperature = 40 CELSIUS
	/// Reference to the steam object that handles visual effects and transfer of reagents
	var/atom/movable/steam_controller/steam
	/// world.time of the last Process() with water.
	var/last_tick_with_water
	/// To prevent dublication of steam particles and sounds
	var/currently_steaming = FALSE
	/// Ref to steam particles for further qdel
	var/atom/movable/particle_emitter/smoke_steam/steam_particles

/obj/machinery/sauna/Initialize(mapload)
	. = ..()
	emissive = emissive_appearance(icon, "sauna_ea")

/obj/machinery/sauna/Destroy()
	steam = null // Steam object deletes itself on depletion of reagents
	QDEL_NULL(steam_particles)
	QDEL_NULL(emissive)
	return ..()

/obj/machinery/sauna/attack_hand(mob/user)
	. = ..()

	if(issilicon(user))
		return

	if(!anchored)
		show_splash_text(user, "anchor it first!", "\The [src] must be anchored to the floor!")
		return

	var/list/options = list()

	if(istype(container))
		options["Detach container"] = radial_detach

	if(target_temperature < max_temperature)
		options["Increase Temperature"] = radial_add

	if(target_temperature > min_temperature)
		options["Decrease Temperature"] = radial_subtract

	options["Toggle"] = radial_use

	if(length(options) < 1)
		return

	var/choice

	if(length(options) == 1)
		choice = options[1]
	else
		choice = show_radial_menu(user, src, options, require_near = !issilicon(user))

	switch(choice)
		if("Detach container")
			if(!istype(container))
				return

			replace_container(user)
		if("Toggle")
			toggle(user)
			playsound(get_turf(src), GET_SFX(SFX_USE_KNOB), 45, TRUE)
		if("Increase Temperature")
			target_temperature = min(max_temperature, target_temperature + TEMPERATURE_INCREMENT)
			show_splash_text(user, "temperature increased", "You increase \the [src]'s target temperature to [CONV_KELVIN_CELSIUS(target_temperature)] celsius.")
			playsound(get_turf(src), GET_SFX(SFX_USE_KNOB), 45, TRUE)
		if("Decrease Temperature")
			target_temperature = max(min_temperature, target_temperature - TEMPERATURE_INCREMENT)
			show_splash_text(user, "temperature decreased", "You decrease \the [src]'s target temperature to [CONV_KELVIN_CELSIUS(target_temperature)] celsius.")
			playsound(get_turf(src), GET_SFX(SFX_USE_KNOB), 45, TRUE)

/obj/machinery/sauna/attackby(obj/item/attack_item, mob/living/user, params)
	if(!container && default_deconstruction_screwdriver(user, attack_item))
		return

	if(default_deconstruction_crowbar(user, attack_item))
		return

	if(istype(attack_item, /obj/item/reagent_containers/vessel) && attack_item.is_open_container())
		var/obj/item/reagent_containers/vessel/new_container = attack_item
		if(!user.drop(new_container, src))
			return

		replace_container(user, new_container)
		return

	return ..()

/obj/machinery/sauna/wrench_floor_bolts(mob/user)
	if(!(stat & (NOPOWER | BROKEN | POWEROFF)))
		show_splash_text(user, "turn off first!", "\The [src] must be turned off first!")
		return

	. = ..()
	if(!.)
		return

	if(!anchored)
		stat |= POWEROFF
		STOP_PROCESSING(SSmachines, src)
		update_icon()

/obj/machinery/sauna/Process()
	if(stat & (NOPOWER | BROKEN | POWEROFF))
		STOP_PROCESSING(SSmachines, src)
		return

	var/datum/gas_mixture/env = loc.return_air()
	if(!istype(env))
		return

	if(abs(env.temperature - target_temperature) <= 0.1)
		return

	var/transfer_moles = 0.25 * env.total_moles
	var/datum/gas_mixture/removed = env.remove(transfer_moles)

	if(!istype(removed))
		return

	var/heat_transfer = removed.get_thermal_energy_change(target_temperature)
	var/power_draw
	if(heat_transfer < 0) // Sauna can't act as a freezer
		return

	heat_transfer = min(heat_transfer, heating_power)
	removed.add_thermal_energy(heat_transfer)
	power_draw = heat_transfer
	use_power_oneoff(power_draw)
	env.merge(removed)

	if(container?.reagents.get_reagent_amount(/datum/reagent/water))
		last_tick_with_water = world.time
	else
		update_icon()

	if(world.time >= last_tick_with_water + TIME_WITHOUT_WATER_UNTIL_FIRE)
		catch_fire()
		return

	if(istype(steam) && !QDELETED(steam))
		container?.reagents.trans_to_holder(steam.reagents, 15)
		steam_effect()

	else
		if(env.temperature <= 40 CELSIUS)
			return

		var/turf/simulated/T = get_turf(src)
		var/total_water_required = T?.zone?.contents?.len * WATER_UNIT_PER_TILE
		if(container?.reagents?.total_volume <= total_water_required)
			return

		steam = new /atom/movable/steam_controller(get_turf(src), src)
		steam_effect()
		container.reagents.trans_to_holder(steam.reagents, container.reagents.total_volume)

/obj/machinery/sauna/proc/steam_effect()
	if(currently_steaming)
		return

	currently_steaming = TRUE
	playsound(get_turf(src), 'sound/effects/water_sizzle.ogg', 15)
	steam_particles = new /atom/movable/particle_emitter/smoke_steam(get_turf(src))
	set_next_think(world.time + 30 SECONDS)

/obj/machinery/sauna/think()
	QDEL_NULL(steam_particles)
	currently_steaming = FALSE

/obj/machinery/sauna/proc/catch_fire()
	var/atom/movable/particle_emitter/fire_smoke/fire = new /atom/movable/particle_emitter/fire_smoke(get_turf(src))
	stat |= BROKEN
	update_icon()
	QDEL_IN(fire, 20 SECONDS)

/// Generic toggle proc. Nothing special.
/obj/machinery/sauna/proc/toggle(mob/user)
	if(stat & NOPOWER)
		show_splash_text(user, "no power!", "\The [src] is not powered!")
		return

	if(stat & BROKEN)
		show_splash_text(user, "broken!", "\The [src] is broken!")
		return

	if(stat & POWEROFF)
		stat &= ~POWEROFF
		show_splash_text(user, "enabled", "You turn on \the [src]")
		last_tick_with_water = world.time
		START_PROCESSING(SSmachines, src)
	else
		stat |= POWEROFF
		show_splash_text(user, "disabled", "You turn off \the [src]")
		STOP_PROCESSING(SSmachines, src)

	update_icon()

/// Handles insertion/ejection of a given reagent container.
/obj/machinery/sauna/proc/replace_container(mob/living/user, obj/item/reagent_containers/vessel/new_container)
	if(!istype(user))
		return

	if(container)
		user.pick_or_drop(container, get_turf(src))
		show_splash_text(user, "ejected container", "Ejected \the [container] from \the [src].")
		container = null

	if(new_container)
		container = new_container
		show_splash_text(user, "instered container", "Inserted \the [container] in \the [src].")

	update_icon()

/obj/machinery/sauna/on_update_icon()
	icon_state = "[base_icon_state][(stat & (BROKEN | NOPOWER | POWEROFF)) ? "" : "_on"]"

	CutOverlays(container_overlay)
	if(!isnull(container))
		AddOverlays(container_overlay)

	CutOverlays(on_bad)
	CutOverlays(on_good)
	if(!(stat & (BROKEN | NOPOWER | POWEROFF)))
		if(istype(container) && container?.reagents.get_reagent_amount(/datum/reagent/water))
			AddOverlays(on_good)
			set_light(0.15, 0.1, 1, 2, "#82ff4c" )
		else
			AddOverlays(on_bad)
			set_light(0.15, 0.1, 1, 2, "#f86060")

	CutOverlays(emissive)
	var/should_glow = update_glow()
	if(should_glow)
		AddOverlays(emissive)

/obj/machinery/sauna/proc/update_glow()
	if(stat & (BROKEN | NOPOWER | POWEROFF))
		set_light(0)
		return FALSE

	if(istype(container) && container?.reagents.get_reagent_amount(/datum/reagent/water))
		set_light(0.15, 1, 2, 3.5, "#82ff4c")
	else
		set_light(0.15, 1, 2, 3.5, "#f86060")
	return TRUE

/obj/machinery/sauna/examine(mob/user, infix)
	. = ..()

	if(container)
		if(container.reagents && container.reagents.total_volume)
			. += SPAN_NOTICE("\The [src] has \a [container] loaded. It contains [container.reagents.total_volume]u of reagents.")
		else
			. += SPAN_NOTICE("\The [src] has \a [container] loaded. It is empty.")

	. += SPAN_NOTICE("Its temperature is set at [CONV_KELVIN_CELSIUS(target_temperature)] celsius.")

	if(panel_open)
		. += SPAN_NOTICE("[src]'s maintenance hatch is open!")

/atom/movable/steam_controller
	anchored = TRUE
	invisibility = INVISIBILITY_SYSTEM
	var/atom/movable/steam_overlay/overlay = /atom/movable/steam_overlay
	var/weakref/sauna_ref

/atom/movable/steam_controller/Initialize(mapload, obj/machinery/sauna/sauna)
	. = ..()
	if(istype(sauna))
		sauna_ref = weakref(sauna)

	create_reagents(1000)

	overlay = new overlay()

	handle_turfs()

	set_next_think(world.time + 30 SECONDS)

/atom/movable/steam_controller/Destroy()
	var/turf/simulated/T = get_turf(src)
	var/list/turfs = T?.zone?.contents
	for(var/turf/turf in turfs)
		turf.vis_contents.Remove(overlay)

	QDEL_NULL(overlay)

	var/obj/machinery/sauna/sauna = sauna_ref.resolve()
	if(istype(sauna))
		sauna.steam = null
	sauna_ref = null

	return ..()

/atom/movable/steam_controller/think()
	var/turf/simulated/T = get_turf(src)
	var/list/turfs = T?.zone?.contents
	var/datum/gas_mixture/env = loc.return_air()

	handle_turfs()

	if(env.temperature <= 40 CELSIUS)
		condense(turfs)
		return

	if(turfs?.len * WATER_UNIT_PER_TILE > reagents?.get_reagent_amount(/datum/reagent/water))
		disappear()
		return

	if(turfs?.len * WATER_UNIT_PER_TILE < reagents?.get_reagent_amount(/datum/reagent/water))
		reagents?.remove_reagent(/datum/reagent/water, turfs?.len * WATER_UNIT_PER_TILE)
		thicken()

	set_next_think(world.time + 30 SECONDS)

/// Checks all affected turfs, adds visual effects and transfers reagents to atoms and mobs.
/atom/movable/steam_controller/proc/handle_turfs()
	var/turf/simulated/T = get_turf(src)
	var/list/turfs = T?.zone?.contents
	for(var/turf/simulated/floor/turf in turfs)
		if(!LAZYISIN(turf.vis_contents, overlay))
			turf.vis_contents.Add(overlay)

		if(!reagents.reagent_list.len)
			continue

		reagents.touch_turf(turf)
		for(var/atom/A in turf.contents)
			if(isliving(A))
				var/mob/living/affected = A
				if(affected.wear_mask && (affected.wear_mask.item_flags & ITEM_FLAG_BLOCK_GAS_SMOKE_EFFECT))
					continue

				reagents.trans_to_mob(affected, 5, CHEM_INGEST)
				reagents.trans_to_mob(affected, 5, CHEM_BLOOD)
			else if(isobj(A) && !A.simulated)
				reagents.touch_obj(A)

/atom/movable/steam_controller/proc/condense(list/turfs)
	for(var/turf/simulated/T in turfs)
		T.wet_floor(1)

	disappear()

/atom/movable/steam_controller/proc/disappear()
	overlay.update_alpha(0, 5 SECONDS)
	qdel_self()

/atom/movable/steam_controller/proc/thicken()
	overlay.update_alpha(min(255, alpha + STEAM_OVERLAY_ALPHA_INCREMENT), 5 SECONDS)

/atom/movable/steam_overlay
	icon = null
	icon_state = null
	plane = DEFAULT_PLANE
	layer = ABOVE_PROJECTILE_LAYER
	vis_flags = 0
	alpha = 127
	render_source = STEAM_EFFECT_TARGET
	appearance_flags = TILE_BOUND | PIXEL_SCALE | KEEP_APART | RESET_ALPHA
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/steam_overlay/proc/update_alpha(new_alpha, animation_duratuion)
	if(new_alpha == alpha)
		return

	animate(src, alpha = new_alpha, time = animation_duratuion, easing = SINE_EASING | EASE_IN, loop = -1)
	alpha = new_alpha
