#define STATE_UNANCHORED  0
#define STATE_EMPTY       1
#define STATE_WIRED       2
#define STATE_SIGNALLER   3

/obj/structure/secure_door_assembly
	name = "secure door assembly"
	icon = 'icons/obj/doors/secure_door_assembly.dmi'
	anchored = FALSE
	density = TRUE
	obj_flags = OBJ_FLAG_ANCHORABLE | OBJ_FLAG_ANCHOR_BLOCKS_ROTATION
	var/state = STATE_UNANCHORED
	var/obj/item/device/assembly/signaler/signaler = null
	var/base_icon = null
	var/material_path = null
	var/door_path = null

/obj/structure/secure_door_assembly/Initialize()
	. = ..()

	AddElement(/datum/element/simple_rotation)

/obj/structure/secure_door_assembly/Destroy()
	QDEL_NULL(signaler)
	return ..()

/obj/structure/secure_door_assembly/proc/make_just_dismantled()
	anchored = TRUE
	state = STATE_WIRED
	update_icon()

/obj/structure/secure_door_assembly/on_update_icon()
	switch(state)
		if(STATE_EMPTY)
			icon_state = "[base_icon]_st0"
		if(STATE_WIRED)
			icon_state = "[base_icon]_st1"
		if(STATE_SIGNALLER)
			icon_state = "[base_icon]_st2"

/obj/structure/secure_door_assembly/attackby(obj/item/W, mob/user)
	switch(state)
		if(STATE_UNANCHORED)
			if(isWelder(W))
				deconstruct_assembly(W, user)
				return

		if(STATE_EMPTY)
			if(isCoil(W))
				add_cable(W, user)
				return

		if(STATE_WIRED)
			if(isWirecutter(W))
				remove_cable(user)
				return

			if(istype(W, /obj/item/device/assembly/signaler))
				add_signaler(W, user)
				return

		if(STATE_SIGNALLER)
			if(isCrowbar(W))
				remove_signaler(user)
				return

			if(isScrewdriver(W))
				finish_assembly(user)
				return

	return ..()

/obj/structure/secure_door_assembly/proc/deconstruct_assembly(obj/item/weldingtool/WT, mob/user)
	user.visible_message("[user] dissassembles \the [src].", "You start to dissassemble \the [src].")
	if(!WT.use_tool(src, user, delay = 4 SECONDS, amount = 5))
		return

	to_chat(user, SPAN_NOTICE("You dissasembled \the [src]!"))
	new material_path(loc, 10)
	qdel(src)

/obj/structure/secure_door_assembly/wrench_floor_bolts(mob/user, delay = 40)
	if(state > STATE_EMPTY)
		return

	. = ..()

	if(anchored)
		state = STATE_EMPTY
	else
		state = STATE_UNANCHORED

/obj/structure/secure_door_assembly/proc/add_cable(obj/item/stack/cable_coil/C, mob/user)
	if (C.get_amount() < 1)
		to_chat(user, SPAN_WARNING("You need one length of coil to wire \the [src] ."))
		return

	user.visible_message("[user] wires \the [src].", "You start to wire \the [src].")
	if(do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG) && anchored)
		if (C.use(1))
			to_chat(user, SPAN_NOTICE("You wire \the [src]."))
			state = STATE_WIRED
			update_icon()

/obj/structure/secure_door_assembly/proc/remove_cable(mob/user)
	playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
	user.visible_message("[user] cuts the wires from \the [src].", "You start to cut the wires from \the [src].")

	if(do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
		to_chat(user, SPAN_NOTICE("You cut \the [src] wires!"))
		new /obj/item/stack/cable_coil(loc, 1)
		state = STATE_EMPTY
		update_icon()

/obj/structure/secure_door_assembly/proc/add_signaler(obj/item/device/assembly/signaler/W, mob/user)
	playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
	user.visible_message("[user] installs the signaller into \the [src].", "You start to install signaller into \the [src].")

	if(do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
		if(!user.drop(W, src))
			return

		to_chat(user, SPAN_NOTICE("You installed signaller into \the [src]!"))
		signaler = W
		state = STATE_SIGNALLER
		update_icon()

/obj/structure/secure_door_assembly/proc/remove_signaler(mob/user)
	user.visible_message("\The [user] starts removing the signaller from \the [src].", "You start removing the signaller from \the [src].")

	if(do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
		to_chat(user, SPAN_NOTICE("You removed \the signaller!"))
		state = STATE_WIRED
		signaler.dropInto(loc)
		signaler = null
		update_icon()

/obj/structure/secure_door_assembly/proc/finish_assembly(mob/user)
	playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
	to_chat(user, SPAN_NOTICE("Now finishing \the shutters."))

	if(do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
		new door_path(loc, signaler?.code, signaler?.frequency, dir)
		qdel(src)

/obj/structure/secure_door_assembly/blast
	name = "blast door assembly"
	icon = 'icons/obj/doors/secure_door_assembly.dmi'
	icon_state = "blast_st0"
	base_icon = "blast"
	material_path = /obj/item/stack/material/plasteel
	door_path = /obj/machinery/door/blast/regular

/obj/structure/secure_door_assembly/shutters
	name = "shutters assembly"
	icon = 'icons/obj/doors/secure_door_assembly.dmi'
	icon_state = "shutter_st0"
	base_icon = "shutter"
	material_path = /obj/item/stack/material/steel
	door_path = /obj/machinery/door/blast/shutters


#undef STATE_UNANCHORED
#undef STATE_EMPTY
#undef STATE_WIRED
#undef STATE_SIGNALLER
