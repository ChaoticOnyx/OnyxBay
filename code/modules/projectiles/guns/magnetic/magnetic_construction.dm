// We really need some datums for this.
/obj/item/coilgun_assembly
	name = "coilgun stock"
	desc = "It might be a coilgun, someday."
	icon = 'icons/obj/coilgun.dmi'
	icon_state = "coilgun_construction_1"

	var/construction_stage = 1

/obj/item/coilgun_assembly/attackby(obj/item/thing, mob/user)

	if(istype(thing, /obj/item/stack/material) && construction_stage == 1)
		var/obj/item/stack/material/reinforcing = thing
		var/material/reinforcing_with = reinforcing.get_material()
		if(reinforcing_with.name == MATERIAL_STEEL) // Steel
			if(reinforcing.get_amount() < 5)
				to_chat(user, "<span class='warning'>You need at least 5 [reinforcing.singular_name]\s for this task.</span>")
				return
			reinforcing.use(5)
			user.visible_message("<span class='notice'>\The [user] shapes some steel sheets around \the [src] to form a body.</span>")
			increment_construction_stage()
			return

	if(istype(thing, /obj/item/tape_roll) && construction_stage == 2)
		user.visible_message("<span class='notice'>\The [user] secures \the [src] together with \the [thing].</span>")
		increment_construction_stage()
		return

	if(istype(thing, /obj/item/pipe) && construction_stage == 3)
		user.drop_from_inventory(thing)
		qdel(thing)
		user.visible_message("<span class='notice'>\The [user] jams \the [thing] into \the [src].</span>")
		increment_construction_stage()
		return

	if(isWelder(thing) && construction_stage == 4)
		var/obj/item/weldingtool/welder = thing

		if(!welder.isOn())
			to_chat(user, "<span class='warning'>Turn it on first!</span>")
			return

		if(!welder.remove_fuel(0,user))
			to_chat(user, "<span class='warning'>You need more fuel!</span>")
			return

		user.visible_message("<span class='notice'>\The [user] welds the barrel of \the [src] into place.</span>")
		playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
		increment_construction_stage()
		return

	if(isCoil(thing) && construction_stage == 5)
		var/obj/item/stack/cable_coil/cable = thing
		if(cable.get_amount() < 5)
			to_chat(user, "<span class='warning'>You need at least 5 lengths of cable for this task.</span>")
			return
		cable.use(5)
		user.visible_message("<span class='notice'>\The [user] wires \the [src].</span>")
		increment_construction_stage()
		return

	if(istype(thing, /obj/item/smes_coil) && construction_stage >= 6 && construction_stage <= 8)
		user.visible_message("<span class='notice'>\The [user] installs \a [thing] into \the [src].</span>")
		user.drop_from_inventory(thing)
		qdel(thing)
		increment_construction_stage()
		return

	if(isScrewdriver(thing) && construction_stage >= 9)
		user.visible_message("<span class='notice'>\The [user] secures \the [src] and finishes it off.</span>")
		playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		var/obj/item/gun/magnetic/coilgun = new(loc)
		var/put_in_hands
		var/mob/M = src.loc
		if(istype(M))
			put_in_hands = M == user
			M.drop_from_inventory(src)
		if(put_in_hands)
			user.put_in_hands(coilgun)
		qdel(src)
		return

	return ..()

/obj/item/coilgun_assembly/proc/increment_construction_stage()
	if(construction_stage < 9)
		construction_stage++
	icon_state = "coilgun_construction_[construction_stage]"

/obj/item/coilgun_assembly/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) <= 2)
		switch(construction_stage)
			if(2) . += "\n<span class='notice'>It has a metal frame loosely shaped around the stock.</span>"
			if(3) . += "\n<span class='notice'>It has a metal frame duct-taped to the stock.</span>"
			if(4) . += "\n<span class='notice'>It has a length of pipe attached to the body.</span>"
			if(4) . += "\n<span class='notice'>It has a length of pipe welded to the body.</span>"
			if(6) . += "\n<span class='notice'>It has a cable mount and capacitor jack wired to the frame.</span>"
			if(7) . += "\n<span class='notice'>It has a single superconducting coil threaded onto the barrel.</span>"
			if(8) . += "\n<span class='notice'>It has a pair of superconducting coils threaded onto the barrel.</span>"
			if(9) . += "\n<span class='notice'>It has three superconducting coils attached to the body, waiting to be secured.</span>"
