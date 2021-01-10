
// Standard old-school presets
/obj/item/clothing/glasses/hud/standard/material
	name = "material goggles HUD"
	matrix = /obj/item/device/hudmatrix/material

/obj/item/clothing/glasses/hud/standard/material/active
	active = 1

/obj/item/clothing/glasses/hud/standard/meson
	name = "meson goggles HUD"
	matrix = /obj/item/device/hudmatrix/meson

/obj/item/clothing/glasses/hud/standard/meson/active
	active = 1

/obj/item/clothing/glasses/hud/aviators/security
	name = "security aviators HUD"
	matrix = /obj/item/device/hudmatrix/security

/obj/item/clothing/glasses/hud/aviators/security/active
	active = 1

/obj/item/clothing/glasses/hud/standard/thermal
	name = "thermal goggles HUD"
	matrix = /obj/item/device/hudmatrix/thermal

/obj/item/clothing/glasses/hud/standard/thermal/active
	active = 1

/obj/item/clothing/glasses/hud/one_eyed/oneye/medical
	name = "medical over-eye HUD"
	matrix = /obj/item/device/hudmatrix/medical

/obj/item/clothing/glasses/hud/one_eyed/oneye/medical/active
	active = 1

/obj/item/clothing/glasses/hud/standard/science
	name = "science goggles HUD"
	matrix = /obj/item/device/hudmatrix/science

/obj/item/clothing/glasses/hud/standard/science/active
	active = 1

/obj/item/clothing/glasses/hud/scanners/night
	name = "night vision goggles HUD"
	matrix = /obj/item/device/hudmatrix/night

/obj/item/clothing/glasses/hud/scanners/night/active
	active = 1


// Misc
/obj/item/clothing/glasses/hud/one_eyed/patch/thermal
	name = "thermal patch HUD"
	matrix = /obj/item/device/hudmatrix/thermal

/obj/item/clothing/glasses/hud/shades/thermal
	name = "thermal clip-on HUD"
	matrix = /obj/item/device/hudmatrix/thermal

/obj/item/clothing/glasses/hud/shades/thermal/sunshield
	lenses = /obj/item/device/hudlenses/sunshield

/obj/item/clothing/glasses/hud/standard/thermal/syndie
	name = "meson goggles HUD"
	matrix = /obj/item/device/hudmatrix/thermal/syndie

/obj/item/clothing/glasses/hud/standard/medical
	name = "medical goggles HUD"
	matrix = /obj/item/device/hudmatrix/medical

/obj/item/clothing/glasses/hud/standard/medical/active
	active = 1

/obj/item/clothing/glasses/hud/standard/security
	name = "security goggles HUD"
	matrix = /obj/item/device/hudmatrix/security

/obj/item/clothing/glasses/hud/standard/security/active
	active = 1

/obj/item/clothing/glasses/hud/standard/night
	name = "night vision goggles HUD"
	matrix = /obj/item/device/hudmatrix/night

/obj/item/clothing/glasses/hud/standard/night/active
	active = 1

// HUDs with non-removable matrices
/obj/item/clothing/glasses/hud/plain/jensenshades
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	gender = PLURAL
	icon_state = "jensenshades"
	item_state = "jensenshades"
	vision_flags = SEE_MOBS
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	matrix = /obj/item/device/hudmatrix/security

/obj/item/clothing/glasses/hud/plain/thermal/monocle
	name = "thermoncle"
	desc = "A monocle thermal."
	icon_state = "thermoncle"
	item_state = "thermoncle"
	matrix = /obj/item/device/hudmatrix/thermal
	body_parts_covered = 0 //doesn't protect eyes because it's a monocle, duh

/obj/item/clothing/glasses/hud/plain/thermal/jensen
	name = "optical thermal implants"
	gender = PLURAL
	desc = "A set of implantable lenses designed to augment your vision."
	icon_state = "thermalimplants"
	item_state = "thermalimplants"
	item_state_slots = list(
		slot_l_hand_str = "syringe_kit",
		slot_r_hand_str = "syringe_kit"
		)
	matrix = /obj/item/device/hudmatrix/thermal
	body_parts_covered = 0 //don't protect eyes because, well, contacts
