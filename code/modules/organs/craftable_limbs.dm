/obj/item/weapon/craftable_limb
	name = "prosthetic assembly"
	desc = "It looks like some kind of prosthetic limb."
	icon = 'icons/mob/human_races/cyberlimbs/makeshift/wooden_assembly.dmi'
	icon_state = "arm"

	var/state = 1

	var/company = "Morgan Trading Co"
	var/body_part = BP_L_ARM

/obj/item/weapon/craftable_limb/right
	body_part = BP_R_ARM

/obj/item/weapon/craftable_limb/leg
	icon_state = "leg"
	body_part = BP_L_LEG

/obj/item/weapon/craftable_limb/leg/right
	body_part = BP_R_LEG

/obj/item/weapon/craftable_limb/update_icon()
	overlays.Cut()
	switch(state)
		if(1)
			icon_state = initial(icon_state)
		if(2)
			icon_state = "[initial(icon_state)]_wire"
		if(3)
			icon_state = "[initial(icon_state)]_casing"

/obj/item/weapon/craftable_limb/proc/create_prosthtic()
	var/mob/living/carbon/human/H = new /mob/living/carbon/human(usr.loc)
	H.death(0, "no message")

	H.set_species(SPECIES_HUMAN)
	H.gender = MALE

	var/obj/item/organ/external/O = H.get_organ(body_part)
	O.robotize(company)

	O.droplimb(clean = TRUE, silent = TRUE)
	O.clean_blood()

	qdel(H)

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
					qdel(src)
	return ..()


