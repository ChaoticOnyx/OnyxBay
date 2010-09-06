/mob/living/silicon/robot/death(gibbed)
	src.stat = 2
	src.canmove = 0

	src.camera.status = 0.0

	if(src.blind)
		src.blind.layer = 0
	src.sight |= SEE_TURFS
	src.sight |= SEE_MOBS
	src.sight |= SEE_OBJS

	src.see_in_dark = 8
	src.see_invisible = 2
	src.updateicon()

	return ..(gibbed)