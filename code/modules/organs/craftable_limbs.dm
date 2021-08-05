/obj/item/weapon/crafrable_limb
	name = "organ printer"
	desc = "It's a machine that prints organs."
	icon = 'icons\mob\human_races\cyberlimbs\makeshift\wooden_assembly.dmi'
	icon_state = ""

	var/state = 1
	var/body_part = "hand"

/obj/item/weapon/crafrable_limb/Initialize()
	update_icon()

/obj/item/weapon/crafrable_limb/update_icon()
	icon_state = "[body_part]-[state]"

/obj/item/weapon/crafrable_limb/attackby(obj/item/weapon/W, mob/user)
/*	switch(state)
		if(1)
			if(isWelder(W))

			if(isCoil(W))
				var/obj/item/stack/cable_coil/C = W
				if (C.use(5))
					to_chat(user, SPAM("notice", "You wire \the [src]."))
					buildstage = 2
					update_icon()
					return
				else
					to_chat(user, SPAN("warning", "You need 5 pieces of cable to do wire \the [src]."))
					return
		if(2)
			if(istype(W, ))

		if(3)
			if(isScrewdriver(W))
	return ..() */


