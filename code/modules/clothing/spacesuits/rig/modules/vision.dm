/*
 * Contains
 * /obj/item/rig_module/vision
 * /obj/item/rig_module/vision/multi
 * /obj/item/rig_module/vision/meson
 * /obj/item/rig_module/vision/thermal
 * /obj/item/rig_module/vision/nvg
 * /obj/item/rig_module/vision/medhud
 * /obj/item/rig_module/vision/sechud
 */

/datum/rig_vision
	var/mode
	var/obj/item/clothing/glasses/glasses

/datum/rig_vision/New()
	if(ispath(glasses))
		glasses = new glasses

/datum/rig_vision/Destroy()
	..()
	QDEL_NULL(glasses)

/datum/rig_vision/nvg
	mode = "night vision"
	glasses = /obj/item/clothing/glasses/hud/standard/night/active

/datum/rig_vision/thermal
	mode = "thermal scanner"
	glasses = /obj/item/clothing/glasses/hud/standard/thermal/active

/datum/rig_vision/meson
	mode = "meson scanner"
	glasses = /obj/item/clothing/glasses/hud/standard/meson/active

/datum/rig_vision/sechud
	mode = "security HUD"
	glasses = /obj/item/clothing/glasses/hud/standard/security/active

/datum/rig_vision/medhud
	mode = "medical HUD"
	glasses = /obj/item/clothing/glasses/hud/standard/medical/active

/obj/item/rig_module/vision

	name = "powersuit visor"
	desc = "A layered, translucent visor system for a powersuit."
	icon_state = "hud_multi"

	interface_name = "optical scanners"
	interface_desc = "An integrated multi-mode vision system."

	usable = 1
	toggleable = 1
	disruptive = 0
	module_cooldown = 0
	active_power_cost = 100

	engage_string = "Cycle Visor Mode"
	activate_string = "Enable Visor"
	deactivate_string = "Disable Visor"

	var/datum/rig_vision/vision
	var/list/vision_modes = list(
		/datum/rig_vision/nvg,
		/datum/rig_vision/thermal,
		/datum/rig_vision/meson
		)

	var/vision_index

/obj/item/rig_module/vision/multi

	name = "powersuit optical package"
	desc = "A complete visor system of optical scanners and vision modes."
	icon_state = "hud_full"


	interface_name = "multi optical visor"
	interface_desc = "An integrated multi-mode vision system."

	vision_modes = list(/datum/rig_vision/meson,
						/datum/rig_vision/nvg,
						/datum/rig_vision/thermal,
						/datum/rig_vision/sechud,
						/datum/rig_vision/medhud)

/obj/item/rig_module/vision/meson

	name = "powersuit meson matrix"
	desc = "A layered, translucent visor system for a powersuit."
	icon_state = "hud_meson"
	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 5)
	usable = 0

	interface_name = "meson HUD"
	interface_desc = "An integrated meson heads up display."

	vision_modes = list(/datum/rig_vision/meson)

/obj/item/rig_module/vision/thermal

	name = "powersuit thermal matrix"
	desc = "A layered, translucent visor system for a powersuit."
	icon_state = "hud_thermal"

	usable = 0

	interface_name = "thermal HUD"
	interface_desc = "An integrated thermal heads up display."

	vision_modes = list(/datum/rig_vision/thermal)

/obj/item/rig_module/vision/nvg

	name = "powersuit night vision matrix"
	desc = "A multi input night vision system for a powersuit."
	icon_state = "hud_night"
	origin_tech = list(TECH_MAGNET = 6, TECH_ENGINEERING = 6)
	usable = 0

	interface_name = "night vision HUD"
	interface_desc = "An integrated night vision heads up display."

	vision_modes = list(/datum/rig_vision/nvg)

/obj/item/rig_module/vision/sechud

	name = "powersuit security matrix"
	desc = "A simple tactical information system for a powersuit."
	icon_state = "hud_sec"
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 2, TECH_ENGINEERING = 5)
	usable = 0

	interface_name = "security HUD"
	interface_desc = "An integrated security heads up display."

	vision_modes = list(/datum/rig_vision/sechud)

/obj/item/rig_module/vision/medhud

	name = "powersuit medical matrix"
	desc = "A simple medical status indicator for a powersuit."
	icon_state = "hud_medical"
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 2, TECH_ENGINEERING = 5)
	usable = 0

	interface_name = "medical HUD"
	interface_desc = "An integrated medical heads up display."

	vision_modes = list(/datum/rig_vision/medhud)


// There should only ever be one vision module installed in a suit.
/obj/item/rig_module/vision/installed()
	..()
	holder.visor = src

/obj/item/rig_module/vision/engage()

	var/starting_up = !active

	if(!..() || !vision_modes)
		return 0

	// Don't cycle if this engage() is being called by activate().
	if(starting_up)
		to_chat(holder.wearer, "<span class='info'>You activate your visual sensors.</span>")
		return 1

	if(vision_modes.len > 1)
		vision_index++
		if(vision_index > vision_modes.len)
			vision_index = 1
		vision = vision_modes[vision_index]

		to_chat(holder.wearer, "<span class='info'>You cycle your sensors to <b>[vision.mode]</b> mode.</span>")
	else
		to_chat(holder.wearer, "<span class='info'>Your sensors only have one mode.</span>")
	return 1

/obj/item/rig_module/vision/Initialize()
	. = ..()

	if(!vision_modes)
		return

	vision_index = 1
	var/list/processed_vision = list()

	for(var/vision_mode in vision_modes)
		var/datum/rig_vision/vision_datum = new vision_mode
		if(!vision)
			vision = vision_datum
		processed_vision += vision_datum

	vision_modes = processed_vision

/obj/item/rig_module/vision/Destroy()
	QDEL_LIST(vision_modes)
	. = ..()
