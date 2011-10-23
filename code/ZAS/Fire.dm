var/IgnitionLevel = 3 //Moles of oxygen+plasma - co2 needed to burn.

#define OXYGEN
atom/proc/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return null

turf/proc/hotspot_expose(exposed_temperature, exposed_volume, soh = 0)

turf/simulated/hotspot_expose(exposed_temperature, exposed_volume, soh)
	var/datum/gas_mixture/air_contents = return_air(1)
	if(!air_contents)
		return 0

  /*if(active_hotspot)
		if(soh)
			if(air_contents.toxins > 0.5 && air_contents.oxygen > 0.5)
				if(active_hotspot.temperature < exposed_temperature)
					active_hotspot.temperature = exposed_temperature
				if(active_hotspot.volume < exposed_volume)
					active_hotspot.volume = exposed_volume
		return 1*/
	var/igniting = 0
	if(locate(/obj/fire) in src)
		return 1
	var/datum/gas/volatile_fuel/fuel = locate() in air_contents.trace_gases
	var/fuel_level = 0
	if(fuel)
		fuel_level = fuel.moles
	if((air_contents.oxygen + air_contents.toxins + fuel_level*1.5) - (air_contents.carbon_dioxide*0.25) > IgnitionLevel && air_contents.toxins > 0.5)
		igniting = 1
		if(air_contents.oxygen < 0.5 || air_contents.toxins < 0.5)
			return 0

		if(parent&&parent.group_processing)
			parent.suspend_group_processing()

		if(! (locate(/obj/fire) in src))
			var/obj/fire/F = new(src,1000)
			F.temperature = exposed_temperature
			F.volume = CELL_VOLUME

		//active_hotspot.just_spawned = (current_cycle < air_master.current_cycle)
		//remove just_spawned protection if no longer processing this cell

	return igniting

obj/hotspot
	//Icon for fire on turfs, also helps for nurturing small fires until they are full tile

	anchored = 1

	mouse_opacity = 0

	//luminosity = 3

	icon = 'fire.dmi'
	icon_state = "1"

	layer = TURF_LAYER

	var
		volume = 125
		temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST

		just_spawned = 1

		bypassing = 0

obj/hotspot/proc/perform_exposure()
	var/turf/simulated/floor/location = loc
	if(!istype(location))
		return 0

	if(volume > CELL_VOLUME*0.95)
		bypassing = 1
	else bypassing = 0

	if(bypassing)
		if(!just_spawned)
			volume = location.air.fuel_burnt*FIRE_GROWTH_RATE
			temperature = location.air.temperature
	else
		var/datum/gas_mixture/affected = location.air.remove_ratio(volume/location.air.volume)

		affected.temperature = temperature

		affected.react()

		temperature = affected.temperature
		volume = affected.fuel_burnt*FIRE_GROWTH_RATE

		location.assume_air(affected)

		for(var/atom/item in loc)
			item.temperature_expose(null, temperature, volume)

obj/hotspot/proc/process(turf/simulated/list/possible_spread)
	if(just_spawned)
		just_spawned = 0
		return 0

	var/turf/simulated/floor/location = loc
	if(!istype(location))
		del(src)

	if((temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST) || (volume <= 1))
		del(src)

	if(location.air.toxins < 0.5 || location.air.oxygen < 0.5)
		del(src)


	perform_exposure()

	if(location.wet) location.wet = 0

	if(bypassing)
		icon_state = "3"
		location.burn_tile()

		//Possible spread due to radiated heat
		if(location.air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
			var/radiated_temperature = location.air.temperature*FIRE_SPREAD_RADIOSITY_SCALE

			for(var/turf/simulated/possible_target in possible_spread)
				if(!possible_target.active_hotspot)
					possible_target.hotspot_expose(radiated_temperature, CELL_VOLUME/4)

	else
		if(volume > CELL_VOLUME*0.4)
			icon_state = "2"
		else
			icon_state = "1"

	return 1

obj/hotspot/New()
	..()
	dir = pick(cardinal)
	ul_SetLuminosity(3)

obj/hotspot/Del()
	loc:active_hotspot = null
	src.ul_SetLuminosity(0)
	loc = null
	..()

var
	fire_ratio_1 = 0.05

obj
	fire
		//Icon for fire on turfs, also helps for nurturing small fires until they are full tile

		anchored = 1
		mouse_opacity = 0

		//luminosity = 3

		icon = 'fire.dmi'
		icon_state = "1"

		layer = TURF_LAYER

		var
			volume = CELL_VOLUME
			temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
			firelevel = 10000
			archived_firelevel = 0

		proc/process()
			if(firelevel > IgnitionLevel)
				var/turf/simulated/floor/S = loc
				if(!S.zone) del src
				//src.temperature += (src.firelevel/FireTempDivider+FireOffset - src.temperature) / FireRate
				if(istype(S,/turf/simulated/floor))
					var/datum/gas_mixture/air_contents = S.return_air()
					var/datum/gas/volatile_fuel/fuel = locate(/datum/gas/volatile_fuel/) in air_contents.trace_gases
					var/fuel_level = 0
					if(fuel)
						fuel_level = fuel.moles
					firelevel = (air_contents.oxygen + air_contents.toxins + fuel_level*1.5) - (air_contents.carbon_dioxide*0.25)

					if(firelevel > IgnitionLevel * 1.5)
						for(var/direction in cardinal)
							if(S.air_check_directions&direction) //Grab all valid bordering tiles
								var/turf/simulated/enemy_tile = get_step(S, direction)
								if(istype(enemy_tile))
									if(!(locate(/obj/fire) in enemy_tile) && prob(65))
										new/obj/fire(enemy_tile,firelevel)
									//else
									//	world << "There's a fire there bitch."
								//else
								//	world << "[enemy_tile] cannot be spread to."
					//else
					//	world << "Not enough firelevel to spread: [firelevel]/[IgnitionLevel*1.5]"

					var/datum/gas_mixture/flow = air_contents.remove_ratio(0.5)
					//n = PV/RT, taking the volume of a single tile from the gas.

					if(flow)

						if(flow.oxygen > 0.3 && (flow.toxins || fuel_level))

							icon_state = "1"
							if(firelevel > IgnitionLevel * 2)
								icon_state = "2"
							if(firelevel > IgnitionLevel * 3.5)
								icon_state = "3"

							if(flow.toxins)
								if(flow.temperature < PLASMA_UPPER_TEMPERATURE)
									flow.temperature += (vsc.FIRE_PLASMA_ENERGY_RELEASED*fire_ratio_1) / flow.heat_capacity()

							if(fuel_level)
								if(flow.temperature < PLASMA_UPPER_TEMPERATURE)
									flow.temperature += (vsc.FIRE_CARBON_ENERGY_RELEASED*fire_ratio_1) / flow.heat_capacity()

							if(flow.toxins > fire_ratio_1)
								flow.oxygen -= vsc.OXY_TO_PLASMA*fire_ratio_1
								flow.toxins -= fire_ratio_1
								flow.carbon_dioxide += fire_ratio_1
							else if(flow.toxins)
								flow.oxygen -= flow.toxins * vsc.OXY_TO_PLASMA
								flow.carbon_dioxide += flow.toxins
								flow.toxins = 0

							if(fuel_level > fire_ratio_1/1.5)
								flow.oxygen -= vsc.OXY_TO_PLASMA*fire_ratio_1
								fuel.moles -= fire_ratio_1
								flow.carbon_dioxide += fire_ratio_1
							else if(fuel_level)
								flow.oxygen -= fuel.moles * vsc.OXY_TO_PLASMA
								flow.carbon_dioxide += fuel.moles
								fuel.moles = 0

						else
							del src


						S.assume_air(flow)
					else
						//world << "No air at all."
						del src
				else
					del src
			else
				//world << "Insufficient fire level for ignition: [firelevel]/[IgnitionLevel]"
				del src


		New(newLoc,fl)
			..()
			dir = pick(cardinal)
			ul_SetLuminosity(3)
			firelevel = fl

		Del()
			if (istype(loc, /turf/simulated))
				src.ul_SetLuminosity(0)

				loc = null

			..()