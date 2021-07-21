#define SOURCE_TO_TARGET 0
#define TARGET_TO_SOURCE 1
#define PUMP_EFFICIENCY 0.6
#define TANK_FAILURE_PRESSURE (ONE_ATMOSPHERE*25)
#define PUMP_MAX_VOLUME 100

/*
Roadmap:

pump
volume pump
gas vent
integrated connector
gas filter
gas mixer
integrated tank
large integrated tank
heater tank
freezer tank
atmospheric cooler
atmospheric heater
tank slot
*/

/obj/item/integrated_circuit/atmospherics
	category_text = "Atmospherics"
	cooldown_per_use = 2 SECONDS
	complexity = 10
	size = 7
	outputs = list(
		"self reference" = IC_PINTYPE_SELFREF,
		"pressure" = IC_PINTYPE_NUMBER
			)
	var/datum/gas_mixture/air_contents
	var/volume = 2 //Pretty small, I know

/obj/item/integrated_circuit/atmospherics/Initialize()
	air_contents = new(volume)
	..()

/obj/item/integrated_circuit/atmospherics/return_air()
	return air_contents

//Check if the gas container is adjacent and of the right type
/obj/item/integrated_circuit/atmospherics/proc/check_gassource(atom/gasholder)
	if(!gasholder)
		return FALSE
	if(!gasholder.Adjacent(get_object()))
		return FALSE
	if(!istype(gasholder, /obj/item/weapon/tank) && !istype(gasholder, /obj/machinery/portable_atmospherics) && !istype(gasholder, /obj/item/integrated_circuit/atmospherics))
		return FALSE
	return TRUE

//Needed in circuits where source and target types differ
/obj/item/integrated_circuit/atmospherics/proc/check_gastarget(atom/gasholder)
	return check_gassource(gasholder)


// - gas pump -
/obj/item/integrated_circuit/atmospherics/pump
	name = "gas pump"
	desc = "Somehow moves gases between two tanks, canisters, and other gas containers."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
			"source" = IC_PINTYPE_REF,
			"target" = IC_PINTYPE_REF,
			"target pressure" = IC_PINTYPE_NUMBER
			)
	activators = list(
			"transfer" = IC_PINTYPE_PULSE_IN,
			"on transfer" = IC_PINTYPE_PULSE_OUT
			)
	var/direction = SOURCE_TO_TARGET
	var/target_pressure = MAX_PUMP_PRESSURE
	power_draw_per_use = 20

/obj/item/integrated_circuit/atmospherics/pump/Initialize()
	air_contents = new(volume)
	extended_desc += " Use negative pressure to move air from target to source. \
					Note that only part of the gas is moved on each transfer, \
					so multiple activations will be necessary to achieve target pressure. \
					The pressure limit for circuit pumps is [round(MAX_PUMP_PRESSURE)] kPa."
	. = ..()

// This proc gets the direction of the gas flow depending on its value, by calling update target
/obj/item/integrated_circuit/atmospherics/pump/on_data_written()
	var/amt = get_pin_data(IC_INPUT, 3)
	update_target(amt)

/obj/item/integrated_circuit/atmospherics/pump/proc/update_target(new_amount)
	if(!isnum_safe(new_amount))
		new_amount = 0
	// See in which direction the gas moves
	if(new_amount < 0)
		direction = TARGET_TO_SOURCE
	else
		direction = SOURCE_TO_TARGET
	target_pressure = min(round(MAX_PUMP_PRESSURE),abs(new_amount))

/obj/item/integrated_circuit/atmospherics/pump/do_work()
	var/obj/source = get_pin_data_as_type(IC_INPUT, 1, /obj)
	var/obj/target = get_pin_data_as_type(IC_INPUT, 2, /obj)
	perform_magic(source, target)
	activate_pin(2)

/obj/item/integrated_circuit/atmospherics/pump/proc/perform_magic(atom/source, atom/target)
	//Check if both atoms are of the right type: atmos circuits/gas tanks/canisters. If one is the same, use the circuit var
	if(!check_gassource(source))
		source = src

	if(!check_gastarget(target))
		target = src

	// If both are the same, this whole proc would do nothing and just waste performance
	if(source == target)
		return

	var/datum/gas_mixture/source_air = source.return_air()
	var/datum/gas_mixture/target_air = target.return_air()

	if(!source_air || !target_air)
		return

	// Swapping both source and target
	if(direction == TARGET_TO_SOURCE)
		var/temp = source_air
		source_air = target_air
		target_air = temp

	// If what you are pumping is empty, use the circuit's storage
	if(source_air.total_moles <= 0)
		source_air = air_contents

	// Move gas from one place to another
	move_gas(source_air, target_air, (istype(target, /obj/item/weapon/tank) ? target : null))

/obj/item/integrated_circuit/atmospherics/pump/proc/move_gas(datum/gas_mixture/source_air, datum/gas_mixture/target_air, obj/item/weapon/tank/snowflake)

	// No moles = nothing to pump
	if(source_air.total_moles <= 0  || target_air.return_pressure() >= MAX_PUMP_PRESSURE)
		return

	// Negative Kelvin temperatures should never happen and if they do, normalize them
	var/source_temp = source_air.temperature
	if(source_temp < TCMB)
		var/transfer_temp = source_air.get_thermal_energy_change(TCMB)
		source_air.add_thermal_energy(transfer_temp)

	var/pressure_delta = target_pressure - target_air.return_pressure()
	if(pressure_delta > 0.1)
		var/transfer_moles = (pressure_delta*target_air.volume/(source_air.temperature * R_IDEAL_GAS_EQUATION))*PUMP_EFFICIENCY
		var/datum/gas_mixture/removed = source_air.remove(transfer_moles)
		if(istype(snowflake)) //Snowflake check for tanks specifically, because tank ruptures are handled in a very snowflakey way that expects all tank interactions to be handled via the tank's procs
			snowflake.assume_air(removed)
		else
			target_air.merge(removed)

// - volume pump -
/obj/item/integrated_circuit/atmospherics/pump/volume
	name = "volume pump"
	desc = "Moves gases between two tanks, canisters, and other gas containers by using their volume, up to 200 L/s."
	extended_desc = " Use negative volume to move air from target to source. Note that only part of the gas is moved on each transfer. Its maximum pumping volume is capped at 1000kPa."

	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
			"source" = IC_PINTYPE_REF,
			"target" = IC_PINTYPE_REF,
			"transfer volume" = IC_PINTYPE_NUMBER
			)
	activators = list(
			"transfer" = IC_PINTYPE_PULSE_IN,
			"on transfer" = IC_PINTYPE_PULSE_OUT
			)
	direction = SOURCE_TO_TARGET
	var/transfer_rate = PUMP_MAX_VOLUME
	power_draw_per_use = 20

/obj/item/integrated_circuit/atmospherics/pump/volume/update_target(new_amount)
	if(!isnum_safe(new_amount))
		new_amount = 0
	// See in which direction the gas moves
	if(new_amount < 0)
		direction = TARGET_TO_SOURCE
	else
		direction = SOURCE_TO_TARGET
	target_pressure = min(PUMP_MAX_VOLUME,abs(new_amount))

/obj/item/integrated_circuit/atmospherics/pump/volume/move_gas(datum/gas_mixture/source_air, datum/gas_mixture/target_air, obj/item/weapon/tank/snowflake)
	// No moles = nothing to pump
	if(source_air.total_moles <= 0)
		return

	// Negative Kelvin temperatures should never happen and if they do, normalize them
	var/source_temp = source_air.temperature
	if(source_temp < TCMB)
		var/transfer_temp = source_air.get_thermal_energy_change(TCMB)
		source_air.add_thermal_energy(transfer_temp)

	if((source_air.return_pressure() < 0.01) || (target_air.return_pressure() >= MAX_PUMP_PRESSURE))
		return

	//The second part of the min caps the pressure built by the volume pumps to the max pump pressure
	var/transfer_ratio = min(transfer_rate,target_air.volume*MAX_PUMP_PRESSURE/source_air.volume)/source_air.volume

	var/datum/gas_mixture/removed = source_air.remove_ratio(transfer_ratio * PUMP_EFFICIENCY)

	if(istype(snowflake))
		snowflake.assume_air(removed)
	else
		target_air.merge(removed)

// - gas vent -
/obj/item/integrated_circuit/atmospherics/pump/vent
	name = "gas vent"
	extended_desc = "Use negative volume to move air from target to environment. Note that only part of the gas is moved on each transfer. Unlike the gas pump, this one keeps pumping even further to pressures of 9000 pKa and it is not advised to use it on tank circuits."
	desc = "Moves gases between the environment and adjacent gas containers."
	inputs = list(
			"container" = IC_PINTYPE_REF,
			"target pressure" = IC_PINTYPE_NUMBER
			)

/obj/item/integrated_circuit/atmospherics/pump/vent/on_data_written()
	var/amt = get_pin_data(IC_INPUT, 2)
	update_target(amt)

/obj/item/integrated_circuit/atmospherics/pump/vent/do_work()
	var/turf/source = get_turf(src)
	var/obj/target = get_pin_data_as_type(IC_INPUT, 1, /obj)
	perform_magic(source, target)
	activate_pin(2)

/obj/item/integrated_circuit/atmospherics/pump/vent/check_gastarget(atom/gasholder)
	if(!gasholder)
		return FALSE
	if(!gasholder.Adjacent(get_object()))
		return FALSE
	if(!istype(gasholder, /obj/item/weapon/tank) && !istype(gasholder, /obj/machinery/portable_atmospherics) && !istype(gasholder, /obj/item/integrated_circuit/atmospherics))
		return FALSE
	return TRUE

/obj/item/integrated_circuit/atmospherics/pump/vent/check_gassource(atom/target)
	if(!target)
		return FALSE
	if(!istype(target, /turf))
		return FALSE
	return TRUE

// - gas filter -
/obj/item/integrated_circuit/atmospherics/pump/filter
	name = "gas filter"
	desc = "Filters one gas out of a mixture."
	complexity = 20
	size = 8
	spawn_flags = IC_SPAWN_RESEARCH
	inputs = list(
			"source" = IC_PINTYPE_REF,
			"filtered output" = IC_PINTYPE_REF,
			"contaminants output" = IC_PINTYPE_REF,
			"wanted gases" = IC_PINTYPE_LIST,
			"target pressure" = IC_PINTYPE_NUMBER
			)
	power_draw_per_use = 30

/obj/item/integrated_circuit/atmospherics/pump/filter/Initialize()
	air_contents = new(volume)
	. = ..()
	extended_desc = "Remember to properly spell and capitalize the filtered gas name. \
					Note that only part of the gas is moved on each transfer, \
					so multiple activations will be necessary to achieve target pressure. \
					The pressure limit for circuit pumps is [round(MAX_PUMP_PRESSURE)] kPa."

/obj/item/integrated_circuit/atmospherics/pump/filter/on_data_written()
	var/amt = get_pin_data(IC_INPUT, 5)
	target_pressure = Clamp(amt, 0, MAX_PUMP_PRESSURE)

/obj/item/integrated_circuit/atmospherics/pump/filter/do_work()
	var/obj/source = get_pin_data_as_type(IC_INPUT, 1, /obj)
	var/obj/filtered = get_pin_data_as_type(IC_INPUT, 2, /obj)
	var/obj/contaminants = get_pin_data_as_type(IC_INPUT, 3, /obj)

	var/list/wanted = get_pin_data(IC_INPUT, 4)

	// If there is no filtered output, this whole thing makes no sense
	if(!check_gassource(filtered))
		return

	var/datum/gas_mixture/filtered_air = filtered.return_air()
	if(!filtered_air)
		return

	// If no source is set, the source is possibly this circuit's content
	if(!check_gassource(source))
		source = src
	var/datum/gas_mixture/source_air = source.return_air()

	//No source air: source is this circuit
	if(!source_air)
		source_air = air_contents

	// If no filtering tank is set, filter through itself
	if(!check_gassource(contaminants))
		contaminants = src
	var/datum/gas_mixture/contaminated_air = contaminants.return_air()

	//If there is no gas mixture datum for unfiltered, pump the contaminants back into the circuit
	if(!contaminated_air)
		contaminated_air = air_contents

	if(contaminated_air.return_pressure() >= MAX_PUMP_PRESSURE || filtered_air.return_pressure() >= MAX_PUMP_PRESSURE)
		return

	var/datum/gas_mixture/sink_filtered = new
	var/datum/gas_mixture/sink_clean = new
	var/total_transfer_moles = target_pressure
	var/available_power = assembly.return_power()
	if(source_air.total_moles < MINIMUM_MOLES_TO_FILTER) //if we cant transfer enough gas just stop to avoid further processing
		return

	wanted = wanted & source_air.gas	//only filter gasses that are actually there. DO NOT USE &=

	var/total_specific_power = 0		//the power required to remove one mole of input gas
	var/total_filterable_moles = 0		//the total amount of filterable gas
	var/total_unfilterable_moles = 0	//the total amount of non-filterable gas
	var/list/specific_power_gas = list()	//the power required to remove one mole of pure gas, for each gas type
	for(var/g in source_air.gas)
		if(source_air.gas[g] < MINIMUM_MOLES_TO_FILTER)
			continue

		if(g in wanted)
			specific_power_gas[g] = calculate_specific_power_gas(g, source_air, sink_filtered)/ATMOS_FILTER_EFFICIENCY
			total_filterable_moles += source_air.gas[g]
		else
			specific_power_gas[g] = calculate_specific_power_gas(g, source_air, sink_clean)/ATMOS_FILTER_EFFICIENCY
			total_unfilterable_moles += source_air.gas[g]

		var/ratio = source_air.gas[g]/source_air.total_moles //converts the specific power per mole of pure gas to specific power per mole of input gas mix
		total_specific_power += specific_power_gas[g]*ratio

	//Figure out how much of each gas to filter
	if(isnull(total_transfer_moles))
		total_transfer_moles = source_air.total_moles
	else
		total_transfer_moles = min(total_transfer_moles, source_air.total_moles)

	//limit transfer_moles based on available power
	if(!isnull(available_power) && total_specific_power > 0)
		total_transfer_moles = min(total_transfer_moles, available_power/total_specific_power)

	if(total_transfer_moles < MINIMUM_MOLES_TO_FILTER) //if we cant transfer enough gas just stop to avoid further processing
		return -1


	var/datum/gas_mixture/removed = source_air.remove(total_transfer_moles)
	if (!removed) //Just in case
		return -1

	var/filtered_power_used = 0		//power used to move filterable gas to sink_filtered
	var/unfiltered_power_used = 0	//power used to move unfilterable gas to sink_clean
	for (var/g in removed.gas)
		var/power_used = specific_power_gas[g]*removed.gas[g]

		if (g in wanted)
			//use update=0. All the filtered gasses are supposed to be added simultaneously, so we update after the for loop.
			sink_filtered.adjust_gas_temp(g, removed.gas[g], removed.temperature, update=0)
			removed.adjust_gas(g, -removed.gas[g], update=0)
			filtered_power_used += power_used
		else
			unfiltered_power_used += power_used

	sink_filtered.update_values()
	removed.update_values()

	sink_clean.merge(removed)

	//Check if the pressure is high enough to put stuff in filtered, or else just put it back in the source
	if(filtered_air.return_pressure() < target_pressure)
		if(istype(filtered, /obj/item/weapon/tank))
			filtered.assume_air(sink_filtered)
		else
			filtered_air.merge(sink_filtered)
	else
		if(istype(source, /obj/item/weapon/tank))
			source.assume_air(sink_filtered)
		else
			source_air.merge(sink_filtered)
	if(istype(contaminants, /obj/item/weapon/tank))
		contaminants.assume_air(sink_clean)
	else
		contaminated_air.merge(sink_clean)

	activate_pin(2)
	assembly.draw_power(filtered_power_used + unfiltered_power_used)

// - gas mixer -
/obj/item/integrated_circuit/atmospherics/pump/mixer
	name = "gas mixer"
	desc = "Mixes different types of gases."
	complexity = 20
	size = 8
	spawn_flags = IC_SPAWN_RESEARCH
	inputs = list(
			"gas sources" = IC_PINTYPE_LIST,
			"output" = IC_PINTYPE_REF,
			"first source percentage" = IC_PINTYPE_NUMBER,
			"target pressure" = IC_PINTYPE_NUMBER
			)
	power_draw_per_use = 30

/obj/item/integrated_circuit/atmospherics/pump/mixer/do_work()
	var/list/obj/entities = get_pin_data(IC_INPUT, 1)
	if(!length(entities))
		return
	var/list/datum/gas_mixture/mix_sources = list()
	for(var/obj/entity in entities)
		if(check_gassource(entity))
			mix_sources.Add(entity)

	var/obj/gas_output = get_pin_data(IC_INPUT, 2)

	if(!check_gassource(gas_output))
		gas_output = src

	var/datum/gas_mixture/output_gases = gas_output.return_air()

	var/total_transfer_moles = target_pressure
	var/available_power = assembly.return_power()
	if(!length(mix_sources))
		return -1

	var/total_specific_power = 0	//the power needed to mix one mole of gas
	var/total_mixing_moles = null	//the total amount of gas that can be mixed, given our mix ratios
	var/total_input_volume = 0		//for flow rate calculation
	var/total_input_moles = 0		//for flow rate calculation
	var/list/source_specific_power = list()
	for(var/datum/gas_mixture/source in mix_sources)
		if(source.total_moles < MINIMUM_MOLES_TO_FILTER)
			continue

		var/mix_ratio = mix_sources[source]
		if (!mix_ratio)
			continue	//this gas is not being mixed in

		//mixing rate is limited by the source with the least amount of available gas
		var/this_mixing_moles = source.total_moles/mix_ratio
		if (isnull(total_mixing_moles) || total_mixing_moles > this_mixing_moles)
			total_mixing_moles = this_mixing_moles

		source_specific_power[source] = calculate_specific_power(source, output_gases)*mix_ratio/ATMOS_FILTER_EFFICIENCY
		total_specific_power += source_specific_power[source]
		total_input_volume += source.volume
		total_input_moles += source.total_moles

	if(total_mixing_moles < MINIMUM_MOLES_TO_FILTER) //if we cant transfer enough gas just stop to avoid further processing
		return

	if (isnull(total_transfer_moles))
		total_transfer_moles = total_mixing_moles
	else
		total_transfer_moles = min(total_mixing_moles, total_transfer_moles)

	//limit transfer_moles based on available power
	if(!isnull(available_power) && total_specific_power > 0)
		total_transfer_moles = min(total_transfer_moles, available_power / total_specific_power)

	if(total_transfer_moles < MINIMUM_MOLES_TO_FILTER) //if we cant transfer enough gas just stop to avoid further processing
		return -1

	var/total_power_draw = 0
	for (var/datum/gas_mixture/source in mix_sources)
		var/mix_ratio = mix_sources[source]
		if (!mix_ratio)
			continue

		var/transfer_moles = total_transfer_moles * mix_ratio

		var/datum/gas_mixture/removed = source.remove(transfer_moles)

		var/power_draw = transfer_moles * source_specific_power[source]
		total_power_draw += power_draw

		output_gases.merge(removed)

	activate_pin(2)
	assembly.draw_power(total_power_draw)

// - integrated tank -
/obj/item/integrated_circuit/atmospherics/tank
	name = "integrated tank"
	desc = "A small tank for the storage of gases."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	size = 4
	activators = list(
			"push ref" = IC_PINTYPE_PULSE_IN
			)
	volume = 3 //emergency tank sized
	var/broken = FALSE

/obj/item/integrated_circuit/atmospherics/tank/Initialize()
	START_PROCESSING(SSobj, src)
	. = ..()
	extended_desc = "Take care not to pressurize it above [round(TANK_FAILURE_PRESSURE)] kPa, or else it will break."

/obj/item/integrated_circuit/atmospherics/tank/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/integrated_circuit/atmospherics/tank/do_work()
	set_pin_data(IC_OUTPUT, 1, weakref(src))
	push_data()

/obj/item/integrated_circuit/atmospherics/tank/Process()
	var/tank_pressure = air_contents.return_pressure()
	set_pin_data(IC_OUTPUT, 2, tank_pressure)
	push_data()

	//Check if tank broken
	if(!broken && tank_pressure > TANK_FAILURE_PRESSURE)
		broken = TRUE
		to_chat(view(2), SPAN_NOTICE("The [name] ruptures, releasing its gases!"))
	if(broken)
		release()

/obj/item/integrated_circuit/atmospherics/tank/proc/release()
	if(air_contents.total_moles > 0)
		playsound(loc, 'sound/effects/spray.ogg', 10, 1, -3)
		var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles)
		var/turf/current_turf = get_turf(src)
		if(!isturf(current_turf))
			return
		var/datum/gas_mixture/exterior_gas = current_turf.return_air()
		exterior_gas.merge(expelled_gas)

// - large integrated tank -
/obj/item/integrated_circuit/atmospherics/tank/large
	name = "large integrated tank"
	desc = "A less small tank for the storage of gases."
	volume = 9
	size = 12
	spawn_flags = IC_SPAWN_RESEARCH


// - freezer tank -
/obj/item/integrated_circuit/atmospherics/tank/freezer
	name = "freezer tank"
	desc = "Cools the gas it contains to a preset temperature."
	volume = 6
	size = 8
	inputs = list(
		"target temperature" = IC_PINTYPE_NUMBER,
		"on" = IC_PINTYPE_BOOLEAN
		)
	inputs_default = list("1" = 300)
	spawn_flags = IC_SPAWN_RESEARCH
	var/temperature = 293.15
	var/heating_power = 40 KILOWATTS

/obj/item/integrated_circuit/atmospherics/tank/freezer/on_data_written()
	temperature = max(73.15,min(293.15,get_pin_data(IC_INPUT, 1)))
	if(get_pin_data(IC_INPUT, 2))
		power_draw_idle = 30
	else
		power_draw_idle = 0

/obj/item/integrated_circuit/atmospherics/tank/freezer/Process()
	var/is_on = get_pin_data(IC_INPUT, 1)
	var/obj/item/device/electronic_assembly/EA = get_object()
	if(!is_on || !istype(EA) || !EA.battery)
		return
	var/obj/item/weapon/cell/battery = EA.battery

	var/transfer_moles = 0.25 * air_contents.total_moles
	var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

	if(removed)
		var/heat_transfer = removed.get_thermal_energy_change(temperature)
		var/power_draw

		if(heat_transfer < 0) // cooling air
			heat_transfer = abs(heat_transfer)

			//Assume the heat is being pumped into the hull which is fixed at 20 C
			var/cop = removed.temperature/T20C	//coefficient of performance from thermodynamics -> power used = heat_transfer/cop

			heat_transfer = min(heat_transfer, cop * heating_power)	//limit heat transfer by available power

			heat_transfer = removed.add_thermal_energy(-heat_transfer)	//get the actual heat transfer

			power_draw = abs(heat_transfer)/cop

		battery.use(min((battery.maxcharge - battery.charge), power_draw))

		air_contents.merge(removed)
	..()

// - heater tank -
/obj/item/integrated_circuit/atmospherics/tank/freezer/heater
	name = "heater tank"
	desc = "Heats the gas it contains to a preset temperature."
	volume = 6
	inputs = list(
		"target temperature" = IC_PINTYPE_NUMBER,
		"on" = IC_PINTYPE_BOOLEAN
		)
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/atmospherics/tank/freezer/heater/on_data_written()
	temperature = max(293.15,min(573.15,get_pin_data(IC_INPUT, 1)))
	if(get_pin_data(IC_INPUT, 2))
		power_draw_idle = 30
	else
		power_draw_idle = 0

/obj/item/integrated_circuit/atmospherics/tank/freezer/heater/Process()
	var/is_on = get_pin_data(IC_INPUT, 2)
	var/obj/item/device/electronic_assembly/EA = get_object()
	if(!is_on || !istype(EA) || !EA.battery)
		return
	var/obj/item/weapon/cell/battery = EA.battery

	var/transfer_moles = 0.25 * air_contents.total_moles
	var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

	if(removed)
		var/heat_transfer = removed.get_thermal_energy_change(temperature)
		var/power_draw

		if(heat_transfer > 0) // heating air
			heat_transfer = min(heat_transfer, heating_power) //limit by the power rating of the heater

			removed.add_thermal_energy(heat_transfer)

			power_draw = heat_transfer

		battery.use(min((battery.maxcharge - battery.charge), power_draw))

		air_contents.merge(removed)
	..()

// - atmospheric cooler -
/obj/item/integrated_circuit/atmospherics/cooler
	name = "atmospheric cooler circuit"
	desc = "Cools the air around it."
	volume = 6
	size = 13
	spawn_flags = IC_SPAWN_RESEARCH
	inputs = list(
		"target temperature" = IC_PINTYPE_NUMBER,
		"on" = IC_PINTYPE_BOOLEAN
		)
	var/temperature = 293.15
	var/heating_power = 40 KILOWATTS

/obj/item/integrated_circuit/atmospherics/cooler/Initialize()
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/item/integrated_circuit/atmospherics/cooler/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/integrated_circuit/atmospherics/cooler/on_data_written()
	temperature = max(243.15,min(293.15,get_pin_data(IC_INPUT, 1)))
	if(get_pin_data(IC_INPUT, 2))
		power_draw_idle = 30
	else
		power_draw_idle = 0

/obj/item/integrated_circuit/atmospherics/cooler/Process()
	var/is_on = get_pin_data(IC_INPUT, 2)
	var/obj/item/device/electronic_assembly/EA = get_object()
	if(!is_on || !istype(EA) || !EA.battery)
		return
	var/obj/item/weapon/cell/battery = EA.battery
	var/datum/gas_mixture/env = loc.return_air()

	var/transfer_moles = 0.25 * env.total_moles
	var/datum/gas_mixture/removed = env.remove(transfer_moles)

	if(removed)
		var/heat_transfer = removed.get_thermal_energy_change(temperature)
		var/power_draw

		if(heat_transfer < 0) // cooling air
			heat_transfer = abs(heat_transfer)

			//Assume the heat is being pumped into the hull which is fixed at 20 C
			var/cop = removed.temperature/T20C	//coefficient of performance from thermodynamics -> power used = heat_transfer/cop

			heat_transfer = min(heat_transfer, cop * heating_power)	//limit heat transfer by available power

			heat_transfer = removed.add_thermal_energy(-heat_transfer)	//get the actual heat transfer

			power_draw = abs(heat_transfer)/cop

		battery.use(min((battery.maxcharge - battery.charge), power_draw))

		env.merge(removed)

	var/tank_pressure = env.return_pressure()
	set_pin_data(IC_OUTPUT, 2, tank_pressure)
	push_data()

// - atmospheric heater -
/obj/item/integrated_circuit/atmospherics/cooler/heater
	name = "atmospheric heater circuit"
	desc = "Heats the air around it."

/obj/item/integrated_circuit/atmospherics/cooler/heater/on_data_written()
	temperature = max(293.15,min(323.15,get_pin_data(IC_INPUT, 1)))
	if(get_pin_data(IC_INPUT, 2))
		power_draw_idle = 30
	else
		power_draw_idle = 0

/obj/item/integrated_circuit/atmospherics/cooler/heater/Process()
	var/is_on = get_pin_data(IC_INPUT, 2)
	var/obj/item/device/electronic_assembly/EA = get_object()
	if(!is_on || !istype(EA) || !EA.battery)
		return
	var/obj/item/weapon/cell/battery = EA.battery
	var/datum/gas_mixture/env = loc.return_air()

	var/transfer_moles = 0.25 * env.total_moles
	var/datum/gas_mixture/removed = env.remove(transfer_moles)

	if(removed)
		var/heat_transfer = removed.get_thermal_energy_change(temperature)
		var/power_draw

		if(heat_transfer > 0) // heating air
			heat_transfer = min(heat_transfer, heating_power) //limit by the power rating of the heater

			removed.add_thermal_energy(heat_transfer)

			power_draw = heat_transfer

		battery.use(min((battery.maxcharge - battery.charge), power_draw))

		env.merge(removed)

	var/tank_pressure = env.return_pressure()
	set_pin_data(IC_OUTPUT, 2, tank_pressure)
	push_data()

// - integrated connector - // Can't connect and disconnect properly
/obj/item/integrated_circuit/atmospherics/connector
	name = "integrated connector"
	desc = "Creates an airtight seal with standard connectors found on the floor, \
		 	allowing the assembly to exchange gases with a pipe network."
	extended_desc = "This circuit will automatically attempt to locate and connect to ports on the floor beneath it when activated. \
					You <b>must</b> set a target before connecting."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
			"target" = IC_PINTYPE_REF
			)
	activators = list(
			"toggle connection" = IC_PINTYPE_PULSE_IN,
			"on connected" = IC_PINTYPE_PULSE_OUT,
			"on connection failed" = IC_PINTYPE_PULSE_OUT,
			"on disconnected" = IC_PINTYPE_PULSE_OUT
			)

	ext_moved_triggerable = TRUE
	var/obj/machinery/atmospherics/portables_connector/connector

/obj/item/integrated_circuit/atmospherics/connector/Initialize()
	START_PROCESSING(SSobj, src)
	. = ..()

//Sucks up the gas from the connector
/obj/item/integrated_circuit/atmospherics/connector/Process()
	set_pin_data(IC_OUTPUT, 2, air_contents.return_pressure())


/obj/item/integrated_circuit/atmospherics/connector/check_gassource(atom/gasholder)
	if(!gasholder)
		return FALSE
	if(!istype(gasholder,/obj/machinery/atmospherics/portables_connector))
		return FALSE
	return TRUE

//If the assembly containing this is moved from the tile the connector pipe is in, the connection breaks
/obj/item/integrated_circuit/atmospherics/connector/ext_moved()
	if(connector)
		if(connector.Adjacent(get_object()))
			// The assembly is set as connected device and the connector handles the rest
			if(disconnect())
				activate_pin(4)

/obj/item/integrated_circuit/atmospherics/connector/do_work()
	// If there is a connection, disconnect
	if(connector)
		if(disconnect())
			activate_pin(4)
		return

	var/obj/machinery/atmospherics/portables_connector/PC = locate() in get_turf(src)
	// If no connector can't connect
	if(!check_gassource(PC))
		activate_pin(3)
		return
	connector = PC
	connector.connected_device = src
	connector.on = 1 //Activate port updates

	//Actually enforce the air sharing
	var/datum/pipe_network/network = connector.return_network(src)
	if(network && !network.gases.Find(air_contents))
		network.gases += air_contents
		network.update = 1

	activate_pin(2)

/obj/item/integrated_circuit/atmospherics/connector/proc/disconnect()
	if(!connector)
		return FALSE

	var/datum/pipe_network/network = connector.return_network(src)
	if(network)
		network.gases -= air_contents

	connector.connected_device = null
	connector = null
	return TRUE


// - tank slot -
/obj/item/integrated_circuit/input/tank_slot
	category_text = "Atmospherics"
	cooldown_per_use = 1
	name = "tank slot"
	desc = "Lets you add a tank to your assembly and remove it even when the assembly is closed."
	extended_desc = "It can help you extract gases easier."
	complexity = 25
	size = 30
	inputs = list()
	outputs = list(
		"pressure used" = IC_PINTYPE_NUMBER,
		"current tank" = IC_PINTYPE_REF
		)
	activators = list(
		"push ref" = IC_PINTYPE_PULSE_OUT,
		"on insert" = IC_PINTYPE_PULSE_OUT,
		"on remove" = IC_PINTYPE_PULSE_OUT
		)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

	can_be_asked_input = TRUE
	demands_object_input = TRUE
	can_input_object_when_closed = TRUE

	var/obj/item/weapon/tank/current_tank

/obj/item/integrated_circuit/input/tank_slot/Initialize()
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/item/integrated_circuit/input/tank_slot/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/integrated_circuit/input/tank_slot/Process()
	push_pressure()

/obj/item/integrated_circuit/input/tank_slot/proc/push_pressure()
	if(!current_tank)
		set_pin_data(IC_OUTPUT, 1, 0)
		return

	var/datum/gas_mixture/tank_air = current_tank.return_air()
	if(!tank_air)
		set_pin_data(IC_OUTPUT, 1, 0)
		return

	set_pin_data(IC_OUTPUT, 1, tank_air.return_pressure())
	push_data()

/obj/item/integrated_circuit/input/tank_slot/attackby(obj/item/weapon/W, mob/user)
	if(!istype(W, /obj/item/weapon/tank))
		to_chat(user, SPAN("warning", "The [W.name] doesn't seem to fit in here."))
		return

	if(current_tank)
		to_chat(user, SPAN("warning", "There is already a gas tank inside."))
		return

	current_tank = W
	user.drop_item(W)
	W.forceMove(src)

	//Set the pin to a weak reference of the current tank
	push_pressure()
	set_pin_data(IC_OUTPUT, 2, weakref(current_tank))
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/tank_slot/attack_self(mob/user)
	if(!current_tank)
		to_chat(user, SPAN("notice", "There is currently no tank attached."))

	to_chat(user, SPAN("notice", "You take [current_tank] out of the tank slot."))
	user.put_in_hands(current_tank)
	current_tank = null

	//Remove tank reference
	push_pressure()
	set_pin_data(IC_OUTPUT, 2, null)
	push_data()
	activate_pin(3)

/obj/item/integrated_circuit/input/tank_slot/ask_for_input(mob/user)
	attack_self(user)

#undef SOURCE_TO_TARGET
#undef TARGET_TO_SOURCE
#undef PUMP_EFFICIENCY
#undef TANK_FAILURE_PRESSURE
#undef PUMP_MAX_VOLUME
