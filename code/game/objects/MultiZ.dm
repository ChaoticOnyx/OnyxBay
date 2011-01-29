/obj/multiz
	icon = 'multiz.dmi'
	density = 0
	opacity = 0
	anchored = 1
	var/istop = 1

	CanPass(obj/mover, turf/source, height, airflow)
		return airflow || !density

/obj/multiz/proc/targetZ()
	return src.z + (istop ? 1 : -1)

/obj/multiz/ladder
	icon_state = "ladderdown"
	name = "ladder"
	desc = "A Ladder.  You climb up and down it."

/obj/multiz/ladder/New()
	..()
	if (!istop)
		icon_state = "ladderup"
	else
		icon_state = "ladderdown"

/obj/multiz/ladder/attack_paw(var/mob/M)
	return attack_hand(M)

/obj/multiz/ladder/attackby(var/W, var/mob/M)
	return attack_hand(M)

/obj/multiz/ladder/attack_hand(var/mob/M)
	M.Move(locate(src.x, src.y, targetZ()))

/obj/multiz/ladder/blob_act()
	var/newblob = 1
	for(var/obj/blob in locate(src.x, src.y, targetZ()))
		newblob = 0
	if(newblob)
		new /obj/blob(locate(src.x, src.y, targetZ()))

//Stairs.  var/dir on all four component objects should be the dir you'd walk from top to bottom
/obj/multiz/stairs
	name = "Stairs"
	desc = "Stairs.  You walk up and down them."
	icon_state = "ramptop"

/obj/multiz/stairs/New()
	icon_state = istop ^ istype(src, /obj/multiz/stairs/active) ? "ramptop" : "rampbottom"

/obj/multiz/stairs/enter/bottom
	istop = 0

/obj/multiz/stairs/active
	density = 1

/obj/multiz/stairs/active/Bumped(var/atom/movable/M)
	if(istype(src, /obj/multiz/stairs/active/bottom) && !locate(/obj/multiz/stairs/enter) in M.loc)
		return //If on bottom, only let them go up stairs if they've moved to the entry tile first.
	//If it's the top, they can fall down just fine.
	if(ismob(M) && M:client)
		M:client.moving = 1
	M.Move(locate(src.x, src.y, targetZ()))
	if (ismob(M) && M:client)
		M:client.moving = 0

/obj/multiz/stairs/active/Click()
	if(!istype(usr,/mob/dead/observer))
		return ..()
	usr.client.moving = 1
	usr.Move(locate(src.x, src.y, targetZ()))
	usr.client.moving = 0
/obj/multiz/stairs/active/bottom
	istop = 0
	opacity = 1
