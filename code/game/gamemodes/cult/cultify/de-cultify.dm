/turf/unsimulated/wall/cult/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/nullrod))
		user.visible_message("<span class='notice'>\The [user] touches \the [src] with \the [I], and it shifts.</span>", "<span class='notice'>You touch \the [src] with \the [I], and it shifts.</span>")
		ChangeTurf(/turf/unsimulated/wall)
		return
	..()
