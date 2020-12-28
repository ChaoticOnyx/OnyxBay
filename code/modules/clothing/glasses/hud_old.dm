/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 2)
	var/list/icon/current = list() //the current hud icons
	electric = 1
	gender = NEUTER

/obj/item/clothing/glasses/proc/process_hud(mob/M)
	if(hud)
		hud.process_hud(M)

/obj/item/clothing/glasses/hud/process_hud(mob/M)
	return

/obj/item/clothing/glasses/hud/health
	name = "health scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	hud_type = HUD_MEDICAL
	body_parts_covered = 0

/obj/item/clothing/glasses/hud/health/process_hud(mob/M)
	process_med_hud(M, 1)

/obj/item/clothing/glasses/hud/health/prescription
	name = "prescription health scanner HUD"
	desc = "A medical HUD integrated with a set of prescription glasses."
	prescription = 7
	icon_state = "healthhudpresc"
	item_state = "glasses"

/obj/item/clothing/glasses/hud/health/visor
	name = "medical HUD visor"
	desc = "A medical HUD integrated with a wide visor."
	icon_state = "medhud_visor"
	item_state = "medhud_visor"

/obj/item/clothing/glasses/hud/security
	name = "security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	hud_type = HUD_SECURITY
	body_parts_covered = 0
	var/global/list/jobs[0]

/obj/item/clothing/glasses/hud/security/prescription
	name = "prescription security HUD"
	desc = "A security HUD integrated with a set of prescription glasses"
	prescription = 7
	icon_state = "sechudpresc"
	item_state = "glasses"

/obj/item/clothing/glasses/hud/security/process_hud(mob/M)
	process_sec_hud(M, 1)

/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "Goggles fitted with a portable analyzer capable of determining the fabricator training potential of an item or components of a machine. Sensitive to EMP."
	icon_state = "purple"
	item_state = "glasses"
	action_button_name = "Toggle Goggles"
	hud_type = HUD_SCIENCE
	toggleable = TRUE
	electric = TRUE

/obj/item/clothing/glasses/science/Initialize()
	. = ..()
	overlay = GLOB.global_hud.science

/obj/item/clothing/glasses/science/attack_self(mob/user)
	..()
	if(active)
		hud_type = HUD_SCIENCE
	else
		hud_type = null

/obj/item/clothing/glasses/meson
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	gender = NEUTER
	icon_state = "meson"
	item_state = "glasses"
	action_button_name = "Toggle Goggles"
	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 2)
	toggleable = TRUE
	vision_flags = SEE_TURFS
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	electric = TRUE

/obj/item/clothing/glasses/meson/Initialize()
	. = ..()
	overlay = GLOB.global_hud.meson

/obj/item/clothing/glasses/meson/prescription
	name = "prescription mesons"
	desc = "Optical Meson Scanner with prescription lenses."
	prescription = 6

/obj/item/clothing/glasses/night
	name = "night vision goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	item_state = "glasses"
	origin_tech = list(TECH_MAGNET = 2)
	darkness_view = 7
	action_button_name = "Toggle Goggles"
	toggleable = TRUE
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	off_state = "denight"
	electric = TRUE

/obj/item/clothing/glasses/night/Initialize()
	. = ..()
	overlay = GLOB.global_hud.nvg

/obj/item/clothing/glasses/sunglasses/sechud
	name = "HUD sunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	hud = /obj/item/clothing/glasses/hud/security
	electric = TRUE
	darktinted = 0

/obj/item/clothing/glasses/sunglasses/sechud/goggles //now just a more "military" set of HUDglasses for the Torch
	name = "HUD goggles"
	desc = "Flash-resistant goggles with an inbuilt heads-up display."
	icon_state = "goggles"

/obj/item/clothing/glasses/sunglasses/sechud/toggle
	name = "HUD aviators"
	desc = "Modified aviator glasses that can be switched between HUD and flash protection modes."
	icon_state = "sec_hud"
	off_state = "sec_flash"
	action_button_name = "Toggle Mode"
	var/on = TRUE
	toggleable = TRUE
	activation_sound = 'sound/effects/pop.ogg'

	var/hud_holder

/obj/item/clothing/glasses/sunglasses/sechud/toggle/Initialize()
	. = ..()
	hud_holder = hud

/obj/item/clothing/glasses/sunglasses/sechud/toggle/Destroy()
	qdel(hud_holder)
	hud_holder = null
	hud = null
	. = ..()

/obj/item/clothing/glasses/sunglasses/sechud/toggle/attack_self(mob/user)
	if(toggleable && !user.incapacitated())
		on = !on
		if(on)
			flash_protection = FLASH_PROTECTION_NONE
			src.hud = hud_holder
			to_chat(user, "You switch \the [src] to HUD mode.")
		else
			flash_protection = initial(flash_protection)
			src.hud = null
			to_chat(user, "You switch \the [src] to flash protection mode.")
		update_icon()
		sound_to(user, activation_sound)
		user.update_inv_glasses()
		user.update_action_buttons()

/obj/item/clothing/glasses/sunglasses/sechud/toggle/update_icon()
	if(on)
		icon_state = initial(icon_state)
	else
		icon_state = off_state



/obj/item/clothing/glasses/eyepatch/hud
	name = "iPatch"
	desc = "For the technologically inclined pirate. It connects directly to the optical nerve of the user, replacing the need for that useless eyeball."
	gender = NEUTER
	icon_state = "hudpatch"
	item_state = "hudpatch"
	off_state = "hudpatch"
	action_button_name = "Toggle iPatch"
	toggleable = TRUE
	var/eye_color = COLOR_WHITE
	electric = TRUE

/obj/item/clothing/glasses/eyepatch/hud/Initialize()
	.  = ..()
	update_icon()

/obj/item/clothing/glasses/eyepatch/hud/attack_self()
	..()
	update_icon()

/obj/item/clothing/glasses/eyepatch/hud/update_icon()
	overlays.Cut()
	if(active)
		var/image/eye = overlay_image(icon, "[icon_state]_eye", flags=RESET_COLOR)
		eye.color = eye_color
		overlays += eye

/obj/item/clothing/glasses/eyepatch/hud/get_mob_overlay(mob/user_mob, slot)
	var/image/res = ..()
	if(active)
		var/image/eye = overlay_image(res.icon, "[icon_state]_eye", flags=RESET_COLOR)
		eye.color = eye_color
		eye.layer = ABOVE_LIGHTING_LAYER
		eye.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		res.overlays += eye
	return res

/obj/item/clothing/glasses/eyepatch/hud/security
	name = "HUDpatch"
	desc = "A Security-type heads-up display that connects directly to the optical nerve of the user, replacing the need for that useless eyeball."
	hud = /obj/item/clothing/glasses/hud/security
	eye_color = COLOR_RED

/obj/item/clothing/glasses/eyepatch/hud/medical
	name = "MEDpatch"
	desc = "A Medical-type heads-up display that connects directly to the ocular nerve of the user, replacing the need for that useless eyeball."
	hud = /obj/item/clothing/glasses/hud/health
	eye_color = COLOR_CYAN

/obj/item/clothing/glasses/eyepatch/hud/meson
	name = "MESpatch"
	desc = "An optical meson scanner display that connects directly to the ocular nerve of the user, replacing the need for that useless eyeball."
	vision_flags = SEE_TURFS
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	eye_color = COLOR_LIME

/obj/item/clothing/glasses/eyepatch/hud/meson/Initialize()
	. = ..()
	overlay = GLOB.global_hud.meson

/obj/item/clothing/glasses/material
	name = "optical material scanner"
	desc = "Very confusing glasses."
	gender = NEUTER
	icon_state = "material"
	item_state = "glasses"
	origin_tech = list(TECH_MAGNET = 3, TECH_ENGINEERING = 3)
	action_button_name = "Toggle Goggles"
	toggleable = TRUE
	vision_flags = SEE_OBJS
	electric = TRUE

/obj/item/clothing/glasses/material/Initialize()
	. = ..()
	overlay = GLOB.global_hud.material


