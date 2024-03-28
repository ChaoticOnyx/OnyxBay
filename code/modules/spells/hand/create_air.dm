/datum/spell/hand/create_air
	name = "Create Air"
	desc = "A much used spell used in the vasteness of space to make it less deadly."

	charge_max = 200
	spell_flags = Z2NOCAST
	invocation_type = SPI_NONE
	icon_state = "wiz_air"
	var/list/air_change = list("oxygen" = ONE_ATMOSPHERE)
	compatible_targets = list(/atom)

/datum/spell/hand/create_air/cast_hand(atom/target, mob/user)
	var/turf/t = get_turf(target)
	if(!istype(t))
		return

	var/datum/gas_mixture/environment = t.return_air()
	if(!istype(environment))
		return

	for(var/gas in air_change)
		environment.adjust_gas(gas, air_change[gas])
