var/const/GHOST_IMAGE_NONE = 0
var/const/GHOST_IMAGE_DARKNESS = 1
var/const/GHOST_IMAGE_SIGHTLESS = 2
var/const/GHOST_IMAGE_ALL = ~GHOST_IMAGE_NONE

/mob/observer
	density = 0
	alpha = 127
	plane = OBSERVER_PLANE
	invisibility = INVISIBILITY_OBSERVER
	see_invisible = SEE_INVISIBLE_OBSERVER
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS|SEE_SELF
	simulated = FALSE
	stat = DEAD
	status_flags = GODMODE
	var/ghost_image_flag = GHOST_IMAGE_DARKNESS
	var/image/ghost_image = null //this mobs ghost image, for deleting and stuff

	is_poi = TRUE

/mob/observer/Initialize()
	. = ..()
	ghost_image = image(icon, src)
	ghost_image.plane = plane
	ghost_image.layer = layer
	ghost_image.appearance = src
	ghost_image.appearance_flags = DEFAULT_APPEARANCE_FLAGS | KEEP_TOGETHER | RESET_ALPHA

/mob/observer/check_airflow_movable()
	return FALSE

/mob/observer/CanPass()
	return TRUE

/mob/observer/dust()	//observers can't be vaporised.
	return

/mob/observer/gib(anim, do_gibs)		//observers can't be gibbed.
	return

/mob/observer/is_blind()	//Not blind either.
	return

/mob/observer/is_deaf() 	//Nor deaf.
	return

/mob/observer/set_stat()
	stat = DEAD // They are also always dead

/mob/observer/touch_map_edge()
	if(z in GLOB.using_map.get_levels_with_trait(ZTRAIT_SEALED))
		return

	var/new_x = x
	var/new_y = y

	if(x <= TRANSITION_EDGE)
		new_x = TRANSITION_EDGE + 1
	else if (x >= (world.maxx - TRANSITION_EDGE + 1))
		new_x = world.maxx - TRANSITION_EDGE
	else if (y <= TRANSITION_EDGE)
		new_y = TRANSITION_EDGE + 1
	else if (y >= (world.maxy - TRANSITION_EDGE + 1))
		new_y = world.maxy - TRANSITION_EDGE

	var/turf/T = locate(new_x, new_y, z)
	if(T)
		forceMove(T)
		inertia_dir = 0
		throwing = 0
		to_chat(src, "<span class='notice'>You cannot move further in this direction.</span>")
