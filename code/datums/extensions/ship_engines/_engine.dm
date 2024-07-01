GLOBAL_LIST_EMPTY(ship_engines)
/datum/extension/ship_engine
	expected_type = /obj/machinery
	flags = EXTENSION_FLAG_IMMEDIATE

	// Stateful variables about a ship engine.
	var/thrust_limit	= 1				// How much of available thrust to use.
	var/next_on			= 0				// When the engine can next fire.
	var/engine_type		= "thruster"	// A fancy name to use for display purposes on the type of engine.
	var/blockage		= FALSE			// Is the engine blocked and unable to fire?
	var/boot_time		= 35			// How long does the engine take to boot?

	var/volume_per_burn = 40			// Amount in litres of propellant to use per burn.
	var/charge_per_burn = 36000 		//10Wh for default 2 capacitor, chews through that battery power! Makes a trade off of fuel efficient vs energy efficient

/datum/extension/ship_engine/New(holder, e_type)
	..()
	engine_type = e_type
	GLOB.ship_engines |= src

/datum/extension/ship_engine/Destroy()
	GLOB.ship_engines -= src
	for(var/obj/structure/overmap/S in SSstar_system.ships)
		S.engines -= src
	return ..()

/datum/extension/ship_engine/proc/is_on()
	var/obj/machinery/M = holder
	M.power_change()
	if(M.use_power && M.operable(MAINT))
		if(next_on > world.time)
			return FALSE

		else
			return TRUE

	return FALSE

/// Checks whether the engine has enough fuel to be operational.
/datum/extension/ship_engine/proc/has_fuel()
	return TRUE

// Does a specific impulse burn, using only immediate fuel.
// Returns actual exhaust velocity (ve m/s) produced as a result of the burn.
// Power is a 0-1 notation of how much potential thrust to put into the burn.
// Useful when acceleration limiting is in effect to save fuel.
/datum/extension/ship_engine/proc/burn(power = 1)

// Can the engine burn/ignite?
/datum/extension/ship_engine/proc/can_burn()
	return is_on() && has_fuel()

// Gets a friendly string for the engine's status to display to a pilot.
/datum/extension/ship_engine/proc/get_status()
	. = list()
	var/obj/machinery/M = holder

	var/area/A = get_area(holder)
	.+= "Location: [A.name]."
	if(M.stat & NOPOWER)
		.+= "<span class='average'>Insufficient power to operate.</span>"
	if(!has_fuel())
		.+= "<span class='average'>Insufficient fuel for a burn.</span>"
	if(M.stat & BROKEN)
		.+= "<span class='average'>Inoperable engine configuration.</span>"
	if(blockage)
		.+= "<span class='average'>Obstruction of airflow detected.</span>"
	return jointext(.,"<br>")

// Gets the weight in kg of mass available for specific impulse ignition.
// Do not return 0 on this proc. 0 will always result in 0 thrust.
// wet_mass + exhaust_velocity determines force applied to a ship to move forward.
/datum/extension/ship_engine/proc/get_specific_wet_mass()
	return 0.03

/datum/extension/ship_engine/proc/check_blockage()
	var/obj/machinery/M = holder
	blockage = FALSE
	var/exhaust_dir = GLOB.flip_dir[M.dir]
	var/turf/A = get_step(src, exhaust_dir)
	var/turf/B = A
	var/airblock
	while(isturf(A) && !(isspaceturf(A)))
		ATMOS_CANPASS_TURF(airblock, B, A)
		if(airblock & AIR_BLOCKED)
			blockage = TRUE
			break
		B = A
		A = get_step(A, exhaust_dir)
	return blockage

// Gets the potential exhaust velocity (ve m/s) from a specific impulse.
/datum/extension/ship_engine/proc/get_exhaust_velocity(datum/gas_mixture/propellant)
	return 0

/datum/extension/ship_engine/proc/toggle()
	var/obj/machinery/M = holder
	if(M.use_power)
		M.update_use_power(POWER_USE_OFF)
	else
		if(blockage)
			if(check_blockage())
				return
		M.update_use_power(POWER_USE_IDLE)
		if(M.stat & NOPOWER)//try again
			M.power_change()
		if(is_on())//if everything is in working order, start booting!
			next_on = world.time + boot_time

/datum/extension/ship_engine/proc/sync_to_ship()
	. = FALSE
	for(var/obj/structure/overmap/S in SSstar_system.ships)
		S.engines |= src
