/obj/effect/landmark
	name = "landmark"
	icon = 'icons/misc/landmarks.dmi'
	icon_state = "landmark"

	anchored = 1
	unacidable = 1
	simulated = 0
	invisibility = 101

	var/delete_after = FALSE

/obj/effect/landmark/New()
	..()

	tag = "landmark*[name]"
	landmarks_list += src

	return 1

/obj/effect/landmark/Initialize()
	. = ..()

	if(delete_after)
		return INITIALIZE_HINT_QDEL

/obj/effect/landmark/Destroy()
	landmarks_list -= src
	return ..()

/obj/effect/landmark/random_gen
	var/generation_width
	var/generation_height
	var/seed
	delete_after = TRUE

/obj/effect/landmark/random_gen/asteroid/Initialize()
	. = ..()

	if (!config.generate_map)
		return

	var/min_x = 1
	var/min_y = 1
	var/max_x = world.maxx
	var/max_y = world.maxy

	if (generation_width)
		min_x = max(src.x, min_x)
		max_x = min(src.x + generation_width, max_x)
	if (generation_height)
		min_y = max(src.y, min_y)
		max_y = min(src.y + generation_height, max_y)

	new /datum/random_map/automata/cave_system(seed, min_x, min_y, src.z, max_x, max_y)
	new /datum/random_map/noise/ore(seed, min_x, min_y, src.z, max_x, max_y)

	GLOB.using_map.refresh_mining_turfs(src.z)
