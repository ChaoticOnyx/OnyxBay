/turf/unsimulated/wall/cult/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/nullrod))
		user.visible_message(SPAN("notice", "\The [user] touches \the [src] with \the [I], and it shifts."), SPAN("notice", "You touch \the [src] with \the [I], and it shifts."))
		ChangeTurf(/turf/unsimulated/wall)
		return
	..()
