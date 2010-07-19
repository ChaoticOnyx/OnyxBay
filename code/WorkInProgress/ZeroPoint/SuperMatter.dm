#define NITROGEN_RETARDATION_FACTOR 4	//Higher == N2 slows reaction more
#define THERMAL_RELEASE_MODIFIER 50		//Higher == less heat released during reaction
#define PLASMA_RELEASE_MODIFIER 750		//Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 1500	//Higher == less oxygen released at high temperature/power

/obj/machinery/engine/supermatter
	name = "Supermatter"
	desc = "A strangely translucent and iridescent crystal.  \red You get headaches just from looking at it."
	icon = 'engine.dmi'
	icon_state = "darkmatter"

	density = 1
	anchored = 1

	var/gasefficency = 0.25


/obj/machinery/engine/supermatter/process()

	var/turf/simulated/L = loc

	//Ok, get the air from the turf
	var/datum/gas_mixture/env = L.return_air()

	//Remove gas from surrounding area
	var/transfer_moles = gasefficency * env.total_moles()
	var/datum/gas_mixture/removed = env.remove(transfer_moles)

	if (!removed)
		return 1

	var/power = max(round((removed.temperature - T0C) / 20), 0) //Total laser power plus an overload factor

	for(var/dir in cardinal)
		var/turf/T = get_step(L, dir)
		for(var/obj/beam/e_beam/item in T)
			power += item.power


	//Ok, 100% oxygen atmosphere = best reaction
	//Maxes out at 100% oxygen pressure
	var/oxygen = max(min((removed.oxygen - (removed.nitrogen * NITROGEN_RETARDATION_FACTOR)) / MOLES_CELLSTANDARD, 1), 0)

	var/device_energy = oxygen * power

	device_energy *= removed.temperature / T0C

	device_energy = round(device_energy)

	//To figure out how much temperature to add each tick, consider that at one atmosphere's worth
	//of pure oxygen, with all four lasers firing at standard energy and no N2 present, at room temperature
	//that the device energy is around 2140.  At that stage, we don't want too much heat to be put out
	//Since the core is effectively "cold"

	//world << "T: [removed.temperature] O: [removed.oxygen] - [removed.nitrogen] => [oxygen]"
	//world << "P: [power] D: [device_energy]"

	//Also keep in mind we are only adding this temperature to (efficiency)% of the one tile the rock
	//is on.  An increase of 4*C here results in an increase of 1*C / (#tilesincore) overall.
	removed.temperature += max((device_energy / THERMAL_RELEASE_MODIFIER), 0)

	//Calculate how much gas to release
	removed.toxins += max(round(device_energy / PLASMA_RELEASE_MODIFIER), 0)

	removed.oxygen += max(round((device_energy + removed.temperature - T0C) / OXYGEN_RELEASE_MODIFIER), 0)

	//world << "T: [removed.temperature] Pl: [removed.toxins] O: [removed.oxygen]"
	//world << "-----------------------------------------------------------------"

	env.merge(removed)

	return 1