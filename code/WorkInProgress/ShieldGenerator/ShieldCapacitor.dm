//Shield Generator - Shielding Capacitor
//Stores shield energy for consumption by the shielding systems

/obj/machinery/shielding/capacitor
	name = "Shielding Capacitor"
	desc = "A storage device for shield energy"
	icon = 'shieldgen.dmi'
	icon_state = "cap"
	anchored = 1
	density = 1

	var/maxcharge = 5000
	var/charge = 1000
	var/obj/machinery/shielding/energyconverter/generator = null

/obj/machinery/shielding/capacitor/process()
	if(stat & BROKEN)
		charge = 0
		updateicon()
		return
	if(stat & NOPOWER)
		if(charge)
			charge -= 400
			charge = max(charge, 0)
	else
		use_power(round(charge ** 1.1))
	updateicon()
	return

/obj/machinery/shielding/capacitor/proc/updateicon()
	clearoverlays()
	icon_state = "cap[stat & (NOPOWER|BROKEN) ? "-p" : ""]"
	addoverlay(image('shieldgen.dmi', "c[round(charge * 5 / maxcharge)]"))
	if(!generator.operatingmode || generator.stat)
		addoverlay(image('shieldgen.dmi', "cap-o"))
	return