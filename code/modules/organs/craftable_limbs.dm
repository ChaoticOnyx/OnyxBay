/obj/item/weapon/craftable_limb
	name = "prosthetic assembly"
	desc = "It looks like some kind of prosthetic limb."
	icon = 'icons/mob/human_races/cyberlimbs/makeshift/wooden_assembly.dmi'
	icon_state = "hand"

	var/state = 1

	var/company = "Morgan Trading Co"
	var/build_path = /obj/item/organ/external/arm

/obj/item/weapon/crafrable_limb/Initialize()
	. = ..()

	update_icon()

/obj/item/weapon/craftable_limb/update_icon()
	overlays.Cut()
	icon_state = initial(icon_state)
	switch(state)
		if(1)
			return
		if(2)
			overlays.Add(image(icon, "[icon_state]_wire"))
		if(3)
			overlays.Add(image(icon, "[icon_state]_casing"))

/obj/item/weapon/craftable_limb/proc/create_prosthtic()

/obj/item/weapon/craftable_limb/attackby(obj/item/weapon/W, mob/user)
	switch(state)
		if(1)
			if(isWelder(W))
				var/obj/item/weapon/weldingtool/WT = W

				if(!WT.isOn())
					to_chat(user, "The welder must be on for this task.")
					return

				playsound(loc, 'sound/items/Welder.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You deconstruct the assembly.</span>")
				new /obj/item/stack/material/steel(user.loc, 2)
				qdel(src)

			if(isCoil(W))
				var/obj/item/stack/cable_coil/C = W
				if(C.use(2))
					to_chat(user, SPAN("notice", "You add cables to \the [src]."))
					state = 2
					update_icon()
				else
					to_chat(user, SPAN("warning", "You need 2 pieces of cable to do wire \the [src]."))
					return
		if(2)
			if(isWirecutter(W))
				to_chat(user, SPAN("notice", "You remove the cables from \the [src]."))
				state = 1
				update_icon()
				new /obj/item/stack/cable_coil(user.loc, 2)

			if(istype(W, /obj/item/stack/material/wood))
				var/obj/item/stack/material/wood/M = W
				if(M.use(2))
					to_chat(user, SPAN("notice", "You add wooden cover to \the [src]."))
					state = 3
					update_icon()
				else
					to_chat(user, SPAN("warning", "You need al least 2 wooden boards to add cover on \the [src]."))
					return
		if(3)
			if(isCrowbar(W))
				to_chat(user, SPAN("notice", "You remove wooden shielding from \the [src]."))
				state = 2
				update_icon()
				new /obj/item/stack/material/wood(user.loc, 2)

			if(isScrewdriver(W))
				to_chat(user, SPAN("notice", "You start securing \the [src]'s cover."))
				if(do_after(user, 20, src))
					to_chat(user, SPAN("notice", "You secure \the [src]'s cover."))
					create_prosthtic()
	return ..()


