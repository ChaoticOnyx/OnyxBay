//Shield Generator - Energy Converter
//Converts electrical energy to shield energy

//Not done, not commented.

/obj/machinery/shielding/energyconverter
	name = "Energy Converter"
	desc = "An energy conversion unit for the shield generator system"
	icon = 'shieldgen.dmi'
	icon_state = "econ"
	anchored = 1
	density = 1

	var/conversionrate = 0 //Units of shield energy produced per tick
	var/setconversionrate = 60
	var/maxconversionrate = 100
	var/lastconversionrate = 50
	var/maxautoconversionpositivedelta = 50
	var/chargeing
	var/operatingmode = 1
	//0 = Off
	//1 = On Manual
	//2 = On Auto - attempt to maintain shield charge above a specific level
	//3 = Remote Control
	var/targetlevel = 75 //% of maximum charge
	var/obj/machinery/shielding/capacitor/capacitor = null


//SETUP
/obj/machinery/shielding/energyconverter/initialize()
	capacitor = locate() in get_step(src, WEST)
	if(!capacitor)
		stat |= BROKEN
		updateicon()
	else
		capacitor.generator = src

//PLAYER INTERACTION


/obj/machinery/shielding/energyconverter/attack_hand(mob/user as mob)
	return interact(user)

/obj/machinery/shielding/energyconverter/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return attack_hand(user)

/obj/machinery/shielding/energyconverter/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/shielding/energyconverter/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/shielding/energyconverter/attack_alien(mob/user as mob)
	return attack_hand(user)

/obj/machinery/shielding/energyconverter/proc/interact(mob/user as mob)

	var/modestring
	switch(operatingmode)
		if(0)
			modestring = "      OFF"
		if(1)
			modestring = "   MANUAL"
		if(2)
			modestring = "AUTOMATIC"
		if(3)
			modestring = "   REMOTE"

	var/genrate = add_lspace("[round(lastconversionrate * 100 / maxconversionrate)]", 3)
	var/scharge = add_lspace("[round(capacitor.charge * 100 / capacitor.maxcharge)]", 3)
	var/endraw =  add_lspace("[round(conversionrate ** 2.15)]", 6)

	var/modec = ""

	switch(operatingmode)
		if(0)
			modec = {"<b>\[Off\]</b> <a href="?mode=1">Manual</a> <a href="?mode=2">Auto</a> <a href="?mode=3">Remote</a>"}
		if(1)
			modec = {"<a href="?mode=0">Off</a> <b>\[Manual\]</b> <a href="?mode=2">Auto</a> <a href="?mode=3">Remote</a>"}
		if(2)
			modec = {"<a href="?mode=0">Off</a> <a href="?mode=1">Manual</a> b>\[Auto\]</b> <a href="?mode=3">Remote</a>"}
		if(3)
			modec = {"<a href="?mode=0">Off</a> <a href="?mode=1">Manual</a> <a href="?mode=2">Auto</a> b>\[Remote\]</b>"}

	var/dat = {"<html><head><title>Shield Energy Converter</title></head><body><div style="position: absolute; right: 5px; top: 5px; border: 2px inset"><pre>
Mode:           [modestring]&nbsp;
Generation Rate:      [genrate]%
Shield Charge:        [scharge]%
Energy Draw:       [endraw]W
</pre></div><h1>Shield Energy Conversion System</h1><pre>Operating Mode:                    [modec]
Auto Mode Target Shield Charge %: <a href="?src=\ref[src];auto=1">M</a> <a href="?src=\ref[src];auto=2">-</a> <a href="?src=\ref[src];auto=3">-</a> 100 <a href="?src=\ref[src];auto=4">+</a> <a href="?src=\ref[src];auto=5">+</a> <a href="?src=\ref[src];auto=6">M</a>
Manual Mode Generation Rate:      <a href="?src=\ref[src];man=1">M</a> <a href="?src=\ref[src];man=2">-</a> <a href="?src=\ref[src];man=3">-</a> 500 <a href="?src=\ref[src];man=4">+</a> <a href="?src=\ref[src];man=5">+</a> <a href="?src=\ref[src];man=6">M</a>
</pre></body></html>"}

	user << browse(dat, "window=shieldgen;size=800x200")
	onclose(user, "shieldgen")

	return
/obj/machinery/shielding/energyconverter/Topic(href, href_list)
	if(..())
		return


	usr.machine = src







//STANDARD PROCESSING

/obj/machinery/shielding/energyconverter/process()
	if(stat & (NOPOWER|BROKEN) || !operatingmode)
		return

	if(!capacitor)
		stat |= BROKEN
		updateicon()
		return

	switch(operatingmode)
		if(1)
			//Manual Mode
			conversionrate = setconversionrate
		if(2)
			//Auto Mode

			//Get current shield levels
			var/charge = capacitor.charge / capacitor.maxcharge

			//How much is needed?
			var/needed = max(targetlevel - charge, 0) * capacitor.maxcharge

			//what is the most we could produce this tick?
			var/automax = lastconversionrate + maxautoconversionpositivedelta

			//how much should we produce?

			conversionrate = min(max(automax, needed), maxconversionrate)

	use_power(round(conversionrate ** 2.05))
	use_power(-round(produce_energy(conversionrate) ** 1.25)) //Partially return shield energy that couldn't be used
	lastconversionrate = conversionrate
	ShieldNetwork.Balance() //TODO move this so it's not called unncessarily
	updateicon()
	updateUsrDialog()

/obj/machinery/shielding/energyconverter/power_change()
	..()
	updateicon()

/obj/machinery/shielding/energyconverter/proc/produce_energy(var/amount)
	//Get batteries

	//how much can we put in?
	var/maxin = min(amount, capacitor.maxcharge - capacitor.charge)

	//put as much of amount as possible in
	capacitor.charge += maxin

	//and return any we couldn't add to the shield set
	return amount - maxin

/obj/machinery/shielding/energyconverter/proc/updateicon()
	clearoverlays()
	if (stat)
		icon_state = "econ-p"
	else
		icon_state = "econ"
		if(operatingmode && capacitor && !capacitor.stat)
			addoverlay(image('shieldgen.dmi', "o[round((conversionrate * 11) / maxconversionrate)]"))
		else
			addoverlay(image('shieldgen.dmi', "econ-o"))