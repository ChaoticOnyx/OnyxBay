
// HUD Matrices
/obj/item/device/hudmatrix
	name = "HUD optical matrix"
	desc = "An optical matrix for a HUD."
	icon = 'icons/obj/hud_modules.dmi'
	icon_state = "matrix"
	item_state = ""
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	var/hud_type = null
	var/obj/screen/overlay = null
	var/vision_flags = 0
	var/see_invisible = 0
	var/darkness_view = 0 //Base human is 2
	var/flash_protection = FLASH_PROTECTION_NONE
	var/matrix_type = ""
	var/matrix_icon = ""
	var/sec_hud = FALSE
	var/med_hud = FALSE
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 2)

/obj/item/device/hudmatrix/material
	name = "HUD material matrix"
	desc = "Used for various dynamic objects through anything."
	icon_state = "matrix_material"
	vision_flags = SEE_OBJS
	matrix_type = "material"
	matrix_icon = "material"
	origin_tech = list(TECH_MAGNET = 3, TECH_ENGINEERING = 3)

/obj/item/device/hudmatrix/material/Initialize()
	. = ..()
	overlay = GLOB.global_hud.material

/obj/item/device/hudmatrix/meson
	name = "HUD meson matrix"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "matrix_meson"
	vision_flags = SEE_TURFS
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	matrix_type = "meson"
	matrix_icon = "meson"
	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 2)

/obj/item/device/hudmatrix/meson/Initialize()
	. = ..()
	overlay = GLOB.global_hud.meson

/obj/item/device/hudmatrix/security
	name = "HUD security matrix"
	desc = "Scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "matrix_sec"
	hud_type = HUD_SECURITY
	flash_protection = FLASH_PROTECTION_MODERATE
	darkness_view = -1
	matrix_type = "security"
	matrix_icon = "sec"
	sec_hud = TRUE

/obj/item/device/hudmatrix/thermal
	name = "HUD thermal matrix"
	desc = "Used for seeing living creatures through anything."
	icon_state = "matrix_thermal"
	vision_flags = SEE_MOBS
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	flash_protection = FLASH_PROTECTION_REDUCED
	matrix_type = "thermal"
	matrix_icon = "thermal"

/obj/item/device/hudmatrix/thermal/Initialize()
	. = ..()
	overlay = GLOB.global_hud.thermal

/obj/item/device/hudmatrix/medical
	name = "HUD medical matrix"
	desc = "Scans the humans in view and provides accurate data about their health status."
	icon_state = "matrix_medical"
	hud_type = HUD_MEDICAL
	matrix_type = "medical"
	matrix_icon = "medical"
	med_hud = TRUE

/obj/item/device/hudmatrix/science
	name = "HUD science matrix"
	desc = "Capable of determining the fabricator training potential of an item, components of a machine, or contained reagents."
	icon_state = "matrix_science"
	hud_type = HUD_SCIENCE
	matrix_type = "science"
	matrix_icon = "science"

/obj/item/device/hudmatrix/science/Initialize()
	. = ..()
	overlay = GLOB.global_hud.science

/obj/item/device/hudmatrix/night
	name = "HUD night vision matrix"
	desc = "Amplifies light for dark environments."
	icon_state = "matrix_night"
	hud_type = HUD_SECURITY
	matrix_type = "night vision"
	matrix_icon = "night"
	darkness_view = 7
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	origin_tech = list(TECH_MAGNET = 2)

/obj/item/device/hudmatrix/night/Initialize()
	. = ..()
	overlay = GLOB.global_hud.nvg

/obj/item/device/hudmatrix/thermal/syndie
	name = "suspicious HUD matrix"
	desc = "Used for seeing living creatures through anything without attracting unwanted attention."
	icon_state = "matrix_syndie"
	matrix_type = "meson"
	matrix_icon = "meson"
	var/syndie_matrix_mask = 0 // 0 for meson, 1 for medical, 2 for science, 3 for thermal

/obj/item/device/hudmatrix/thermal/syndie/attack_self(mob/user) // Kinda placeholderish stuff, gonna be changed in the future ~Toby
	syndie_matrix_mask++
	if(syndie_matrix_mask > 3)
		syndie_matrix_mask = 0
	switch(syndie_matrix_mask)
		if(0)
			matrix_type = "meson"
			matrix_icon = "meson"
		if(1)
			matrix_type = "medical"
			matrix_icon = "medical"
		if(2)
			matrix_type = "science"
			matrix_icon = "science"
		if(3)
			matrix_type = "thermal"
			matrix_icon = "thermal"
	to_chat(user, SPAN("notice", "\The [src] mimics a [matrix_type] now."))

// HUD Lenses
/obj/item/device/hudlenses
	name = "HUD lenses"
	desc = "A set of attachable lenses for HUDs."
	icon = 'icons/obj/hud_modules.dmi'
	icon_state = ""
	item_state = ""
	w_class = ITEM_SIZE_TINY

/obj/item/device/hudlenses/proc/attach_lenses(obj/item/clothing/glasses/hud/H)
	if(!H)
		return 0
	forceMove(H)
	H.lenses = src
	return 1

/obj/item/device/hudlenses/proc/detach_lenses(obj/item/clothing/glasses/hud/H)
	if(!H)
		return
	dropInto(get_turf(H))
	H.lenses = null

/obj/item/device/hudlenses/prescription
	name = "HUD prescription lenses"
	desc = "A set of attachable prescription lenses for HUDs."
	icon = 'icons/obj/hud_modules.dmi'
	icon_state = "prescription"

/obj/item/device/hudlenses/prescription/attach_lenses(obj/item/clothing/glasses/hud/H)
	. = ..()
	if(!.)
		return 0
	H.prescription = 7

/obj/item/device/hudlenses/prescription/detach_lenses(obj/item/clothing/glasses/hud/H)
	if(!H)
		return
	H.prescription = initial(H.prescription)
	..()

/obj/item/device/hudlenses/sunshield
	name = "HUD sunshield lenses"
	desc = "A set of attachable sunshield lenses for HUDs."
	icon = 'icons/obj/hud_modules.dmi'
	icon_state = "sunshield"

/obj/item/device/hudlenses/sunshield/attach_lenses(obj/item/clothing/glasses/hud/H)
	. = ..()
	if(!.)
		return 0
	H.cumulative_flash_protection++

/obj/item/device/hudlenses/sunshield/detach_lenses(obj/item/clothing/glasses/hud/H)
	if(!H)
		return
	H.cumulative_flash_protection--
	..()

// Finally HUDs themselves
/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A HUD."
	gender = NEUTER
	icon_state = "hud_standard"
	item_state = "hud_standard"
	item_state_slots = list(
		slot_l_hand_str = "sunglasses",
		slot_r_hand_str = "sunglasses"
		)
	origin_tech = list(TECH_MATERIAL = 2)
	action_button_name = "Toggle HUD"
	toggleable = TRUE
	electric = TRUE
	active = FALSE
	var/hud_name = ""
	var/hud_icon = ""
	var/obj/item/device/hudmatrix/matrix = null
	var/obj/item/device/hudlenses/lenses = null
	var/matrix_removable = TRUE
	var/cumulative_flash_protection = FLASH_PROTECTION_NONE
	var/sec_hud = FALSE
	var/med_hud = FALSE

/obj/item/clothing/glasses/hud/_examine_text(mob/user)
	. = ..()
	if(matrix)
		. += "\nIt has a [matrix.matrix_type] optical matrix installed."
	if(lenses)
		. += "\nIt has [lenses] installed."

/obj/item/clothing/glasses/hud/Initialize()
	. = ..()
	icon_state = "hud_[hud_icon]"
	item_state = "hud_[hud_icon]"
	if(ispath(matrix))
		matrix = new matrix(src)
		cumulative_flash_protection += matrix.flash_protection
		if(active)
			activate_matrix()
	if(ispath(lenses))
		lenses = new lenses()
		lenses.attach_lenses(src)

/obj/item/clothing/glasses/hud/Destroy()
	QDEL_NULL(matrix)
	QDEL_NULL(lenses)
	return ..()

/obj/item/clothing/glasses/hud/process_hud(mob/M)
	if(sec_hud)
		process_sec_hud(M, 1)
	if(med_hud)
		process_med_hud(M, 1)

/obj/item/clothing/glasses/hud/update_icon()
	overlays.Cut()
	if(active && matrix)
		overlays += overlay_image(icon, "[hud_icon]_[matrix.matrix_icon]")
	if(lenses)
		overlays += overlay_image(icon, "[hud_icon]_[lenses.icon_state]")

/obj/item/clothing/glasses/hud/attackby(obj/item/W, mob/user)
	if(isScrewdriver(W))
		if(!matrix)
			if(lenses)
				lenses.detach_lenses(src)
				update_icon()
				update_clothing_icon()
				user.update_action_buttons()
				return
			to_chat(user, SPAN("notice", "\The [src] has no optical matrix installed."))
			return
		if(!matrix_removable)
			return
		deactivate_matrix()
		cumulative_flash_protection -= matrix.flash_protection
		to_chat(user, SPAN("notice", "You uninstall \the [matrix] from \the [src]."))
		matrix.dropInto(get_turf(src))
		matrix = null
		update_clothing_icon()
		user.update_action_buttons()

	if(istype(W, /obj/item/device/hudmatrix))
		if(matrix)
			to_chat(user, SPAN("notice", "\The [src] already has a [matrix] installed."))
			return
		if(user.unEquip(W))
			W.forceMove(src)
			matrix = W
			cumulative_flash_protection += matrix.flash_protection
			to_chat(user, SPAN("notice", "You install \the [matrix] into \the [src]."))
			sound_to(user, sound(deactivation_sound, volume = 50))
			update_clothing_icon()
			user.update_action_buttons()

	if(istype(W, /obj/item/device/hudlenses))
		if(lenses)
			to_chat(user, SPAN("notice", "\The [src] already has [lenses] installed."))
			return
		if(one_eyed)
			to_chat(user, SPAN("notice", "\The [W] cannot be attached to \the [src]."))
			return
		if(active)
			to_chat(user, SPAN("notice", "You must deactivate the optical matrix first."))
			return
		if(user.unEquip(W))
			var/obj/item/device/hudlenses/H = W
			H.attach_lenses(src)
			to_chat(user, SPAN("notice", "You install \the [H] into \the [src]."))
			sound_to(user, sound(deactivation_sound, volume = 50))
			update_clothing_icon()
			user.update_action_buttons()

	else
		..()

/obj/item/clothing/glasses/hud/attack_self(mob/user)
	if(!user.incapacitated())
		toggle_matrix(user)
	return

/obj/item/clothing/glasses/hud/proc/activate_matrix()
	if(!matrix)
		return
	active = TRUE
	name = "[matrix.matrix_type] [hud_name] HUD"
	if(matrix.overlay)
		overlay = matrix.overlay
	if(matrix.vision_flags)
		vision_flags = matrix.vision_flags
	if(matrix.see_invisible)
		see_invisible = matrix.see_invisible
	if(matrix.darkness_view)
		darkness_view = matrix.darkness_view
	if(!one_eyed)
		flash_protection = between(FLASH_PROTECTION_VULNERABLE, cumulative_flash_protection, FLASH_PROTECTION_MAJOR)
	sec_hud = matrix.sec_hud
	med_hud = matrix.med_hud
	hud_type = matrix.hud_type
	if(matrix.matrix_icon)
		update_icon()
		item_state = "[hud_icon]_[matrix.matrix_icon]"

/obj/item/clothing/glasses/hud/proc/deactivate_matrix()
	if(!matrix)
		return
	active = FALSE
	name = "[hud_name] HUD"
	overlay = null
	vision_flags = initial(vision_flags)
	see_invisible = initial(see_invisible)
	darkness_view = initial(darkness_view)
	if(!one_eyed)
		flash_protection = between(FLASH_PROTECTION_VULNERABLE, cumulative_flash_protection - matrix.flash_protection, FLASH_PROTECTION_MAJOR)
	sec_hud = FALSE
	med_hud = FALSE
	hud_type = null
	update_icon()
	item_state = "hud_[hud_icon]"

/obj/item/clothing/glasses/hud/proc/toggle_matrix(mob/user)
	if(!matrix)
		to_chat(user, "\The [src] has no optical matrix installed.")
		return
	if(!active)
		activate_matrix()
		to_chat(user, "You activate the optical matrix on \the [src].")
		sound_to(user, sound(activation_sound, volume = 50))
	else
		deactivate_matrix()
		to_chat(user, "You deactivate the optical matrix on \the [src].")
		sound_to(user, sound(deactivation_sound, volume = 50))
	update_clothing_icon()
	user.update_action_buttons()

/obj/item/clothing/glasses/hud/standard
	name = "goggles HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	icon_state = "hud_standard"
	item_state = "hud_standard"
	hud_name = "goggles"
	hud_icon = "standard"

/obj/item/clothing/glasses/hud/dual
	name = "dual HUD"
	desc = "Old-fashioned heads-up display glasses."
	icon_state = "hud_standard"
	item_state = "hud_standard"
	hud_name = "dual"
	hud_icon = "dual"

/obj/item/clothing/glasses/hud/monoglass
	name = "clear HUD"
	desc = "Big and rimless HUD mono glasses."
	icon_state = "hud_monoglass"
	item_state = "hud_monoglass"
	hud_name = "clear"
	hud_icon = "monoglass"

/obj/item/clothing/glasses/hud/scanners
	name = "goggles HUD"
	desc = "Heavy and oddly shaped pair of HUD goggles."
	icon_state = "hud_scanners"
	item_state = "hud_scanners"
	hud_name = "goggles"
	hud_icon = "scanners"

/obj/item/clothing/glasses/hud/glasses
	name = "glasses HUD"
	desc = "HUD designed to look like a totally normal pair of glasses."
	icon_state = "hud_glasses"
	item_state = "hud_glasses"
	hud_name = "glasses"
	hud_icon = "glasses"

/obj/item/clothing/glasses/hud/aviators
	name = "aviators HUD"
	desc = "A pair of HUD aviators."
	icon_state = "hud_aviators"
	item_state = "hud_aviators"
	hud_name = "aviators"
	hud_icon = "aviators"

/obj/item/clothing/glasses/hud/visor
	name = "visor HUD"
	desc = "A rather retrofuturistic visor with an inbuilt HUD."
	icon_state = "hud_visor"
	item_state = "hud_visor"
	hud_name = "visor"
	hud_icon = "visor"

/obj/item/clothing/glasses/hud/shades
	name = "clip-on HUD"
	desc = "A weird pair of HUD glasses. Perhaps, you've never asked for these."
	icon_state = "hud_shades"
	item_state = "hud_shades"
	hud_name = "clip-on"
	hud_icon = "shades"

/obj/item/clothing/glasses/hud/one_eyed
	one_eyed = TRUE
	body_parts_covered = 0 // Covering one eye isn't enough to protect you from eye-forking
	var/flipped = FALSE // Indicates left or right eye; FALSE = on the left

/obj/item/clothing/glasses/hud/one_eyed/verb/flip_patch()
	set name = "Flip HUD"
	set category = "Object"
	set src in usr

	if(usr.stat || usr.restrained())
		return

	flipped = !flipped
	if(flipped)
		hud_icon = "[initial(hud_icon)]_r"
	else
		hud_icon = "[initial(hud_icon)]"
	icon_state = "hud_[hud_icon]"
	if(active)
		item_state = "[hud_icon]_[matrix.matrix_icon]"
	else
		item_state = "hud_[hud_icon]"
	to_chat(usr, "You flip \the [src] to cover the [src.flipped ? "left" : "right"] eye.")
	update_icon()
	update_clothing_icon()

/obj/item/clothing/glasses/hud/one_eyed/oneye
	name = "over-eye HUD"
	desc = "A small over-eye screen with an inbuilt HUD."
	icon_state = "hud_oneye"
	item_state = "hud_oneye"
	hud_name = "over-eye"
	hud_icon = "oneye"

/obj/item/clothing/glasses/hud/one_eyed/patch
	name = "patch HUD"
	desc = "A heads-up display that connects directly to the optical nerve of the user, replacing the need for that useless eyeball."
	icon_state = "hud_patch"
	item_state = "hud_patch"
	hud_name = "patch"
	hud_icon = "patch"

/obj/item/clothing/glasses/hud/plain
	active = TRUE
	matrix_removable = FALSE
	action_button_name = null

/obj/item/clothing/glasses/hud/plain/Initialize()
	. = ..()
	icon_state = initial(icon_state)
	item_state = initial(item_state)

/obj/item/clothing/glasses/hud/plain/attack_self(mob/user)
	return

/obj/item/clothing/glasses/hud/plain/update_icon()
	return

/obj/item/clothing/glasses/hud/psychoscope
	name = "psychoscope"
	desc = "An old experimental glasses with a strange design."
	icon_state = "psychoscope_off"
	item_state = "psychoscope_off"
	hud_name = "psychoscope"
	activation_sound = 'sound/effects/psychoscope/psychoscope_on.ogg'
	w_class = ITEM_SIZE_NORMAL
	deactivation_sound = null
	matrix = /obj/item/device/hudmatrix/science
	matrix_removable = FALSE
	use_alt_layer = TRUE

/obj/item/clothing/glasses/hud/psychoscope/update_icon()
	if(active)
		icon_state = "psychoscope_on"
		item_state = "psychoscope_on"
	else
		icon_state = "psychoscope_off"
		item_state = "psychoscope_off"

/obj/item/clothing/glasses/hud/psychoscope/Initialize()
	. = ..()
	
	icon_state = "psychoscope_off"
	item_state = "psychoscope_off"

/obj/item/clothing/glasses/hud/psychoscope/activate_matrix()
	. = ..()
	
	update_icon()

/obj/item/clothing/glasses/hud/psychoscope/deactivate_matrix()
	. = ..()
	
	update_icon()
