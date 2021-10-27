/obj/effect/landmark
	name = "landmark"
	icon = 'icons/misc/landmarks.dmi'
	icon_state = "landmark"

	anchored = 1
	unacidable = 1
	simulated = 0
	//invisibility = 101

	var/should_be_added = FALSE
	var/delete_after = FALSE

/obj/effect/landmark/New()
	..()

	if(should_be_added)
		if(!tag)
			tag = "landmark*[name]"
		LAZYADD(GLOB.landmarks_list, src)
		to_world("Это New() [name], лендмарк был добавлен в список.")

	 return 1

/obj/effect/landmark/Initialize()
	. = ..()
	if(delete_after)
		to_world("Это Initialize() [name], лендмарк был удален.")
		return INITIALIZE_HINT_QDEL

/obj/effect/landmark/Destroy()
	if(should_be_added)
		GLOB.landmarks_list -= src
	return ..()
