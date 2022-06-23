/obj/item/integrated_circuit/engineer
	category_text = "Engineering"

/obj/item/integrated_circuit/engineer/supermatter_scan
	name = "Supermatter Crystal Scanner"
	desc = "A miniaturized version of the supermatter crystal analyzer. This allows the machine to know the status of a supermatter crystal."
	icon_state = "medscan_adv"
	complexity = 12
	inputs = list("supermatter crystal" = IC_PINTYPE_REF)
	outputs = list(
		"integrity" = IC_PINTYPE_NUMBER,
		"power" = IC_PINTYPE_NUMBER,
		"air temperature" = IC_PINTYPE_NUMBER,
		"air pressure" = IC_PINTYPE_NUMBER,
		"EPR" = IC_PINTYPE_NUMBER,
		"O2 percent"  = IC_PINTYPE_NUMBER,
		"CO2 percent" = IC_PINTYPE_NUMBER,
		"N2 percent" = IC_PINTYPE_NUMBER,
		"Plasma percent" = IC_PINTYPE_NUMBER,
		"N2O percent" = IC_PINTYPE_NUMBER,
		"H2 percent" = IC_PINTYPE_NUMBER,
	)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 80

/obj/item/integrated_circuit/engineer/supermatter_scan/do_work(ord)
	var/turf/T = get_turf(get_object())
	if(!T)
		return
	var/valid_z_levels = (GetConnectedZlevels(T.z) & GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))
	var/obj/machinery/power/supermatter/S = get_pin_data_as_type(IC_INPUT, 1, /obj/machinery/power/supermatter)
	if(!istype(S) || S.grav_pulling || S.exploded || !(S.z in valid_z_levels) || !istype(S.loc, /turf/))
		return

	T = get_turf(S)
	if(!istype(T))
		return

	var/O2 = 0
	var/CO2 = 0
	var/N2 = 0
	var/PL = 0
	var/N2O = 0
	var/H2 = 0

	var/datum/gas_mixture/air = T.return_air()
	set_pin_data(IC_OUTPUT, 1, S.get_integrity())
	set_pin_data(IC_OUTPUT, 2, S.power)
	set_pin_data(IC_OUTPUT, 3, air.temperature)
	set_pin_data(IC_OUTPUT, 4, air.return_pressure())
	set_pin_data(IC_OUTPUT, 5, S.get_epr())
	if(air.total_moles)
		O2 = round(100*air.gas["oxygen"]/air.total_moles,0.01)
		CO2 = round(100*air.gas["carbon_dioxide"]/air.total_moles,0.01)
		N2 = round(100*air.gas["nitrogen"]/air.total_moles,0.01)
		PL = round(100*air.gas["plasma"]/air.total_moles,0.01)
		N2O = round(100*air.gas["sleeping_agent"]/air.total_moles,0.01)
		H2 = round(100*air.gas["hydrogen"]/air.total_moles,0.01)

	set_pin_data(IC_OUTPUT, 6, O2)
	set_pin_data(IC_OUTPUT, 7, CO2)
	set_pin_data(IC_OUTPUT, 8, N2)
	set_pin_data(IC_OUTPUT, 9, PL)
	set_pin_data(IC_OUTPUT, 10, N2O)
	set_pin_data(IC_OUTPUT, 11, H2)

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/engineer/atmospheric_analyzer
	name = "atmospheric analyzer"
	desc = "A miniaturized analyzer which can scan anything that contains gases. Leave target as NULL to scan the air around the assembly."
	extended_desc = "The nth element of gas amounts is the number of moles of the \
					nth gas in gas list. \
					Pressure is in kPa, temperature is in Kelvin. \
					Due to programming limitations, scanning an object that does \
					not contain a gas will return the air around it instead."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
			"target" = IC_PINTYPE_REF
			)
	outputs = list(
			"gas list" = IC_PINTYPE_LIST,
			"gas amounts" = IC_PINTYPE_LIST,
			"total moles" = IC_PINTYPE_NUMBER,
			"pressure" = IC_PINTYPE_NUMBER,
			"temperature" = IC_PINTYPE_NUMBER,
			"volume" = IC_PINTYPE_NUMBER
			)
	activators = list(
			"scan" = IC_PINTYPE_PULSE_IN,
			"on success" = IC_PINTYPE_PULSE_OUT,
			"on failure" = IC_PINTYPE_PULSE_OUT
			)
	power_draw_per_use = 5

/obj/item/integrated_circuit/engineer/atmospheric_analyzer/do_work()
	for(var/i=1 to 6)
		set_pin_data(IC_OUTPUT, i, null)
	var/atom/target = get_pin_data_as_type(IC_INPUT, 1, /atom)
	if(!target)
		target = get_turf(src)
	if( get_dist(get_turf(target),get_turf(src)) > 1 )
		activate_pin(3)
		return

	var/datum/gas_mixture/air_contents = target.return_air()
	if(!air_contents)
		activate_pin(3)
		return

	var/list/gases = air_contents.gas
	var/list/gas_names = list()
	var/list/gas_amounts = list()
	for(var/id in gases)
		var/name = gas_data.name[id]
		var/amt = round(gases[id], 0.001)
		gas_names.Add(name)
		gas_amounts.Add(amt)

	set_pin_data(IC_OUTPUT, 1, gas_names)
	set_pin_data(IC_OUTPUT, 2, gas_amounts)
	set_pin_data(IC_OUTPUT, 3, round(air_contents.get_total_moles(), 0.001))
	set_pin_data(IC_OUTPUT, 4, round(air_contents.return_pressure(), 0.001))
	set_pin_data(IC_OUTPUT, 5, round(air_contents.temperature, 0.001))
	set_pin_data(IC_OUTPUT, 6, round(air_contents.volume, 0.001))
	push_data()
	activate_pin(2)
