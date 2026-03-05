/obj/item/mcu_module/env_sensor
	name = "environment sensor module"
	desc = "An environment sensor module"
	icon_state = "env_sensor"

	device_type = Z_DEVICE_TYPE_ENV_SENSOR

/obj/item/mcu_module/env_sensor/think()
	var/obj/item/device/mcu/M = __host.resolve()

	if(QDELETED(M))
		return

	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_ENV_SENSOR_B2N_CMD_READY_STATUS, TRUE) == TRUE)

	return

/obj/item/mcu_module/env_sensor/proc/__update_readings(datum/gas_mixture/G, turf/T, alpha_rays, beta_rays, hawking_rays)
	var/list/atmos = list(
		G.total_moles,
		G.return_pressure() * 1000,
		G.temperature,
		G.gas["oxygen"],
		G.gas["nitrogen"],
		G.gas["carbon_dioxide"],
		G.gas["hydrogen"],
		G.gas["plasma"],
	)

	var/total_dose = 0
	var/total_activity = 0
	var/total_energy = 0
	var/sources_count = 0
	var/sources = SSradiation.get_sources_in_range(src)

	for(var/datum/radiation_source/source in sources)
		if(!source.info.is_ionizing())
			continue

		if(source.info.radiation_type == RADIATION_ALPHA_PARTICLE && !alpha_rays)
			continue
		
		if(source.info.radiation_type == RADIATION_BETA_PARTICLE && !beta_rays)
			continue

		if(source.info.radiation_type == RADIATION_HAWKING && !hawking_rays)
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
	
	var/list/radiation = list(
		total_activity / (sources_count == 0 ? 1 : sources_count),
		total_energy / (sources_count == 0 ? 1 : sources_count),
		total_dose,
	)

	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_ENV_SENSOR_B2N_CMD_UPDATE, atmos, radiation) == TRUE)

/obj/item/mcu_module/env_sensor/__syscall(cmd, ...)
	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_APPEND_COUNTERS(M.id, 0, 1000, 0))
	
	switch(cmd)
		if(Z_ENV_SENSOR_N2B_CMD_UPDATE)
			ASSERT(Z_MACHINE_APPEND_COUNTERS(M.id, 0, 5000, 0))
			var/turf/T = get_turf(src)
			var/datum/gas_mixture/G = return_air()

			if(!T || !G)
				return FALSE

			__update_readings(G, T, args[2], args[3], args[4])

			ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_ENV_SENSOR_B2N_CMD_READY_STATUS, FALSE) == TRUE)
			set_next_think(world.time + config.mcu.env_sensor_cooldown)

			return TRUE

	return FALSE

/obj/item/mcu_module/env_sensor/__reset(attached)
	set_next_think(0)

	if(!attached)
		return

	var/turf/T = get_turf(src)
	var/datum/gas_mixture/G = return_air()

	if(T && G)
		__update_readings(G, T, FALSE, FALSE, FALSE)

	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_ENV_SENSOR_B2N_CMD_READY_STATUS, TRUE) == TRUE)
