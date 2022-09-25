/obj/machinery/atmospherics/unary/vent
	plane = FLOOR_PLANE
	use_power = POWER_USE_OFF
	
	idle_power_usage = 150 WATTS //internal circuitry, friction losses and stuff
	power_rating = 7500	//7500 W ~ 10 HP
	level = 1
	var/id_tag = null
	var/frequency = 1439
	var/datum/radio_frequency/radio_connection
	var/area/initial_loc
	var/area_uid
	var/radio_filter_out
	var/radio_filter_in
	var/hibernate = 0 //Do we even process?
	var/error_msg
	
	// Added for aliens
	var/welded = FALSE
	