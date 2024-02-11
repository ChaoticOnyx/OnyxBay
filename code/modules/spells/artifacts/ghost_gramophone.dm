GLOBAL_LIST_EMPTY(ghost_gramophones)
#define GRAMOPHONE_COOLDOWN 3 MINUTES
#define GRAMOPHONE_ACTIVE_TIME 40 SECONDS

/obj/item/device/ghost_gramophone
	name = "Strange gramophone"
	desc = "Artifact that allows you to temporarily hear spirits from a parallel dimension."
	var/active = FALSE
	var/last_activated = - 3 MINUTES
	icon_state = "ghostgramophone0"

/obj/item/device/ghost_gramophone/Initialize()
	. = ..()
	GLOB.ghost_gramophones += src

/obj/item/device/ghost_gramophone/AltClick(mob/living/user)
	if(active)
		to_chat(user, SPAN_NOTICE("The [src] is on and it won't be toggled off by a puny mortal."))
		return

	if(last_activated + GRAMOPHONE_COOLDOWN <= world.time)
		icon_state = "ghostgramophone1"
		active = TRUE
		last_activated = world.time
		visible_message(SPAN_NOTICE("The gramophone starts spinning its record with a squeak."))
		notify_ghosts("A ghost gramophone is channeling words said nearby it!", null, src, action = NOTIFY_JUMP, posses_mob = FALSE)
		set_next_think(world.time + GRAMOPHONE_ACTIVE_TIME)
	else
		to_chat(user, SPAN_NOTICE("You try to turn on the [src], but to no avail! Maybe you should try again later?"))

/obj/item/device/ghost_gramophone/think()
	active = FALSE
	icon_state = "ghostgramophone0"
	visible_message(SPAN_NOTICE("The [src] suddenly goes silent."))
	set_next_think(0)

/obj/item/device/ghost_gramophone/Destroy()
	GLOB.ghost_gramophones -= src
	return ..()

#undef GRAMOPHONE_COOLDOWN
#undef GRAMOPHONE_ACTIVE_TIME
