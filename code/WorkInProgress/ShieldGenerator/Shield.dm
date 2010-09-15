//Shield Generator - Shield Object
//The interactable shielding object

/obj/machinery/shielding/shield
	name = "shield"
	desc = "An energy shield."
	icon = 'effects.dmi'
	explosionstrength = 9
	icon_state = "shieldsparkles"
	icon_state = "15"
	var/atmosonly = 0

	density = 1
//	opacity = 0
//	invisibility = 0

	var/obj/machinery/shielding/emitter/emitter = null

