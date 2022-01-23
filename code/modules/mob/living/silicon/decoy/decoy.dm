/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/mob/ai.dmi'//
	icon_state = "ai"
	anchored = TRUE // -- TLE
	movement_handlers = list(/datum/movement_handler/no_move)

/mob/living/silicon/decoy/New()
	src.icon = 'icons/mob/ai.dmi'
	src.icon_state = "ai"
	src.anchored = TRUE

/mob/living/silicon/decoy/Initialize()
	SHOULD_CALL_PARENT(FALSE)
	atom_flags |= ATOM_FLAG_INITIALIZED
	return INITIALIZE_HINT_NORMAL
