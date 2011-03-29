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

	var/ConversionRate = 0 //Units of shield energy produced per tick
	var/ManualConversionRate = 60
	var/RemoteConversionRate = 60
	var/AutoTargetChargeLevel = 75 //% of maximum charge
	var/AutoMaxConversionRate = 100
	var/MaxAutoConversionRateDelta = 50

	var/HardMaximumConversionRate = 500
	var/PreviousConversionRate = 50

	var/OperatingMode = 1
	//0 = Off
	//1 = On Manual
	//2 = On Auto - attempt to maintain shield charge above a specific level
	//3 = Remote Control

	var/obj/machinery/shielding/capacitor/Capacitor = null


//SETUP
/obj/machinery/shielding/energyconverter/initialize()
	Capacitor = locate() in get_step(src, WEST)
	if(!Capacitor)
		stat |= BROKEN
		UpdateIcon()
	else
		Capacitor.generator = src
		ShieldNetwork.capacitators += 1

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

#ifdef DEBUG
/obj/machinery/shielding/energyconverter/verb/scramble()
	set src in view()
	set popup_menu = 1
	var/freq = input("frequency?")
	radio_controller.RegisterScrambler(freq)
#endif

/obj/machinery/shielding/energyconverter/proc/interact(mob/user as mob)

	var/modestring
	switch(OperatingMode)
		if(0)
			modestring = "      OFF"
		if(1)
			modestring = "   MANUAL"
		if(2)
			modestring = "AUTOMATIC"
		if(3)
			modestring = "   REMOTE"

	var/genrate = add_lspace("[round(PreviousConversionRate * 100 / HardMaximumConversionRate)]", 3)
	var/scharge = add_lspace("[round(Capacitor.charge * 100 / Capacitor.maxcharge)]", 3)
	var/endraw =  add_lspace("[round(ConversionRate ** 2.15)]", 6)

	var/modec = ""

	switch(OperatingMode)
		if(0)
			modec = {"<b>\[Off\]</b> <a href="?src=\ref[src]&set=mode&mode=1">Manual</a> <a href="?src=\ref[src]&set=mode&mode=2">Auto</a> <a href="?src=\ref[src]&set=mode&mode=3">Remote</a>"}
		if(1)
			modec = {"<a href="?src=\ref[src]&set=mode&mode=0">Off</a> <b>\[Manual\]</b> <a href="?src=\ref[src]&set=mode&mode=2">Auto</a> <a href="?src=\ref[src]&set=mode&mode=3">Remote</a>"}
		if(2)
			modec = {"<a href="?src=\ref[src]&set=mode&mode=0">Off</a> <a href="?src=\ref[src]&set=mode&mode=1">Manual</a> <b>\[Auto\]</b> <a href="?src=\ref[src]&set=mode&mode=3">Remote</a>"}
		if(3)
			modec = {"<a href="?src=\ref[src]&set=mode&mode=0">Off</a> <a href="?src=\ref[src]&set=mode&mode=1">Manual</a> <a href="?src=\ref[src]&set=mode&mode=2">Auto</a> <b>\[Remote\]</b>"}

	var/dat = {"<html><head><title>Shield Energy Converter</title></head><body><div style="position: absolute; right: 5px; top: 5px; border: 2px inset"><pre>
Mode:           [modestring]&nbsp;
Generation Rate:       [genrate]%
Shield Charge:         [scharge]%
Maximum Energy Draw: [endraw]W
</pre></div><h1>Shield Energy Conversion System</h1><pre>Operating Mode:                    [modec]
Auto Mode Target Shield Charge %: <a href="?src=\ref[src]&auto=1">M</a> <a href="?src=\ref[src]&auto=2">--</a> <a href="?src=\ref[src]&auto=3">-</a> [AutoTargetChargeLevel] <a href="?src=\ref[src]&auto=4">+</a> <a href="?src=\ref[src]&auto=5">++</a> <a href="?src=\ref[src]&auto=6">M</a>
Manual Mode Generation Rate:      <a href="?src=\ref[src]&man=1">M</a> <a href="?src=\ref[src]&man=2">--</a> <a href="?src=\ref[src]&man=3">-</a> [ManualConversionRate] <a href="?src=\ref[src]&man=4">+</a> <a href="?src=\ref[src]&man=5">++</a> <a href="?src=\ref[src]&man=6">M</a>
</pre></body></html>"}

	user << browse(dat, "window=shieldgen&size=800x200")
	onclose(user, "shieldgen")

	return
/obj/machinery/shielding/energyconverter/Topic(href, href_list)

	if (href_list["set"] == "mode")
		//Set Operating mode
		OperatingMode = text2num(href_list["mode"])
	else if (href_list["man"])
		switch(text2num(href_list["man"]))
			if(1)
				ManualConversionRate = 0
			if(2)
				ManualConversionRate -= 10
			if(3)
				ManualConversionRate -= 1
			if(4)
				ManualConversionRate += 1
			if(5)
				ManualConversionRate += 10
			if(6)
				ManualConversionRate = 500

		ManualConversionRate = max(min(ManualConversionRate, HardMaximumConversionRate), 0)

	else if (href_list["auto"])
		switch(text2num(href_list["auto"]))
			if(1)
				AutoTargetChargeLevel = 0
			if(2)
				AutoTargetChargeLevel -= 10
			if(3)
				AutoTargetChargeLevel -= 1
			if(4)
				AutoTargetChargeLevel += 1
			if(5)
				AutoTargetChargeLevel += 10
			if(6)
				AutoTargetChargeLevel = 100

		AutoTargetChargeLevel = max(min(AutoTargetChargeLevel, 100), 0)

	usr.machine = src
	src.updateDialog()

//STANDARD PROCESSING

/obj/machinery/shielding/energyconverter/process()
	if(stat & (NOPOWER|BROKEN) || !OperatingMode)
		return
	if(!Capacitor)
		stat |= BROKEN
		UpdateIcon()
		return
	if(Capacitor.maxcharge == Capacitor.charge || Capacitor.charge * 100 == AutoTargetChargeLevel && OperatingMode == 3)
		UpdateIcon()
		return
	switch(OperatingMode)
		if(1)
			//Manual Mode
			ConversionRate = ManualConversionRate
		if(2)
			//Auto Mode

			//Get current shield levels
			var/charge = Capacitor.charge / Capacitor.maxcharge

			//How much is needed?
			var/needed = max(AutoTargetChargeLevel - charge, 0) * Capacitor.maxcharge

			//what is the most we could produce this tick?
			var/AutoMaxConversionRate = PreviousConversionRate + MaxAutoConversionRateDelta

			//how much should we produce?

			ConversionRate = min(max(AutoMaxConversionRate, needed), HardMaximumConversionRate)
		if (3)
			//Remote Mode
			ConversionRate = max(min(RemoteConversionRate, HardMaximumConversionRate), 0)

	var/used_power = min(round(ConversionRate ** 2.15), 100000)
	use_power(used_power)
	if(! (stat & NOPOWER) )
		Capacitor.charge += round(ConversionRate ** 2.15)
	PreviousConversionRate = ConversionRate
	UpdateIcon()
	updateUsrDialog()

/obj/machinery/shielding/energyconverter/power_change()
	..()
	UpdateIcon()

/obj/machinery/shielding/energyconverter/proc/produce_energy(var/amount)
	//Get batteries

	//how much can we put in?
	var/maxin = min(amount, Capacitor.maxcharge - Capacitor.charge)

	//put as much of amount as possible in
	Capacitor.charge += maxin

	//and return any we couldn't add to the shield set
	return amount - maxin

/obj/machinery/shielding/energyconverter/proc/UpdateIcon()
	clearoverlays()
	if (stat)
		icon_state = "econ-p"
	else
		icon_state = "econ"
		if(OperatingMode && Capacitor && !Capacitor.stat)
			addoverlay(image('shieldgen.dmi', "o[round((ConversionRate * 11) / HardMaximumConversionRate)]"))
		else
			addoverlay(image('shieldgen.dmi', "econ-o"))