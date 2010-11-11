//Shield Generator - Shield Object
//The interactable shielding object

/obj/machinery/shielding/shield
	name = "shield"
	desc = "An energy shield."
	icon = 'effects.dmi'
	explosionstrength = 0
	icon_state = "shieldsparkles"
	anchored = 1
	var/atmosonly = 0
	var/spawntm = 0

	density = 0
//	opacity = 0
	invisibility = 101

	var/obj/machinery/shielding/emitter/emitter = null

/obj/machinery/shielding/shield/process()
	if(!emitter)
		if(spawntm == 0)
			spawntm = 1
			spawn(rand(50,150))
				density = 0
				explosionstrength = 0
				invisibility = 101
				spawntm = 0

	if(emitter.online)
		if(spawntm == 0)
			spawntm = 1
			spawn(rand(50,150))
				density = 1
				explosionstrength = 9
				invisibility = 0
				spawntm = 0
	else
		if(spawntm == 0)
			spawntm = 1
			spawn(rand(50,150))
				density = 0
				explosionstrength = 0
				invisibility = 101
				spawntm = 0