/obj/proc/analyze_gases(obj/A, mob/user, advanced)
	playsound(src.loc, 'sound/signals/processing21.ogg', 50)
	user.visible_message("<span class='notice'>\The [user] has used \an [src] on \the [A].</span>")
	A.add_fingerprint(user)

	var/air_contents = A.return_air()
	if(!air_contents)
		to_chat(user, "<span class='warning'>Your [src] flashes a red light as it fails to analyze \the [A].</span>")
		return 0

	var/list/result = atmosanalyzer_scan(A, air_contents, advanced)
	print_atmos_analysis(user, result)
	return 1

/proc/print_atmos_analysis(user, list/result)
	if(!length(result))
		return

	to_chat(user, EXAMINE_BLOCK(jointext(result, "\n")))

/proc/atmosanalyzer_scan(atom/target, datum/gas_mixture/mixture, advanced)
	. = list()
	. += SPAN_NOTICE("Results of the analysis of \the [target]:")

	if(!mixture)
		mixture = target.return_air()

	if(mixture)
		var/pressure = mixture.return_pressure()
		var/total_moles = mixture.total_moles

		if(total_moles>0)
			if(abs(pressure - ONE_ATMOSPHERE) < 10)
				. += SPAN_NOTICE("Pressure: [round(pressure, 0.1)] kPa")
			else
				. += SPAN_WARNING("Pressure: [round(pressure, 0.1)] kPa")
			for(var/mix in mixture.gas)
				var/percentage = round(mixture.gas[mix]/total_moles * 100, advanced ? 0.01 : 1)
				if(!percentage)
					continue
				. += SPAN_NOTICE("[gas_data.name[mix]]: [percentage]%")
				if(advanced)
					var/list/traits = list()
					if(gas_data.flags[mix] & XGM_GAS_FUEL)
						traits += "can be used as combustion fuel"
					if(gas_data.flags[mix] & XGM_GAS_OXIDIZER)
						traits += "can be used as oxidizer"
					if(gas_data.flags[mix] & XGM_GAS_CONTAMINANT)
						traits += "contaminates clothing with toxic residue"
					if(gas_data.flags[mix] & XGM_GAS_FUSION_FUEL)
						traits += "can be used to fuel fusion reaction"
					. += "\t" + SPAN_NOTICE("Specific heat: [gas_data.specific_heat[mix]] J/(mol*K), Molar mass: [gas_data.molar_mass[mix]] kg/mol.[traits.len ? "\n\tThis gas [english_list(traits)]" : ""]")
			. += SPAN_NOTICE("Temperature: [round(CONV_KELVIN_CELSIUS(mixture.temperature))]&deg;C / [round(mixture.temperature)]K")
			return

	. += SPAN_WARNING("\The [target] has no gases!")

/turf/proc/get_atmos_adjacent_turfs()
	var/list/atmos_adjacent_turfs = list()
	var/canpass = CanZASPass(src)
	for(var/direction in GLOB.cardinalz)
		var/turf/current_turf
		if(direction != UP && direction != DOWN)
			current_turf = get_step(src, direction)
		if(direction == UP)
			current_turf = GetAbove(src)
			current_turf = istype(current_turf, /turf/simulated/open) ? current_turf : null

		if(direction == DOWN)
			current_turf = istype(src, /turf/simulated/open) ? GetBelow(src) : null

		if(!istype(current_turf, /turf/simulated)) // not interested in you brother
			continue

		if(canpass && CanZASPass(current_turf) && !(blocks_air || current_turf.blocks_air))
			LAZYINITLIST(current_turf.atmos_adjacent_turfs)
			LAZYINITLIST(atmos_adjacent_turfs)
			atmos_adjacent_turfs[current_turf] = TRUE
			current_turf.atmos_adjacent_turfs[src] = TRUE
		else
			LAZYREMOVE(atmos_adjacent_turfs, current_turf)
			if (current_turf.atmos_adjacent_turfs)
				LAZYREMOVE(current_turf.atmos_adjacent_turfs, src)
			UNSETEMPTY(current_turf.atmos_adjacent_turfs)

	UNSETEMPTY(atmos_adjacent_turfs)
	src.atmos_adjacent_turfs = atmos_adjacent_turfs
	return atmos_adjacent_turfs
