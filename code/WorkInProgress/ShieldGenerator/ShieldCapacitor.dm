//Shield Generator - Shielding Capacitor
//Stores shield energy for consumption by the shielding systems

/obj/machinery/shielding/capacitor
	name = "Shielding Capacitor"
	desc = "A storage device for shield energy"
	icon = 'shieldgen.dmi'
	icon_state = "cap"
	anchored = 1
	density = 1
	var/list/emit = list()
	var/maxcharge = 10000000
	var/charge = 1000000
	var/obj/machinery/shielding/energyconverter/generator = null
	var/shields_enabled = 0

	var/on = 1


//Process Loop
/obj/machinery/shielding/capacitor/process()

	if(stat & BROKEN)
		charge = 0
		updateicon()
		return

	if(shields_enabled)
		if(charge)
			charge -= 100000
			charge = max(charge, 0)
		if(charge == 0 && on)
			on = 0
			ShieldNetwork.capacitators -= 1
		else if(charge == 1 && !on)
			on = 1
			ShieldNetwork.capacitators += 1
	updateicon()
	return


///Update the icon
/obj/machinery/shielding/capacitor/proc/updateicon()
	clearoverlays()
	icon_state = "cap[stat & (NOPOWER|BROKEN) ? "-p" : ""]"
	addoverlay(image('shieldgen.dmi', "c[round(charge * 5 / maxcharge)]"))
	if(generator && (!generator.OperatingMode || generator.stat))
		addoverlay(image('shieldgen.dmi', "cap-o"))
	return