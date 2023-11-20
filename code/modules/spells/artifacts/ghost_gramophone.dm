GLOBAL_LIST_EMPTY(ghost_gramophones)
#define GRAMOPHONE_COOLDOWN 3.50 MINUTES
#define GRAMOPHONE_ACTIVE_TIME 30 SECONDS


/obj/item/device/ghost_gramophone
	name = "Strange gramophone"
	desc = "" //TODO think
	var/active = TRUE
	var/last_activated


/obj/item/device/ghost_gramophone/New()
	. = ..()
	GLOB.ghost_gramophones += src


/obj/item/device/ghost_gramophone/attack_hand(mob/living/user)
	if(active)
		return

	if(last_activated + GRAMOPHONE_COOLDOWN >= world.time)
		return

	active = TRUE
	last_activated = world.time
	set_next_think(world.time + GRAMOPHONE_ACTIVE_TIME)


/obj/item/device/ghost_gramophone/think()
	active = FALSE
	set_next_think(0)


/obj/item/device/ghost_gramophone/Destroy()
	GLOB.ghost_gramophones -= src
	return ..()


#undef GRAMOPHONE_COOLDOWN
#undef GRAMOPHONE_ACTIVE_TIME
