/obj/structure/blob/core
	icon_state = "blob_core"
	density = TRUE

	max_health = BLOB_CORE_HEALTH
	damage = BLOB_CORE_DAMAGE

/obj/structure/blob/core/New(loc, ...)
	. = ..()
	
	core = src

/obj/structure/blob/core/can_expand()
	return TRUE
