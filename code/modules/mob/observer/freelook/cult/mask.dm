/mob/observer/eye/cult
	name = "Mask of God"
	desc = "A terrible fracture of reality coinciding into a mirror to another world."

/mob/observer/eye/cult/Initialize()
	. = ..()
	visualnet = new /datum/visualnet/cultnet()

/mob/observer/eye/cult/Destroy()
	QDEL_NULL(visualnet)
	return ..()

/mob/observer/eye/cult/MouseDrop_T(atom/movable/target, mob/user)
	. = ..()
	if(istype(owner, /mob/living/deity) && user.client.holder)
		user.client.holder.cmd_ghost_drag(target, owner)
