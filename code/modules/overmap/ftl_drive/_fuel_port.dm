/obj/machinery/atmospherics/unary/ftl_fuel_port
	name = "fuel port"
	desc = "FTL drive fuel port"
	icon = 'icons/obj/artillery.dmi'
	icon_state = "14"
	var/volume_rate = 50

/obj/machinery/atmospherics/unary/ftl_fuel_port/proc/draw_gas()
	var/power_draw = -1
	var/transfer_moles = (volume_rate / air_contents.volume) * air_contents.total_moles
	if(air_contents.total_moles < MINIMUM_MOLES_TO_PUMP) //if we cant transfer enough gas just stop to avoid further processing
		return -1

	if(isnull(transfer_moles))
		transfer_moles = air_contents.total_moles
	else
		transfer_moles = min(air_contents.total_moles, transfer_moles)

	var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

	if(network)
		network.update = 1
