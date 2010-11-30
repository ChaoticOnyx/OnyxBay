// returns true if the area has power on given channel (or doesn't require power).
// defaults to equipment channel

/obj/machinery/proc/powered(var/chan = EQUIP)
	var/area/A = src.loc.loc		// make sure it's in an area
	if(!A || !isarea(A))
		return 0					// if not, then not powered

	return A.master.powered(chan)	// return power status of the area

// increment the power usage stats for an area

/obj/machinery/proc/use_power(var/amount, var/chan=EQUIP) // defaults to Equipment channel
	var/area/A = src.loc.loc		// make sure it's in an area
	if(!A || !isarea(A))
		return

	A.master.use_power(amount, chan)


/obj/machinery/proc/power_change()		// called whenever the power settings of the containing area change
										// by default, check equipment channel & set flag
										// can override if needed
	if(powered())
		stat &= ~NOPOWER
	else

		stat |= NOPOWER
	return