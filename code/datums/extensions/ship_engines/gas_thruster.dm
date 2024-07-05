#define MINIMUM_RATIO_SPECIFIC_HEAT 1.05
#define MAXIMUM_RATIO_SPECIFIC_HEAT 3.20

/datum/extension/ship_engine/gas
	expected_type = /obj/machinery/atmospherics/unary/engine

/datum/extension/ship_engine/gas/burn(partial = 1)
	var/obj/machinery/atmospherics/unary/engine/E = holder
	if(!is_on())
		return 0

	if(!has_fuel() || (0 < E.use_power_oneoff(charge_per_burn * thrust_limit)) || check_blockage())
		E.audible_message(src, SPAN_WARNING("[holder] coughs once and goes silent!"))
		E.update_use_power(POWER_USE_OFF)
		return 0

	var/datum/gas_mixture/removed = get_propellant(FALSE, partial)
	if(!removed)
		return 0

	. = get_exhaust_velocity(removed)
	playsound(E.loc, 'sound/machines/thruster.ogg', 100 * thrust_limit * partial, 0, world.view * 4, 0.1)
	E.update_icon()

	var/exhaust_dir = GLOB.flip_dir[E.dir]
	var/turf/T = get_step(holder, exhaust_dir)
	if(T)
		T.assume_air(removed)
		new /obj/effect/engine_exhaust(T, E.dir)

/datum/extension/ship_engine/gas/proc/get_propellant(sample_only = TRUE, partial = 1)
	var/obj/machinery/atmospherics/unary/engine/E = holder
	if(istype(E) && E.air_contents?.volume > 0)
		var/datum/gas_mixture/removed = E.air_contents.remove_ratio((volume_per_burn * thrust_limit * partial) / E.air_contents.volume)
		if(removed && sample_only)
			var/datum/gas_mixture/sample = new(removed.volume)
			sample.copy_from(removed)
			E.air_contents.merge(removed)
			return sample

		. = removed

/datum/extension/ship_engine/gas/get_exhaust_velocity(datum/gas_mixture/propellant)
	if(!is_on() || !has_fuel())
		return 0

	propellant = propellant || get_propellant()
	if(!propellant)
		return 0

	var/exit_pressure = get_nozzle_exit_pressure()
	var/ratio_specific_heat = get_ratio_specific_heat(propellant)
	//if((propellant.return_pressure() - exit_pressure) <= MINIMUM_PRESSURE_DIFFERENCE_TO_SUSPEND)
	//	return 0
	var/mm = propellant.specific_mass()
	if(mm == 0)
		return 0

	var/ve2 = ratio_specific_heat * (R_IDEAL_GAS_EQUATION / mm) * propellant.temperature
	ve2 *= 1 - (exit_pressure / propellant.return_pressure()) ** ((ratio_specific_heat - 1) / ratio_specific_heat)
	ve2 = ve2 / (ratio_specific_heat - 1)
	return sqrt(ve2)

/datum/extension/ship_engine/gas/proc/get_nozzle_exit_pressure()
	var/obj/machinery/atmospherics/unary/engine/E = holder
	var/exhaust_dir = GLOB.flip_dir[E.dir]
	var/turf/A = get_step(holder, exhaust_dir)
	var/datum/gas_mixture/nozzle_exit_air = A.return_air()
	var/exit_pressure = 0
	if(nozzle_exit_air)
		exit_pressure = nozzle_exit_air.return_pressure()
	return exit_pressure

/datum/extension/ship_engine/gas/proc/get_ratio_specific_heat(datum/gas_mixture/propellant)
	var/ratio_specific_heat = 0
	propellant = propellant || get_propellant()
	if(!propellant || !length(propellant.gas) || !propellant.total_moles)
		return 0.01 // Divide by zero protection.

	for(var/g in propellant.gas)
		if(propellant.gas[g] < MINIMUM_MOLES_TO_FILTER)
			continue

		var/ratio = (gas_data.specific_heat[g] / 25) + 0.8 // These numbers are meaningless, just magic numbers to calibrate range.
		ratio_specific_heat += ratio * (propellant.gas[g] / propellant.total_moles)
	ratio_specific_heat = ratio_specific_heat / length(propellant.gas)
	if(ratio_specific_heat == 0 || ratio_specific_heat == 1)
		// rare case of avoiding a divide by zero error.
		ratio_specific_heat += 0.01
	return clamp(ratio_specific_heat, MINIMUM_RATIO_SPECIFIC_HEAT, MAXIMUM_RATIO_SPECIFIC_HEAT)

/datum/extension/ship_engine/gas/get_specific_wet_mass()
	var/datum/gas_mixture/propellant = get_propellant()
	if(propellant)
		return round(propellant.specific_mass() * volume_per_burn * thrust_limit, 0.01)

/datum/extension/ship_engine/gas/has_fuel()
	var/obj/machinery/atmospherics/unary/engine/E = holder
	return E.air_contents.total_moles > 5 // minimum fuel usage is five moles, for EXTREMELY hot mix or super low pressure

/datum/extension/ship_engine/gas/get_status()
	. = list()
	.+= ..()

	var/obj/machinery/atmospherics/unary/engine/E = holder
	var/datum/gas_mixture/propellant = get_propellant()
	if(!propellant)
		.+= "<span class='average'>Insufficient or invalid propellant.</span>"
	else
		.+= "Propellant total mass: [round(E.air_contents.get_mass(), 0.01)] kg."
		.+= "Propellant used per burn: [get_specific_wet_mass()] kg."
		.+= "Propellant pressure: [round(propellant.return_pressure()/1000,0.1)] MPa."
		.+= "Propellant molar mass: [propellant.specific_mass()] kg/mol"
		.+= "Propellant ratio specific heat: [get_ratio_specific_heat()]"
		.+= "Exhaust temperature: [propellant.temperature] Kelvin"

	var/exit_pressure = get_nozzle_exit_pressure()
	.+= exit_pressure ? "Nozzle exit pressure: [exit_pressure] kPA" : "Nozzle exit pressure: VACUUM"

	return jointext(.,"<br>")
