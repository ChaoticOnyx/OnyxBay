
/obj/item/computer_hardware/network_card
	name = "basic NTNet network card"
	desc = "A basic network card for usage with standard NTNet frequencies."
	power_usage = 50
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 1)
	critical = 0
	icon_state = "netcard_basic"
	hardware_size = 1
	var/identification_id = null	// Identification ID. Technically MAC address of this device. Can't be changed by user.
	var/identification_string = "" 	// Identification string, technically nickname seen in the network. Can be set by user.
	var/long_range = 0
	var/ethernet = 0 // Hard-wired, therefore always on, ignores NTNet wireless checks.
	malfunction_probability = 1

/obj/item/computer_hardware/network_card/advanced
	name = "advanced NTNet network card"
	desc = "An advanced network card for usage with standard NTNet frequencies. It's transmitter is strong enough to connect even when far away."
	long_range = 1
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 2)
	power_usage = 100 // Better range but higher power usage.
	icon_state = "netcard_advanced"
	hardware_size = 1

/obj/item/computer_hardware/network_card/wired
	name = "wired NTNet network card"
	desc = "An advanced network card for usage with standard NTNet frequencies. This one also supports wired connection."
	ethernet = 1
	origin_tech = list(TECH_DATA = 5, TECH_ENGINEERING = 3)
	power_usage = 100 // Better range but higher power usage.
	icon_state = "netcard_ethernet"
	hardware_size = 3


/obj/item/computer_hardware/network_card/Initialize()
	. = ..()
	identification_id = random_id("network_card_id", 1000, 9999)

/obj/item/computer_hardware/network_card/Destroy()
	if(holder2 && (holder2.network_card == src))
		holder2.network_card = null
	holder2 = null
	return ..()

/obj/item/computer_hardware/network_card/diagnostics(mob/user)
	..()
	to_chat(user, "NIX Unique ID: [identification_id]")
	to_chat(user, "NIX User Tag: [identification_string]")
	to_chat(user, "Supported protocols:")
	to_chat(user, "511.m SFS (Subspace) - Standard Frequency Spread")
	if(long_range)
		to_chat(user, "511.n WFS/HB (Subspace) - Wide Frequency Spread/High Bandiwdth")
	if(ethernet)
		to_chat(user, "OpenEth (Physical Connection) - Physical network connection port")

// Returns a string identifier of this network card
/obj/item/computer_hardware/network_card/proc/get_network_tag()
	return "[identification_string] (NID [identification_id])"

/obj/item/computer_hardware/network_card/proc/is_banned()
	return ntnet_global.check_banned(identification_id)

// 0 - No signal, 1 - Low signal, 2 - High signal. 3 - Wired Connection
/obj/item/computer_hardware/network_card/proc/get_signal(specific_action = 0)
	if(!holder2) // Hardware is not installed in anything. No signal. How did this even get called?
		return 0

	if(!enabled)
		return 0

	if(!check_functionality() || !ntnet_global || is_banned())
		return 0

	if(ethernet) // Computer is connected via wired connection.
		return 3

	if(!ntnet_global.check_function(specific_action)) // NTNet is down and we are not connected via wired connection. No signal.
		return 0

	if(holder2)
		var/turf/T = get_turf(holder2)
		if(!istype(T)) //no reception in nullspace
			return 0
		if(T.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))
			// Computer is on station. Low/High signal depending on what type of network card you have
			if(long_range)
				return 2
			else
				return 1
		if(T.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_CONTACT)) //not on station, but close enough for radio signal to travel
			if(long_range) // Computer is not on station, but it has upgraded network card. Low signal.
				return 1

	return 0 // Computer is not on station and does not have upgraded network card. No signal.
