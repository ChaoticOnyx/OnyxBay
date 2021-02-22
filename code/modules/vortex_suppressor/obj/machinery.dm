/obj/machinery/power/vortex_suppressor
	name = "Advanced Vortex Suppressor"
	desc = "A heavy-duty vortex suppressor and capacitor, capable of blocks vortex flow at small distances."
	icon = 'icons/obj/machines/suppressor.dmi'
	icon_state = "generator0"
	density = 1
	var/datum/wires/shield_generator/wires
	var/shield_modes = 0				// Enabled shield mode flags
	var/max_energy = 0					// Maximal stored energy. In joules. Depends on the type of used SMES coil when constructing this generator.
	var/current_energy = 0				// Current stored energy.
	var/suppressor_radius = 1			// Current field radius.
	var/suppressor_max_radius = 255		// Max radius for suppressor
	var/running = SHIELD_OFF			// Whether the generator is enabled or not.
	var/upkeep_power_usage = 0			// Upkeep power usage last tick.
	var/upkeep_multiplier = 0			// Multiplier of upkeep values.
	var/power_usage = 0					// Total power usage last tick.
	var/hacked = 0						// Whether the generator has been hacked by cutting the safety wire.
	var/offline_for = 0					// The generator will be inoperable for this duration in ticks.
	var/input_cut = 0					// Whether the input wire is cut.
	var/mode_changes_locked = 0			// Whether the control wire is cut, locking out changes.
	var/ai_control_disabled = 0			// Whether the AI control is disabled.
	var/list/mode_list = null			// A list of shield_mode datums.

/obj/machinery/power/vortex_suppressor/update_icon()
	if(running)
		icon_state = "generator1"
	else
		icon_state = "generator0"


/obj/machinery/power/vortex_suppressor/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/vortex_suppressor(src)
	component_parts += new /obj/item/stack/cable_coil(src)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
	component_parts += new /obj/item/weapon/stock_parts/subspace/filter(src)
	component_parts += new /obj/item/weapon/smes_coil(src)					        // SMES coil. Improves maximal shield energy capacity.
	component_parts += new /obj/item/weapon/stock_parts/subspace/crystal(src)
	RefreshParts()
	connect_to_network()
	wires = new(src)

	mode_list = list()
	for(var/st in subtypesof(/datum/suppressor_mode/))
		var/datum/suppressor_mode/SM = new st()
		mode_list.Add(SM)


/obj/machinery/power/vortex_suppressor/Destroy()
	shutdown_field()
	mode_list = null
	QDEL_NULL(wires)
	. = ..()

/obj/machinery/power/vortex_suppressor/RefreshParts()
	max_energy = 0
	for(var/obj/item/weapon/smes_coil/S in component_parts)
		max_energy += S.ChargeCapacity * 10000
	current_energy = between(0, current_energy, max_energy)

// Shuts down the shield, removing all shield segments and unlocking generator settings.
/obj/machinery/power/vortex_suppressor/proc/shutdown_field()
	running = SHIELD_OFF
	current_energy = 0
	update_icon()

// Recalculates and updates the upkeep multiplier
/obj/machinery/power/vortex_suppressor/proc/update_upkeep_multiplier()
	var/new_upkeep = 0
	for(var/datum/suppressor_mode/SM in mode_list)
		if(check_flag(SM.mode_flag))
			new_upkeep += SM.multiplier

	upkeep_multiplier = new_upkeep


/obj/machinery/power/vortex_suppressor/Process()
	upkeep_power_usage = 0
	power_usage = 0

	if(offline_for)
		offline_for = max(0, offline_for - 1)
	// We're turned off.
	if(!running)
		return

	upkeep_power_usage += round(((((suppressor_radius * 2) ** 2) / 2) * ENERGY_UPKEEP_SUPPRESSOR * 50) * upkeep_multiplier)

	var/energy_buffer = 0
	if(powernet && (running == SHIELD_RUNNING) && !input_cut)
		energy_buffer = draw_power(upkeep_power_usage)
		power_usage += round(energy_buffer)

		if(energy_buffer < upkeep_power_usage)
			current_energy -= round(upkeep_power_usage - energy_buffer)	// If we don't have enough energy from the grid, take it from the internal battery instead.

		// Now try to recharge our internal energy.
		var/energy_to_demand = max(0, max_energy - current_energy)

		energy_buffer = draw_power(energy_to_demand)
		power_usage += energy_buffer
		current_energy += round(energy_buffer)

	if(energy_buffer < upkeep_power_usage)
		running = SHIELD_DISCHARGING
		current_energy -= round(upkeep_power_usage)	// We are shutting down, or we lack external power connection. Use energy from internal source instead.

	if(current_energy <= 0)
		energy_failure()

/obj/machinery/power/vortex_suppressor/attackby(obj/item/O as obj, mob/user as mob)
	if(panel_open && isMultitool(O) || isWirecutter(O))
		attack_hand(user)
		return

	if(default_deconstruction_screwdriver(user, O))
		return

	// Prevents dismantle-rebuild tactics to reset the emergency shutdown timer.
	if(running)
		to_chat(user, "Turn off \the [src] first!")
		return
	if(offline_for)
		to_chat(user, "Wait until \the [src] cools down from emergency shutdown first!")
		return

	if(default_deconstruction_crowbar(user, O))
		return
	if(default_part_replacement(user, O))
		return


/obj/machinery/power/vortex_suppressor/proc/energy_failure()
	if(running == SHIELD_DISCHARGING)
		shutdown_field()
	else
		current_energy = 0

/obj/machinery/power/vortex_suppressor/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/data[0]

	data["running"] = running
	data["modes"] = get_flag_descriptions()
	data["max_energy"] = round(max_energy / 1000000, 0.1)
	data["current_energy"] = round(current_energy / 1000000, 0.1)
	data["field_integrity"] = field_integrity()
	data["suppressor_radius"] = suppressor_radius
	data["upkeep_power_usage"] = round(upkeep_power_usage / 1000, 0.1)
	data["power_usage"] = round(power_usage / 1000)
	data["hacked"] = hacked
	data["offline_for"] = offline_for * 2

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "vortex_suppressor.tmpl", src.name, 500, 800)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/machinery/power/vortex_suppressor/attack_hand(mob/user)
	ui_interact(user)
	if(panel_open)
		wires.Interact(user)


/obj/machinery/power/vortex_suppressor/CanUseTopic(mob/user)
	if(issilicon(user) && !Adjacent(user) && ai_control_disabled)
		return STATUS_UPDATE
	return ..()

/obj/machinery/power/vortex_suppressor/OnTopic(user, href_list)
	if(href_list["begin_shutdown"])
		if(running != SHIELD_RUNNING)
			return
		running = SHIELD_OFF
		update_icon()
		return TOPIC_REFRESH

	if(href_list["start_generator"])
		if(offline_for)
			return
		running = SHIELD_RUNNING
		update_icon()
		return TOPIC_REFRESH

	// Instantly drops the shield, but causes a cooldown before it may be started again. Also carries a risk of EMP at high charge.
	if(href_list["emergency_shutdown"])
		if(!running)
			return TOPIC_HANDLED

		var/choice = input(user, "Are you sure that you want to initiate an emergency shield shutdown? This will instantly drop the shield, and may result in unstable release of stored electromagnetic energy. Proceed at your own risk.") in list("Yes", "No")
		if((choice != "Yes") || !running)
			return TOPIC_HANDLED

		// If the shield would take 5 minutes to disperse and shut down using regular methods, it will take x1.5 (7 minutes and 30 seconds) of this time to cool down after emergency shutdown
		offline_for = round(current_energy / (SHIELD_SHUTDOWN_DISPERSION_RATE / 1.5))
		var/old_energy = current_energy
		shutdown_field()
		log_and_message_admins("has triggered \the [src]'s emergency shutdown!", user)
		spawn()
			empulse(src, old_energy / 60000000, old_energy / 32000000, 1) // If shields are charged at 450 MJ, the EMP will be 7.5, 14.0625. 90 MJ, 1.5, 2.8125
		old_energy = 0

		return TOPIC_REFRESH

	if(mode_changes_locked)
		return TOPIC_REFRESH

	if(href_list["set_range"])
		var/new_range = input(user, "Enter new field range (1-[suppressor_max_radius]). Leave blank to cancel.", "Field Radius Control", suppressor_radius) as num
		if(!new_range)
			return TOPIC_HANDLED
		suppressor_radius = between(1, new_range, suppressor_max_radius)
		return TOPIC_REFRESH

	if(href_list["toggle_mode"])
		// Toggling hacked-only modes requires the hacked var to be set to 1
		if((text2num(href_list["toggle_mode"]) & (MODEFLAG_OVERCHARGE)) && !hacked)
			return TOPIC_HANDLED

		toggle_flag(text2num(href_list["toggle_mode"]))
		return TOPIC_REFRESH


/obj/machinery/power/vortex_suppressor/proc/field_integrity()
	if(max_energy)
		return (current_energy / max_energy) * 100
	return 0

// Checks whether specific flags are enabled
/obj/machinery/power/vortex_suppressor/proc/check_flag(flag)
	return (shield_modes & flag)


/obj/machinery/power/vortex_suppressor/proc/toggle_flag(flag)
	shield_modes ^= flag
	update_upkeep_multiplier()

/obj/machinery/power/vortex_suppressor/proc/get_flag_descriptions()
	var/list/all_flags = list()
	for(var/datum/suppressor_mode/SM in mode_list)
		all_flags.Add(list(list(
			"name" = SM.mode_name,
			"desc" = SM.mode_desc,
			"flag" = SM.mode_flag,
			"status" = check_flag(SM.mode_flag),
			"multiplier" = SM.multiplier,
		)))
	return all_flags