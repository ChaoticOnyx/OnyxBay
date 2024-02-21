#define INTERCOM_EMPTY     0
#define INTERCOM_WIRED     1
#define INTERCOM_RADIO     2
#define INTERCOM_COMPLETE  3

/obj/item/device/radio/intercom
	name = "intercom (General)"
	desc = "Talk through this."
	icon_state = "intercom"
	randpixel = 0
	anchored = 1
	w_class = ITEM_SIZE_HUGE
	canhear_range = 2
	atom_flags = ATOM_FLAG_NO_BLOOD
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	layer = ABOVE_WINDOW_LAYER
	unacidable = TRUE
	var/number = 0
	var/last_tick //used to delay the powercheck
	var/static/mutable_appearance/ea_overlay
	var/buildstage = INTERCOM_COMPLETE

/obj/item/device/radio/intercom/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/device/radio/intercom/receive()
	flick("intercom-r", src)

/obj/item/device/radio/intercom/custom
	name = "intercom (Custom)"
	broadcasting = 0
	listening = 0

/obj/item/device/radio/intercom/interrogation
	name = "intercom (Interrogation)"
	frequency  = 1449

/obj/item/device/radio/intercom/private
	name = "intercom (Private)"
	frequency = AI_FREQ

/obj/item/device/radio/intercom/specops
	name = "\improper Spec Ops intercom"
	frequency = ERT_FREQ

/obj/item/device/radio/intercom/department
	canhear_range = 5
	broadcasting = 0
	listening = 1

/obj/item/device/radio/intercom/department/medbay
	name = "intercom (Medbay)"
	frequency = MED_I_FREQ

/obj/item/device/radio/intercom/department/security
	name = "intercom (Security)"
	frequency = SEC_I_FREQ

/obj/item/device/radio/intercom/entertainment
	name = "entertainment intercom"
	frequency = ENT_FREQ
	canhear_range = 4

/obj/item/device/radio/intercom/department/medbay/Initialize()
	. = ..()
	internal_channels = list(
		num2text(PUB_FREQ) = list(),
		num2text(MED_FREQ) = list(access_medical_equip),
		num2text(MED_I_FREQ) = list(access_medical_equip)
		)

/obj/item/device/radio/intercom/department/security/Initialize()
	. = ..()
	internal_channels = list(
		num2text(PUB_FREQ) = list(),
		num2text(SEC_I_FREQ) = list(access_security)
	)

/obj/item/device/radio/intercom/entertainment/Initialize()
	. = ..()
	internal_channels = list(
		num2text(PUB_FREQ) = list(),
		num2text(ENT_FREQ) = list()
	)

/obj/item/device/radio/intercom/syndicate
	name = "illicit intercom"
	desc = "Talk through this. Evilly."
	frequency = SYND_FREQ
	subspace_transmission = 1
	syndie = 1

/obj/item/device/radio/intercom/syndicate/Initialize()
	. = ..()
	internal_channels[num2text(SYND_FREQ)] = list(access_syndicate)

/obj/item/device/radio/intercom/raider
	name = "illicit intercom"
	desc = "Pirate radio, but not in the usual sense of the word."
	frequency = RAID_FREQ
	subspace_transmission = 1
	syndie = 1

/obj/item/device/radio/intercom/raider/Initialize()
	. = ..()
	internal_channels[num2text(RAID_FREQ)] = list(access_syndicate)

/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	src.add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/receive_range(freq, level)
	if (!on)
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.z in level))
			return -1
	if (!src.listening)
		return -1
	if(freq in GLOB.antagonist_frequencies)
		if(!(src.syndie))
			return -1//Prevents broadcast of messages over devices lacking the encryption

	return canhear_range

/obj/item/device/radio/intercom/proc/power_change()
	if(buildstage != INTERCOM_COMPLETE)
		on = 0
		return

	if(!src.loc)
		on = 0
	else
		var/area/A = get_area(src)
		if(!A)
			on = 0
		else
			on = A.powered(STATIC_EQUIP) // set "on" to the power status
	update_icon()

/obj/item/device/radio/intercom/on_update_icon()
	if(!ea_overlay)
		ea_overlay = emissive_appearance(icon, "intercom-ea")
	ClearOverlays()
	switch(buildstage)
		if(INTERCOM_EMPTY)
			icon_state = "intercom_b0"
		if(INTERCOM_WIRED)
			icon_state = "intercom_b1"
		if(INTERCOM_RADIO)
			icon_state = "intercom_b2"
		if(INTERCOM_COMPLETE)
			if(on)
				icon_state = "intercom"
				AddOverlays(ea_overlay)
				set_light(0.75, 0.5, 1, 2, "#008000")
			else
				icon_state = "intercom-p"
				set_light(0)

/obj/item/device/radio/intercom/New(loc, dir, atom/frame)
	..(loc)

	if(dir)
		set_dir(dir)

	if(istype(frame))
		buildstage = INTERCOM_EMPTY
		on = 0
		icon_state = "intercom_b0"
		ClearOverlays()
		pixel_x = (dir & (NORTH|SOUTH))? 0 : (dir == EAST ? -22 : 22)
		pixel_y = (dir & (NORTH|SOUTH))? (dir == NORTH ? -22 : 22) : 0
		frame.transfer_fingerprints_to(src)

/obj/item/device/radio/intercom/attackby(obj/item/W, mob/user)
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
		if(INTERCOM_COMPLETE)
			if(isScrewdriver(W))
				unscrew_frame(user)
				return

	return ..()

/obj/item/device/radio/intercom/proc/add_cable(obj/item/stack/cable_coil/C, mob/user)
	if (C.get_amount() < 1)
		show_splash_text(user, "need more coil!")
		return

	show_splash_text(user, "wiring...")
	if(do_after(user, 40, src))
		if (C.use(1))
			show_splash_text(user, "wired!")
			buildstage = INTERCOM_WIRED
			update_icon()

/obj/item/device/radio/intercom/proc/remove_cable(mob/user)
	playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
	show_splash_text(user, "cutting cable...")

	if(do_after(user, 40, src))
		show_splash_text(user, "cut out!")
		new /obj/item/stack/cable_coil(loc, 1)
		buildstage = INTERCOM_EMPTY
		update_icon()

/obj/item/device/radio/intercom/proc/deconstruct_frame(obj/item/weldingtool/WT, mob/user)
	if (WT.remove_fuel(0, user))
		playsound(loc, 'sound/items/Welder2.ogg', 50, 1)
		show_splash_text(user, "dissasembling...")
		if(do_after(user, 40, src))
			if(!WT.isOn())
				return

			new /obj/item/stack/material/steel(loc, 5)
			qdel(src)
	else
		show_splash_text(user, "need more fuel!")
		return

/obj/item/device/radio/intercom/proc/add_radio(obj/item/device/radio/R, mob/user)
	playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
	show_splash_text(user, "installing radio...")

	if(do_after(user, 40, src))
		if(!user.drop(R, src))
			return

		show_splash_text(user, "installed!")
		qdel(R)
		buildstage = INTERCOM_RADIO
		update_icon()

/obj/item/device/radio/intercom/proc/eject_radio(mob/user)
	playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
	show_splash_text(user, "removing radio...")

	if(do_after(user, 40, src))
		show_splash_text(user, "removed radio!")
		new /obj/item/device/radio(user.loc, 1)
		buildstage = INTERCOM_WIRED
		update_icon()

/obj/item/device/radio/intercom/proc/finish_frame(mob/user)
	playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
	show_splash_text(user, "finishing \the [src]...")

	if(do_after(user, 40, src))
		show_splash_text(user, "finished \the [src]!")
		on = 1
		buildstage = INTERCOM_COMPLETE
		update_icon()

/obj/item/device/radio/intercom/proc/unscrew_frame(mob/user)
	playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
	show_splash_text(user, "unscrewing [src]...")

	if(do_after(user, 40, src))
		show_splash_text(user, "unscrewed!")
		buildstage = INTERCOM_RADIO
		power_change()
		update_icon()

/obj/item/device/radio/intercom/broadcasting
	broadcasting = 1

/obj/item/device/radio/intercom/locked
	var/locked_frequency

/obj/item/device/radio/intercom/locked/set_frequency()
	..(locked_frequency)

/obj/item/device/radio/intercom/locked/list_channels()
	return ""

/obj/item/device/radio/intercom/locked/ai_private
	name = "\improper AI intercom"
	locked_frequency = AI_FREQ
	broadcasting = 1
	listening = 1

/obj/item/device/radio/intercom/locked/confessional
	name = "confessional intercom"
	locked_frequency = 1480

#undef INTERCOM_EMPTY
#undef INTERCOM_WIRED
#undef INTERCOM_RADIO
#undef INTERCOM_COMPLETE
