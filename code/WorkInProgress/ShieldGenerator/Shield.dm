//Shield Generator - Shield Object
//The interactable shielding object

/obj/machinery/shielding/shield
	icon = 'shieldblue.dmi'
	icon_state = "15"
	var/atmosonly = 0

	density = 0
	opacity = 0
	invisibility = 101

	var/obj/machinery/shielding/emitter/emitter = null