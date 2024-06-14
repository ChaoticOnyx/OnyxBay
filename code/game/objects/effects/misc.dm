//The effect when you wrap a dead body in gift wrap
/obj/effect/spresent
	name = "strange present"
	desc = "It's a ... present?"
	icon = 'icons/obj/items.dmi'
	icon_state = "strangepresent"
	density = 1
	anchored = 0

/obj/effect/stop
	var/victim = null
	icon_state = "empty"
	name = "Geas"
	desc = "You can't resist."

/obj/effect/stop/Uncrossed(atom/movable/O)
	if(victim == O)
		return 0
	return 1

/obj/effect/minefield
	name = "minefield"
	var/minerange = 9
	var/minetype = /obj/structure/landmine

/obj/effect/minefield/Initialize()
	. = ..()
	for(var/turf/simulated/floor/T in view(minerange,loc))
		if(prob(5))
			new minetype(T)
