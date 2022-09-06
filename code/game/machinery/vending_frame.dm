#define STAGE_CABLE 0
#define STAGE_CARTRIDGE 1
#define STAGE_GLASS 2
#define STAGE_FINISHING 3

/obj/machinery/vending_frame
	name = "tall machine frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "vbox_0"
	density = 1
	anchored = FALSE
	use_power = POWER_USE_OFF
	atom_flags = ATOM_FLAG_CLIMBABLE
	pull_sound = SFX_PULL_MACHINE
	var/state = STAGE_CABLE
	var/obj/item/vending_cartridge/cartridge

/obj/machinery/vending_frame/proc/update_desc()
	var/D
	if(cartridge)
		D = "It is [name]. It has [cartridge.name] inside."
	else
		D = "It is [name]. It has no vending cartridge inside."
	desc = D

/obj/machinery/vending_frame/update_icon()
	switch(state)
		if(STAGE_CABLE)
			icon_state = "vbox_0"
		if(STAGE_CARTRIDGE)
			icon_state = "vbox_1"
		if(STAGE_GLASS)
			icon_state = "vbox_2"
		if(STAGE_FINISHING)
			icon_state = "vbox_3"

/obj/machinery/vending_frame/attackby(obj/item/O, mob/user)
	switch(state)
		if(STAGE_CABLE)
			if(isWrench(O))
				wrench_frame(user)
			if(isCoil(O))
				add_cable(O, user)
		if(STAGE_CARTRIDGE)
			if(isWrench(O))
				wrench_frame(user)
			if(isWirecutter(O))
				remove_cable(user)
			if(!anchored)
				to_chat(user, SPAN_WARNING("You need to secure [name] first!"))
				return
			if(istype(O, /obj/item/vending_cartridge))
				add_cartridge(O, user)
		if(STAGE_GLASS)
			if(isCrowbar(O))
				remove_cartridge(user)
			if(istype(O, /obj/item/stack/material/glass))
				add_glass(O, user)
		if(STAGE_FINISHING)
			if(isCrowbar(O))
				remove_glass(user)
			if(isScrewdriver(O))
				create_vendomat()

/obj/machinery/vending_frame/proc/wrench_frame(mob/user)
	playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
	if(do_after(user, 20, src))
		to_chat(user, SPAN_NOTICE("You [anchored ? "unwrench" : "wrench"] the frame [anchored ? "from" : "into"] place."))
		anchored = !anchored

/obj/machinery/vending_frame/proc/add_cable(obj/item/stack/cable_coil/C, mob/user)
	if(C.get_amount() < 5)
		to_chat(user, SPAN_WARNING("You need at least five lengths of cable to add it to the frame."))
		return
	playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
	to_chat(user, SPAN_NOTICE("You start to add cables to the frame."))
	if(do_after(user, 20, src) && state == STAGE_CABLE)
		if(C.use(5))
			to_chat(user, SPAN_NOTICE("You have added cables to the frame."))
			state = STAGE_CARTRIDGE
			update_icon()

/obj/machinery/vending_frame/proc/remove_cable(mob/user)
	playsound(loc, 'sound/items/Wirecutter.ogg', 50, 1)
	to_chat(user, SPAN_NOTICE("You remove the cables."))
	var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(loc)
	C.amount = 5
	state = STAGE_CABLE
	update_icon()

/obj/machinery/vending_frame/proc/add_cartridge(obj/item/vending_cartridge/C, mob/user)
	cartridge = C
	user.drop_item()
	C.forceMove(src)
	playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
	to_chat(user, SPAN_NOTICE("You add the [C.name] to the frame."))
	state = STAGE_GLASS
	update_desc()
	update_icon()

/obj/machinery/vending_frame/proc/remove_cartridge(mob/user)
	playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
	to_chat(user, SPAN_NOTICE("You remove the [cartridge.name]"))
	cartridge.forceMove(src.loc)
	cartridge = null
	state = STAGE_CARTRIDGE
	update_desc()
	update_icon()

/obj/machinery/vending_frame/proc/add_glass(obj/item/stack/material/glass/G, mob/user)
	if(G.get_amount() < 5)
		to_chat(user, SPAN_WARNING("You need at least five sheets of glass to add it to the frame."))
		return
	playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
	to_chat(user, SPAN_NOTICE("You start to install display in the frame."))
	if(do_after(user, 20, src) && state == STAGE_GLASS)
		if(G.use(5))
			to_chat(user, SPAN_NOTICE("You have installed display in the frame."))
			state = STAGE_FINISHING
			update_icon()

/obj/machinery/vending_frame/proc/remove_glass(mob/user)
	playsound(loc, 'sound/items/Wirecutter.ogg', 50, 1)
	to_chat(user, SPAN_NOTICE("You remove the glass display."))
	var/obj/item/stack/material/glass/G = new /obj/item/stack/material/glass(loc)
	G.amount = 5
	state = STAGE_GLASS
	update_icon()

/obj/machinery/vending_frame/proc/create_vendomat()
	playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
	var/obj/machinery/vending/new_vendomat = new cartridge.build_path(loc, dir)
	if(new_vendomat.component_parts)
		QDEL_LIST(new_vendomat.component_parts)
	cartridge.forceMove(new_vendomat)
	new_vendomat.component_parts.Add(cartridge)
	new_vendomat.refresh_cartridge()
	qdel(src)

/obj/machinery/vending_frame/proc/refresh_cartridge()
	cartridge = locate() in contents

#undef STAGE_CABLE
#undef STAGE_CARTRIDGE
#undef STAGE_GLASS
#undef STAGE_FINISHING
