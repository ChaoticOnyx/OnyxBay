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
	var/operatingmode = 2
	//0 = Off
	//1 = On Manual
	//2 = On Auto - attempt to maintain shield charge above a specific level
	var/targetlevel = 60 //% of maximum charge


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



	return


//STANDARD PROCESSING

/obj/machinery/shielding/energyconverter/process()
	if(stat & (NOPOWER|BROKEN) || !operatingmode)
		return

	switch(operatingmode)
		if(1)
			//Manual Mode
			conversionrate = setconversionrate
		if(2)
			//Auto Mode

			//Get current shield levels

			//How much is needed?

			//what is the most we could produce this tick?
			var/automax = lastconversionrate + maxautoconversionpositivedelta

			//how much should we produce?

			conversionrate = min(automax, 0)

	use_power(round(conversionrate ** 1.5))
	use_power(-(produce_energy(conversionrate) ** 1.3)) //Partially return shield energy that couldn't be used
	lastconversionrate = conversionrate
	updateicon()
	updateUsrDialog()

/obj/machinery/shielding/energyconverter/proc/produce_energy(var/amount)
	//Get batteries

	//how much can we put in?

	//put as much of amount as possible in

	//and return any we couldn't add to the shield set
	return 0

/obj/machinery/shielding/energyconverter/proc/updateicon()
	if (stat || !operatingmode)
		icon_state = "econ-p"
		clearoverlays()
	else
		icon_state = "econ"
		addoverlay(image('shieldgen.dmi', "o[round((conversionrate * 11) / maxconversionrate)]"))