GLOBAL_LIST_EMPTY(thunderfield_spawns_list)

/obj/effect/landmark/thunderfield_spawn/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/thunderfield_spawn/LateInitialize()
	. = ..()
	GLOB.thunderfield_spawns_list += src

/obj/effect/landmark/thunderfield_spawn/Destroy()
	GLOB.thunderfield_spawns_list -= src
	. = ..()

/obj/item/VR_reward/coin
	name = "Coin"
	desc = "Collect it to get points"
	icon_state = "coin"
	layer = FLY_LAYER
	var/points = 1


/obj/item/VR_reward/coin/equipped(mob/user)
	..()
	if(!isvrhuman(user))
		return
	user.mind.thunder_points += points
	to_chat(user, SPAN_WARNING("You get [points] points! Your total points are: [user.mind.thunder_points]"))
	qdel(src)
