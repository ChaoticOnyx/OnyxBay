/datum/pipeline
	var/datum/gas_mixture/air

	var/list/obj/machinery/atmospherics/pipe/members
	var/list/obj/machinery/atmospherics/pipe/edges //Used for building networks

	var/datum/pipe_network/network
	// Leaking nodes
	var/list/leaks = list()

	var/alert_pressure = 0

	#ifdef TESTING
	var/global/pipelines_count = 0
	var/pipeline_id = 0
	#endif

/datum/pipeline/New()
	set_next_think(world.time + 1 SECOND)
	air = new

/datum/pipeline/Destroy()
	#ifdef TESTING
	to_world_log("Destroying pipeline #[pipeline_id] (\ref[src]).")
	#endif
	QDEL_NULL(network)

	if(air?.volume)
		for(var/obj/machinery/atmospherics/pipe/member in members)
			var/datum/gas_mixture/G = new
			G.copy_from(air)
			G.volume = member.volume
			G.multiply(member.volume / air.volume)
			member.air_temporary = G
			member.parent = null
	else
		for(var/obj/machinery/atmospherics/pipe/member in members)
			member.air_temporary = null
			member.parent = null

	QDEL_NULL(air)

	leaks.Cut()
	for(var/atom/movable/member in members)
		unregister_signal(member, SIGNAL_QDELETING)
	members.Cut()
	for(var/atom/movable/edge in edges)
		unregister_signal(edge, SIGNAL_QDELETING)
	edges.Cut()
	. = ..()
	return QDEL_HINT_QUEUE

/datum/pipeline/think()//This use to be called called from the pipe networks
	//Check to see if pressure is within acceptable limits
	var/pressure = air.return_pressure()
	if(pressure > alert_pressure)
		for(var/obj/machinery/atmospherics/pipe/member in members)
			if(!member.check_pressure(pressure))
				members.Remove(member)
				break //Only delete 1 pipe per process

	set_next_think(world.time + 1.5 SECONDS)

/datum/pipeline/proc/build_pipeline(obj/machinery/atmospherics/pipe/base)
	if(QDELETED(base) || base.getting_pipelined)
		qdel(src)
		return
	#ifdef TESTING
	pipelines_count++
	pipeline_id = pipelines_count
	to_world_log("Building pipeline #[pipeline_id] (\ref[src]).")
	#endif
	var/list/possible_expansions = list(base)
	members = list(base)
	edges = list()

	var/volume = base.volume
	base.parent = src
	alert_pressure = base.alert_pressure

	if(base.air_temporary)
		air.copy_from(base.air_temporary)
		qdel(base.air_temporary)
		base.air_temporary = null

	if(base.leaking)
		leaks |= base

	while(possible_expansions.len > 0)
		for(var/obj/machinery/atmospherics/pipe/borderline in possible_expansions)
			if(QDELETED(borderline))
				continue
			var/list/result = borderline.pipeline_expansion()
			var/edge_check = result.len

			if(result.len > 0)
				for(var/obj/machinery/atmospherics/pipe/item in result)
					if(QDELETED(item) || item.getting_pipelined || item.in_stasis)
						continue
					if(!members.Find(item))
						if(!possible_expansions.Find(item))
							possible_expansions += item
						item.getting_pipelined = TRUE
						members += item
						register_signal(item, SIGNAL_QDELETING, nameof(.proc/on_member_qdel))

						volume += item.volume

						item.parent = src

						alert_pressure = min(alert_pressure, item.alert_pressure)

						if(item.air_temporary)
							air.merge(item.air_temporary)
							qdel(item.air_temporary)
							item.air_temporary = null

						if(item.leaking)
							leaks |= item

					edge_check--

			if(edge_check > 0)
				edges += borderline
				register_signal(borderline, SIGNAL_QDELETING, nameof(.proc/on_borderline_qdel))

			possible_expansions -= borderline

	air.volume = volume

	for(var/obj/machinery/atmospherics/pipe/item in members)
		item.getting_pipelined = FALSE

/datum/pipeline/proc/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)

	if(new_network.line_members.Find(src))
		return 0

	new_network.line_members += src

	network = new_network
	network.leaks |= leaks

	for(var/obj/machinery/atmospherics/pipe/edge in edges)
		for(var/obj/machinery/atmospherics/result in edge.pipeline_expansion())
			if(!istype(result,/obj/machinery/atmospherics/pipe) && (result!=reference))
				result.network_expand(new_network, edge)


	return 1

/datum/pipeline/proc/return_network(obj/machinery/atmospherics/reference)
	if(!network)
		network = new /datum/pipe_network()
		network.build_network(src, null)
			//technically passing these parameters should not be allowed
			//however pipe_network.build_network(..) and pipeline.network_extend(...)
			//		were setup to properly handle this case

	return network

/datum/pipeline/proc/mingle_with_turf(turf/simulated/target, mingle_volume)
	var/datum/gas_mixture/air_sample = air.remove_ratio(mingle_volume/air.volume)
	air_sample.volume = mingle_volume

	if(istype(target) && target.zone)
		//Have to consider preservation of group statuses
		var/datum/gas_mixture/turf_copy = new

		turf_copy.copy_from(target.zone.air)
		turf_copy.volume = target.zone.air.volume //Copy a good representation of the turf from parent group

		equalize_gases(list(air_sample, turf_copy))
		air.merge(air_sample)

		turf_copy.subtract(target.zone.air)

		target.zone.air.merge(turf_copy)

	else
		var/datum/gas_mixture/turf_air = target.return_air()

		equalize_gases(list(air_sample, turf_air))
		air.merge(air_sample)
		//turf_air already modified by equalize_gases()

	if(network)
		network.update = 1

/datum/pipeline/proc/temperature_interact(turf/target, share_volume, thermal_conductivity)
	var/total_heat_capacity = air.heat_capacity()
	var/partial_heat_capacity = total_heat_capacity*(share_volume/air.volume)

	if(istype(target, /turf/simulated))
		var/turf/simulated/modeled_location = target

		if(modeled_location.blocks_air)

			if((modeled_location.heat_capacity>0) && (partial_heat_capacity>0))
				var/delta_temperature = air.temperature - modeled_location.temperature

				var/heat = thermal_conductivity*delta_temperature* \
					(partial_heat_capacity*modeled_location.heat_capacity/(partial_heat_capacity+modeled_location.heat_capacity))

				air.temperature -= heat/total_heat_capacity
				modeled_location.temperature += heat/modeled_location.heat_capacity

		else
			var/delta_temperature = 0
			var/sharer_heat_capacity = 0

			if(modeled_location.zone)
				delta_temperature = (air.temperature - modeled_location.zone.air.temperature)
				sharer_heat_capacity = modeled_location.zone.air.heat_capacity()
			else
				delta_temperature = (air.temperature - modeled_location.air.temperature)
				sharer_heat_capacity = modeled_location.air.heat_capacity()

			var/self_temperature_delta = 0
			var/sharer_temperature_delta = 0

			if((sharer_heat_capacity>0) && (partial_heat_capacity>0))
				var/heat = thermal_conductivity*delta_temperature* \
					(partial_heat_capacity*sharer_heat_capacity/(partial_heat_capacity+sharer_heat_capacity))

				self_temperature_delta = -heat/total_heat_capacity
				sharer_temperature_delta = heat/sharer_heat_capacity
			else
				return 1

			air.temperature += self_temperature_delta

			if(modeled_location.zone)
				modeled_location.zone.air.temperature += sharer_temperature_delta/modeled_location.zone.air.group_multiplier
			else
				modeled_location.air.temperature += sharer_temperature_delta


	else
		if((target.heat_capacity>0) && (partial_heat_capacity>0))
			var/delta_temperature = air.temperature - target.temperature

			var/heat = thermal_conductivity*delta_temperature* \
				(partial_heat_capacity*target.heat_capacity/(partial_heat_capacity+target.heat_capacity))

			air.temperature -= heat/total_heat_capacity
	if(network)
		network.update = 1

//surface must be the surface area in m^2
/datum/pipeline/proc/radiate_heat_to_space(surface, thermal_conductivity)
	var/gas_density = air.total_moles/air.volume
	thermal_conductivity *= min(gas_density / ( RADIATOR_OPTIMUM_PRESSURE/(R_IDEAL_GAS_EQUATION*GAS_CRITICAL_TEMPERATURE) ), 1) //mult by density ratio

	var/heat_gain = get_thermal_radiation(air.temperature, surface, RADIATOR_EXPOSED_SURFACE_AREA_RATIO, thermal_conductivity)

	air.add_thermal_energy(heat_gain)
	if(network)
		network.update = 1

//Returns the amount of heat gained while in space due to thermal radiation (usually a negative value)
//surface - the surface area in m^2
//exposed_surface_ratio - the proportion of the surface that is exposed to sunlight
//thermal_conductivity - a multipler on the heat transfer rate. See OPEN_HEAT_TRANSFER_COEFFICIENT and friends
/proc/get_thermal_radiation(surface_temperature, surface, exposed_surface_ratio, thermal_conductivity)
	//*** Gain heat from sunlight, then lose heat from radiation.

	// We only get heat from the star on the exposed surface area.
	// If the HE pipes gain more energy from AVERAGE_SOLAR_RADIATION than they can radiate, then they have a net heat increase.
	. = AVERAGE_SOLAR_RADIATION * (exposed_surface_ratio * surface) * thermal_conductivity

	// Previously, the temperature would enter equilibrium at 26C or 294K.
	// Only would happen if both sides (all 2 square meters of surface area) were exposed to sunlight.  We now assume it aligned edge on.
	// It currently should stabilise at 129.6K or -143.6C
	. -= surface * STEFAN_BOLTZMANN_CONSTANT * thermal_conductivity * (surface_temperature - COSMIC_RADIATION_TEMPERATURE) ** 4

/datum/pipeline/proc/on_borderline_qdel(atom/movable/former_member)
	qdel_self()

/datum/pipeline/proc/on_member_qdel(atom/movable/former_member)
	qdel_self()
