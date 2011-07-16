/obj/item/weapon/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'structures.dmi'
	icon_state = "window"

/obj/item/weapon/evidencebag/attackby(obj/item/weapon/O, mob/user as mob)
	return src.afterattack(O, user)

/obj/item/weapon/evidencebag/afterattack(obj/item/O, mob/user as mob)
	if(!(O && istype(O)))
		user << "You can't put that inside the [src]!"
		return
	if(src.contents.len > 0)
		user << "The [src] already has something inside it."
		return
	user << "You put the [O] inside the [src]."
	O.loc = src
	src.underlays += O
	desc = "An evidence bag containing \a [O]. [O.desc]"

/obj/item/weapon/evidencebag/attack_self(mob/user as mob)
	var/obj/item/I = src.contents[1]
	user << "You take the [I] out of the [src]."
	I.loc = user.loc
	src.underlays -= I