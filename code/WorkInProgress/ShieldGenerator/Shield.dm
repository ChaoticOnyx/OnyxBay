//Shield Generator - Shield Object
//The interactable shielding object

/obj/shielding/shield
	name = "shield"
	desc = "An energy shield."
	icon = 'effects.dmi'
	icon_state = "shieldsparkles"
	anchored = 1
	invisibility = 101
	density = 0
	opacity = 0
	var/disabled = 0


	var/blockatmosonly = 0
	var/obj/machinery/shielding/emitter/emitter = null
	var/emitterdist = 0

//Shield Density controller
/obj/shielding/shield/CanPass(atom/movable/mover, turf/source, height=1.5, air_group = 0)
	if (density)
		//Block all atmos flow & explosions, but optionally allow movement through
		return !air_group && blockatmosonly
	else
		return 1 //Shield is off; do nothing

//Explosion Handling - Includes support for preblast handling
/obj/shielding/shield/ex_act(strength)
	if (strength <= 0)
		strength = -strength
		if (emitter && emitter.online)
			emitter.Draw(strength * 200)
		#ifdef DEBUG
	//	world << "Shield Handled blast wave"
		#endif
	else if (density)
		world << "Active shield ex_act called with positive value?  What?  This makes no sense and should not have happened.  Tell a dev."