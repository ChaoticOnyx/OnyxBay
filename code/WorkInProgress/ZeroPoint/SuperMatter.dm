/obj/machinery/engine/supermatter
	name = "Supermatter"
	icon = 'engine.dmi'
	icon_state = "darkmatter"

	density = 1


	var/gasefficency = 0.25


/obj/machinery/engine/supermatter/process()
	//power, the total power of all the lasers
	var/power = 0

	var/turf/T = get_turf(src)
	for(var/dir in list(NORTH,SOUTH,EAST,WEST))
		var/turf/Z = get_step(T,dir)

		for(var/item in Z.contents)
			if(istype(item,/obj/beam/e_beam))
				power += item:power

	//Ok, get the air from the turf
	var/turf/simulated/L = loc
	if(istype(L))
		var/datum/gas_mixture/env = L.return_air()

		//Remove gas from surrounding area
		var/transfer_moles = gasefficency * env.total_moles()
		var/datum/gas_mixture/removed = env.remove(transfer_moles)

		//Ok, 100% oxygen atmosphere = best reaction
		//Maxes out at 100% oxygen pressure
		var/oxygen = max((removed.oxygen/(MOLES_CELLSTANDARD*gasefficency)),1)


		var/device_energy = oxygen*power
		if(device_energy >= 1000)
			device_energy += (2000*(removed.temperature/500))

		world << device_energy

		//Ok, start by calculating how much heat to apply
		//4 Lasers = 500*4 = 2000 at default power
		//This should heat up the core by 4C per process
		//But only 25% of the turfs atmos is being affected
		//So 1C per process
		//Assuming enough oxygen for full reaction
		removed.temperature += max((device_energy/4),0)


		//Ok, calculate how much PLASMA to add to the inferno
		//Fix this up later
		removed.toxins += 10

		if(removed.temperature > 3000) // Oh god an overload
			removed.oxygen += 1000
			removed.toxins += 1000




		env.merge(removed)


		/*

	process()
		if(on)
			if(cell && cell.charge > 0)

				var/turf/simulated/L = loc
				if(istype(L))
					var/datum/gas_mixture/env = L.return_air()
					if(env.temperature < (set_temperature+T0C))

						var/transfer_moles = 0.25 * env.total_moles()

						var/datum/gas_mixture/removed = env.remove(transfer_moles)

						//world << "got [transfer_moles] moles at [removed.temperature]"

						if(removed)

							var/heat_capacity = removed.heat_capacity()
							//world << "heating ([heat_capacity])"
							removed.temperature = (removed.temperature*heat_capacity + heating_power)/heat_capacity
							cell.use(heating_power/20000)

							//world << "now at [removed.temperature]"

						env.merge(removed)

						//world << "turf now at [env.temperature]"


			else
				on = 0
				update_icon()


		return
*/