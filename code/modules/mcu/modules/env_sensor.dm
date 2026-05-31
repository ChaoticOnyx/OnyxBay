/obj/item/mcu_module/env_sensor
	name = "environment sensor module"
	desc = "An environment sensor module"
	icon_state = "env_sensor"

/obj/item/mcu_module/env_sensor/think()
	ready = TRUE

/obj/item/mcu_module/env_sensor/__reset(attached)
	set_next_think(0)
	ready = TRUE

/obj/item/mcu_module/env_sensor/proc/__get_stats_function()
	if(!ready)
		return Z_SCRIPT_FUNCTION_ERROR

	var/obj/item/device/mcu/M = __host.resolve()

	var/turf/T = get_turf(src)
	var/datum/gas_mixture/G = T.return_air()

	M.__script.set_var(args[1], G.temperature, Z_SCRIPT_VAR_CAST_INT)
	M.__script.set_var(args[2], G.return_pressure() * 1000, Z_SCRIPT_VAR_CAST_INT)
	M.__script.set_var(args[3], G.get_total_moles(), Z_SCRIPT_VAR_CAST_NONE)

	ready = FALSE
	set_next_think(world.time + config.mcu.env_sensor_cooldown)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/mcu_module/env_sensor/proc/__get_gases_function()
	if(!ready)
		return Z_SCRIPT_FUNCTION_ERROR
	
	var/obj/item/device/mcu/M = __host.resolve()

	var/turf/T = get_turf(src)
	var/datum/gas_mixture/G = T.return_air()

	var/i = 1

	for(var/gas in list("oxygen", "nitrogen", "carbon_dioxide", "hydrogen", "plasma"))
		var/value = G.gas[gas]

		if(value == null)
			value = 0.0
		
		M.__script.set_var(args[i], value, Z_SCRIPT_VAR_CAST_NONE)
		i += 1

	ready = FALSE
	set_next_think(world.time + config.mcu.env_sensor_cooldown)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/mcu_module/env_sensor/proc/__get_radiation_function()
	if(!ready)
		return Z_SCRIPT_FUNCTION_ERROR

	var/turf/T = get_turf(src)
	var/rays = args[1]

	var/total_dose = 0
	var/total_activity = 0
	var/total_energy = 0
	var/sources_count = 0
	var/sources = SSradiation.get_sources_in_range(src)

	for(var/datum/radiation_source/source in sources)
		if(!source.info.is_ionizing())
			continue

		if(source.info.radiation_type == RADIATION_ALPHA_PARTICLE && (rays & ENV_SENSOR_ALPHA_RAYS) == 0)
			continue
		
		if(source.info.radiation_type == RADIATION_BETA_PARTICLE && (rays & ENV_SENSOR_BETA_RAYS) == 0)
			continue

		if(source.info.radiation_type == RADIATION_HAWKING && (rays & ENV_SENSOR_HAWKING_RAYS) == 0)
			continue

		var/datum/radiation/R = source.travel(T)
		var/energy = R.energy

		if(energy <= 0)
			continue

		var/dose = R.calc_absorbed_dose(AVERAGE_HUMAN_WEIGHT)

		total_dose += dose * 1000
		total_activity += CONV_BECQUEREL_QURIE(R.activity)
		total_energy += energy
		sources_count += 1
	
	var/avg_activity = total_activity / (sources_count == 0 ? 1 : sources_count)
	var/avg_energy = total_energy / (sources_count == 0 ? 1 : sources_count)

	var/obj/item/device/mcu/M = __host.resolve()
	M.__script.set_var(args[2], total_dose, Z_SCRIPT_VAR_CAST_NONE)
	M.__script.set_var(args[3], total_activity, Z_SCRIPT_VAR_CAST_NONE)
	M.__script.set_var(args[4], total_energy, Z_SCRIPT_VAR_CAST_NONE)
	M.__script.set_var(args[5], avg_activity, Z_SCRIPT_VAR_CAST_NONE)
	M.__script.set_var(args[6], avg_energy, Z_SCRIPT_VAR_CAST_NONE)

	ready = FALSE
	set_next_think(world.time + config.mcu.env_sensor_cooldown)

	return Z_SCRIPT_FUNCTION_OK
