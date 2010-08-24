/obj/machinery/cyborgcharger
	name = "Cyborg Charging Station"
	icon = 'cyborgcharger.dmi'
	icon_state = "charge"
	density = 0



/obj/machinery/cyborgcharger/process()
	if(powered())
		for(var/mob/living/silicon/robot/R in src.loc)
			var/added
			if(R.cell)
				added = R.cell.maxcharge/100.0
				if(R.module_state_1)
					added+=5
				if(R.module_state_2)
					added+=5
				if(R.module_state_3)
					added+=5
				R.cell:give(added)
			use_power(added)
	return ..()

/obj/machinery/cyborgcharger/power_change()
	if(powered())
		stat &= ~NOPOWER
		src.icon_state = "charge"
	else
		stat |= NOPOWER
		src.icon_state = "charge0"
	return