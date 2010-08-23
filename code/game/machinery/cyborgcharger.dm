/obj/machinery/cyborgcharger
	name = "Cyborg Charging Station"
	icon = 'cyborgcharger.dmi'
	icon_state = "charge"
	density = 0



/obj/machinery/cyborgcharger/process()
	for(var/mob/living/silicon/robot/R in src.loc)
		var/added
		if(R.cell&&R.cell.charge<(R.cell.maxcharge-(R.cell.maxcharge/100)))
			added = R.cell.maxcharge/100.0
			if(R.module_state_1)
				added+=5
			if(R.module_state_2)
				added+=5
			if(R.module_state_3)
				added+=5
			R.cell.charge+=added
		else if (R.cell)
			added = R.cell.maxcharge - R.cell.charge
			R.cell.charge = R.cell.maxcharge
		use_power(added)
	return