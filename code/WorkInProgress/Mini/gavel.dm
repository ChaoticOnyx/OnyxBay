/obj/item/weapon/gavel
	icon = 'items.dmi'
	icon_state = "gavel"
	name = "gavel"
	force = 8.0
	desc = "This is a judge's mallet."

/obj/item/weapon/platform
	icon = 'items.dmi'
	icon_state = "platform"
	name = "platform"

/obj/item/weapon/platform/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/gavel))
		for(var/mob/V in viewers(src, null))
			V.show_message(text("\red [user] whacks the [name] with the [O.name]!"))
	else
		..()