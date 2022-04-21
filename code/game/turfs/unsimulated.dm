GLOBAL_LIST_EMPTY(self_cleaning_list)
/turf/unsimulated
	simulated = 0
	name = "command"
	initial_gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)

/turf/unsimulated/floor/self_cleaning
	var/list/uncleanable_items = list(/mob/living, /obj/item/VR_reward, /mob/observer/ghost, /obj/effect/landmark, /obj/item, /obj/structure) //We dont want this items to be deleted

var/global/list/self_cleaning_list = list()

/turf/unsimulated/floor/self_cleaning/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/unsimulated/floor/self_cleaning/LateInitialize()
	. = ..()

	GLOB.self_cleaning_list += src

/turf/unsimulated/floor/self_cleaning/proc/cleaner() //Not sure if this is the correct way to do that
	for(var/atom/A in contents)
		if(!is_type_in_list(A, uncleanable_items))
			qdel(A)

/turf/unsimulated/floor/self_cleaning/Destroy()
	GLOB.self_cleaning_list -= src
	. = ..()
