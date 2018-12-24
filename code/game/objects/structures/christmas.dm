/obj/structure/christmas/snowman
	name = "snowman"
	desc = "A cute snowman. How are he don`t smelting?.."
	icon = 'icons/obj/christmas.dmi'
	icon_state = "snowman"
	var/obj/item/clothing/head/my_hat
	var/list/allowed = list(/obj/item/clothing/head)


/obj/structure/christmas/snowman/attack_hand(mob/user as mob)
	user.visible_message("[user] puts [my_hat] off \the [src].", "You put [my_hat] off the \the [src]")
	if(!user.put_in_active_hand(my_hat))
		my_hat.loc = get_turf(user)
	my_hat = null
	update_icon()

/obj/structure/christmas/snowman/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/can_hang = 0
	for (var/T in allowed)
		if(istype(W,T))
			can_hang = 1
	if (can_hang && !my_hat)
		user.visible_message("[user] hangs [W] on \the [src].", "You put [W] on the \the [src]")
		my_hat = W
		user.drop_from_inventory(my_hat, src)
		update_icon()
	else
		to_chat(user, "<span class='notice'>You cannot put [W] on [src]</span>")
		return ..()

/obj/structure/christmas/snowman/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	var/can_hang = 0
	for (var/T in allowed)
		if(istype(mover,T))
			can_hang = 1

	if (can_hang && !my_hat)
		src.visible_message("[mover] lands on \the [src].")
		my_hat = mover
		my_hat.loc = src
		update_icon()
		return 0
	else
		return 1

/obj/structure/christmas/snowman/update_icon()
	overlays.Cut()
	if (istype(my_hat, /obj/item/clothing/head))
		overlays += image('icons/mob/onmob/head.dmi',"[my_hat.icon_state]")

/obj/structure/sign/christmas
	name = "CHRISTMAS"
	desc = "HOU-HOU-HOU"
	icon = 'icons/obj/christmas.dmi'

/obj/structure/sign/christmas/garland
	name = "garland"
	desc = "Multi-colored rope with different iridescent bulbs"
	icon_state = "garland"

/obj/structure/sign/christmas/garlandleft
	name = "garland"
	desc = "Multi-colored rope with different iridescent bulbs"
	icon_state = "garland_left"

/obj/structure/sign/christmas/garlandright
	name = "garland"
	desc = "Multi-colored rope with different iridescent bulbs"
	icon_state = "garland_right"

/obj/structure/sign/christmas/garlandcornerleft
	name = "garland"
	desc = "Multi-colored rope with different iridescent bulbs"
	icon_state = "garland_corner_left"

/obj/structure/sign/christmas/garlandcornerleft2
	name = "garland"
	desc = "Multi-colored rope with different iridescent bulbs"
	icon_state = "garland_corner_left2"

/obj/structure/sign/christmas/garlandcornerright
	name = "garland"
	desc = "Multi-colored rope with different iridescent bulbs"
	icon_state = "garland_corner_right"

/obj/structure/sign/christmas/garlandcornerright2
	name = "garland"
	desc = "Multi-colored rope with different iridescent bulbs"
	icon_state = "garland_corner_right2"

/obj/structure/sign/christmas/minigarland
	name = "garland"
	desc = "Multi-colored rope with different iridescent bulbs"
	icon_state = "minigarland"

/obj/structure/sign/christmas/minigarland2
	name = "garland"
	desc = "Multi-colored rope with different iridescent bulbs"
	icon_state = "minigarland2"

/obj/structure/sign/christmas/sock
	name = "christmas sock"
	desc = "A nice Christmas sock."
	icon_state = "sock"

/obj/structure/sign/christmas/sock2
	name = "christmas sock"
	desc = "A nice Christmas sock."
	icon_state = "sock2"

/obj/structure/sign/christmas/socknt
	name = "NT sock"
	desc = "A nice Christmas sock. Property of NanoTrasen."
	icon_state = "sock_nt"

/obj/structure/sign/christmas/sockfrog
	name = "froggy sock"
	desc = "A nice Christmas sock with frog. Kwa."
	icon_state = "sock_frog"

/obj/structure/sign/christmas/sockhor
	name = "christmas sock"
	desc = "A nice Christmas sock."
	icon_state = "sock_hor"

/obj/structure/sign/christmas/socknthor
	name = "NT sock"
	desc = "A nice Christmas sock. Property of NanoTrasen."
	icon_state = "sock_nt_ho"

	/obj/structure/sign/christmas/sockfroghor
	name = "froggy sock"
	desc = "A nice Christmas sock with frog. Kwa."
	icon_state = "sock_frog_ho"