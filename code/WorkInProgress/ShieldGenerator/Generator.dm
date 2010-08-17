//Shield Generator - Energy Converter
//Converts electrical energy to shield energy

/obj/machinery/shielding/energyconverter
	name = "Energy Converter"
	desc = "An energy conversion unit for the shield generator system"
	icon = 'shieldgen.dmi'
	icon_state = "econ"
	anchored = 1
	density = 1

	var/conversionrate = 500 //Units of shield energy produced per tick
	var/setconversionrate = 500
	var/maxconversionrate = 2000
	var/lastconversionrate = 500
	var/maxautoconversionpositivedelta = 50
	var/operatingmode = 1
	//0 = Off
	//1 = On Manual
	//2 = On Auto - attempt to maintain shield charge above a specific level
	//3 = Remote Control
	var/targetlevel = 60 //% of maximum charge
	var/obj/machinery/shielding/capacitor/capacitor = null


//SETUP
	New()
		spawn(5)
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
	var/endraw =  add_lspace("[round(conversionrate ** 1.5)]", 6)

	var/dat = {"<html><head><title>Shield Energy Converter</title></head><body><div style="position: absolute; right: 5px; top: 5px; border: 2px inset"><pre>
Mode:           [modestring]&nbsp;
Generation Rate:      [genrate]%
Shield Charge:        [scharge]%
Energy Draw:       [endraw]W
</pre></div><h1>Shield Energy Conversion System</h1><pre>Operating Mode:                 <b>\[Auto\]</b> <a href="?mode=1">Manual</a> <a href="?mode=2">Remote</a>
Auto Mode Target Shield Charge: <a href="?auto=0">M</a> <a href="?auto=1">-</a> <a href="?auto=2">-</a> 100 <a href="?auto=3">+</a> <a href="?auto=4">+</a> <a href="?auto=5">M</a>
Manual Mode Generation Rate:    <a href="?man=0">M</a> <a href="?man=1">-</a> <a href="?man=2">-</a> 500 <a href="?man=3">+</a> <a href="?man=4">+</a> <a href="?man=5">M</a>
</pre></body></html>"}

	user << browse(dat, "window=shieldgen;size=500x300")
	onclose(user, "shieldgen")

	return


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

	use_power(round(conversionrate ** 1.5))
	use_power(-(produce_energy(conversionrate) ** 1.3)) //Partially return shield energy that couldn't be used
	lastconversionrate = conversionrate
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
	if (stat || !operatingmode)
		icon_state = "econ-p"
	else
		icon_state = "econ"
		addoverlay(image('shieldgen.dmi', "o[round((conversionrate * 11) / maxconversionrate)]"))