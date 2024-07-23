#define INTERCOM_EMPTY     0
#define INTERCOM_WIRED     1
#define INTERCOM_RADIO     2

/obj/item/intercom_assembly
	name = "intercom asssembly"
	desc = "Unassembled intercom."
	icon = 'icons/obj/radio.dmi'
	icon_state = "intercom_b0"
	randpixel = FALSE
	anchored = TRUE
	w_class = ITEM_SIZE_HUGE
	atom_flags = ATOM_FLAG_NO_BLOOD
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	layer = ABOVE_WINDOW_LAYER
	unacidable = TRUE
	var/buildstage = INTERCOM_EMPTY

/obj/item/intercom_assembly/Initialize(mapload, _dir, atom/frame)
	. = ..(mapload)

	if(_dir)
		set_dir(_dir)

	if(istype(frame, /obj/item/frame/intercom))
		buildstage = INTERCOM_EMPTY
		frame.transfer_fingerprints_to(src)
		switch(dir)
			if(NORTH)
				pixel_y = -22
			if(SOUTH)
				pixel_y = 22
			if(EAST)
				pixel_x = -22
			if(WEST)
				pixel_x = 22
	else
		buildstage = INTERCOM_RADIO
		switch(dir)
			if(NORTH)
				pixel_y = -22
			if(SOUTH)
				pixel_y = 22
			if(EAST)
				pixel_x = -22
			if(WEST)
				pixel_x = 22

	update_icon()

/obj/item/intercom_assembly/on_update_icon()
	switch(buildstage)
		if(INTERCOM_EMPTY)
			icon_state = "intercom_b0"
		if(INTERCOM_WIRED)
			icon_state = "intercom_b1"
		if(INTERCOM_RADIO)
			icon_state = "intercom_b2"

/obj/item/intercom_assembly/attackby(obj/item/W, mob/user)
	switch(buildstage)
		if(INTERCOM_EMPTY)
			if(isCoil(W))
				add_cable(W, user)
				return

			if(isWelder(W))
				deconstruct_frame(W, user)
				return

		if(INTERCOM_WIRED)
			if(istype(W, /obj/item/device/radio))
				add_radio(W, user)
				return

			if(isWirecutter(W))
				remove_cable(user)
				return

		if(INTERCOM_RADIO)
			if(isScrewdriver(W))
				finish_frame(user)
				return

			if(isCrowbar(W))
				eject_radio(user)
				return

	return ..()

/obj/item/intercom_assembly/proc/add_cable(obj/item/stack/cable_coil/C, mob/user)
	if(C.get_amount() < 1)
		show_splash_text(user, "need more coil!", SPAN("warning", "You need more cable to wire \the [src]!"))
		return

	show_splash_text(user, "wiring...", "Now wiring \the [src]...")
	if(do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
		if(C.use(1))
			show_splash_text(user, "wired!", SPAN("notice", "You have wired \the [src]!"))
			buildstage = INTERCOM_WIRED
			update_icon()

/obj/item/intercom_assembly/proc/remove_cable(mob/user)
	playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
	show_splash_text(user, "cutting cable...", "Now cutting cable out of \the [src]...")

	if(do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
		show_splash_text(user, "cut out!", SPAN("notice", "You have cut the cable out of \the [src]!"))
		new /obj/item/stack/cable_coil(loc, 1)
		buildstage = INTERCOM_EMPTY
		update_icon()

/obj/item/intercom_assembly/proc/deconstruct_frame(obj/item/weldingtool/WT, mob/user)
	show_splash_text(user, "dissasembling...", "Now dissasembling \the [src]...")
	if(!WT.use_tool(src, user, delay = 4 SECONDS, amount = 5))
		return

	if(QDELETED(src) || !user)
		return

	new /obj/item/stack/material/steel(loc, 3)
	qdel(src)

/obj/item/intercom_assembly/proc/add_radio(obj/item/device/radio/R, mob/user)
	playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
	show_splash_text(user, "installing radio...", "Now installing the radio into \the [src]...")

	if(do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
		if(!user.drop(R, src))
			return

		show_splash_text(user, "installed!", SPAN("notice", "You have installed the radio into \the [src]!"))
		qdel(R)
		buildstage = INTERCOM_RADIO
		update_icon()

/obj/item/intercom_assembly/proc/eject_radio(mob/user)
	playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
	show_splash_text(user, "removing radio...", "Now removing the radio from \the [src]...")

	if(do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
		show_splash_text(user, "removed radio!", SPAN("notice", "You have removed the radio from \the [src]!"))
		new /obj/item/device/radio(user.loc, 1)
		buildstage = INTERCOM_WIRED
		update_icon()

/obj/item/intercom_assembly/proc/finish_frame(mob/user)
	playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
	show_splash_text(user, "finishing \the [src]...", "Now finishing \the [src]...")

	if(do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
		show_splash_text(user, "finished \the [src]!", SPAN("notice", "You have finished assembing \the [src]!"))
		new /obj/item/device/radio/intercom(loc, dir)
		qdel(src)

#undef INTERCOM_EMPTY
#undef INTERCOM_WIRED
#undef INTERCOM_RADIO
