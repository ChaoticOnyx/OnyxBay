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
	if(on)
		icon_state = "intercom"
		em_block_state = "intercom-eb"
		AddOverlays(ea_overlay)
		set_light(0.75, 0.5, 1, 2, "#008000")
	else
		icon_state = "intercom-p"
		em_block_state = null
		set_light(0)

/obj/item/device/radio/intercom/Initialize(mapload, _dir)
	. = ..(mapload)

	if(_dir)
		set_dir(_dir)

	if(!pixel_x && !pixel_y) // Don't touch the premapped shifts
		switch(dir)
			if(NORTH)
				pixel_y = -22
			if(SOUTH)
				pixel_y = 22
			if(EAST)
				pixel_x = -22
			if(WEST)
				pixel_x = 22

	power_change()

/obj/item/device/radio/intercom/attackby(obj/item/W, mob/user)
	if(isScrewdriver(W))
		unscrew_frame(user)
		return

	return ..()

/obj/item/device/radio/intercom/proc/unscrew_frame(mob/user)
	playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
	show_splash_text(user, "unscrewing...", "Now unscrewing \the [src]...")

	if(do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
		show_splash_text(user, "unscrewed!", SPAN("notice", "You have unscrewed \the [src]!"))
		new /obj/item/intercom_assembly(loc, dir, src)
		qdel(src)

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
