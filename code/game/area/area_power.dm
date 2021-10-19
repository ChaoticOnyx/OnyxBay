/area/proc/powered(chan)		// return true if the area has power to given channel
	if(!requires_power)
		return 1
	if(always_unpowered)
		return 0
	switch(chan)
		if(STATIC_EQUIP)
			return power_equip
		if(STATIC_LIGHT)
			return power_light
		if(STATIC_ENVIRON)
			return power_environ

	return 0

// called when power status changes
/area/proc/power_change()
	for(var/obj/machinery/M in src) // for each machine in the area
		M.power_change()            // reverify power status (to update icons etc.)
	for(var/obj/item/device/radio/intercom/I in src) // better than processing hundreds of those each tick
		I.power_change()
	if(fire || eject || party)
		update_icon()

/area/proc/usage(chan)
	var/used = 0
	switch(chan)
		if(TOTAL)
			used += static_light + static_equip + static_environ + used_equip + used_light + used_environ
		if(STATIC_EQUIP)
			used += static_equip + used_equip
		if(STATIC_LIGHT)
			used += static_light + used_light
		if(STATIC_ENVIRON)
			used += static_environ + used_environ
	return used

/area/proc/addStaticPower(value, powerchannel)
	switch(powerchannel)
		if(STATIC_EQUIP)
			static_equip += value
		if(STATIC_LIGHT)
			static_light += value
		if(STATIC_ENVIRON)
			static_environ += value

/area/proc/removeStaticPower(value, powerchannel)
	addStaticPower(-value, powerchannel)

// Helper for APCs; will generally be called every tick.
/area/proc/clear_usage()
	oneoff_equip = 0
	oneoff_light = 0
	oneoff_environ = 0

// Not a proc you want to use directly unless you know what you are doing; see use_power_oneoff below instead.
/area/proc/use_power(amount, chan)
	switch(chan)
		if(STATIC_EQUIP)
			used_equip += amount
		if(STATIC_LIGHT)
			used_light += amount
		if(STATIC_ENVIRON)
			used_environ += amount

// This is used by machines to properly update the area of power changes.
/area/proc/power_use_change(old_amount, new_amount, chan)
	use_power(new_amount - old_amount, chan)

// Use this for a one-time power draw from the area, typically for non-machines.
/area/proc/use_power_oneoff(amount, chan)
	switch(chan)
		if(STATIC_EQUIP)
			oneoff_equip += amount
		if(STATIC_LIGHT)
			oneoff_light += amount
		if(STATIC_ENVIRON)
			oneoff_environ += amount

// This recomputes the continued power usage; can be used for testing or error recovery, but is not called every tick.
/area/proc/retally_power()
	used_equip = 0
	used_light = 0
	used_environ = 0
	for(var/obj/machinery/M in src)
		switch(M.power_channel)
			if(STATIC_EQUIP)
				used_equip += M.get_power_usage()
			if(STATIC_LIGHT)
				used_light += M.get_power_usage()
			if(STATIC_ENVIRON)
				used_environ += M.get_power_usage()
