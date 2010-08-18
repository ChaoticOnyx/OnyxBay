//Shield Generator - Emitters
//The shield emitters

/obj/machinery/shielding/emitter/emitter
	icon = 'shieldgen.dmi'

	var/list/obj/machinery/shielding/shield/shields = list( )


//TODO change this so it uses whether shield energy is available
/obj/machinery/shielding/emitter/emitter/powered(var/chan = EQUIP)
	return 1

/obj/machinery/shielding/emitter/emitter/plate
	icon_state = "plate"

