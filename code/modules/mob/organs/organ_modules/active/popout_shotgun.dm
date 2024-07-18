/obj/item/organ_module/active/simple/shotgun
	name = "pop-out shotgun"
	desc = "A galvanized steel mechanism that replaces most of the flesh below the elbow. Using the arm's natural range of motion as a hinge, it can be flicked open to reveal a 12-gauge shotgun with room for a single shell."
	action_button_name = "Deploy shotgun"
	icon_state = "popout_shotgun"
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	holding_type = /obj/item/gun/projectile/shotgun/popout
	origin_tech = list(TECH_MATERIAL = 3, TECH_COMBAT = 3)
	module_flags = OM_FLAG_DEFAULT
	available_in_charsetup = FALSE

/obj/item/gun/projectile/shotgun/popout
	name = "pop-out shotgun"
	desc = "A specialized 12-gauge shotgun concealed in the forearm. A deadly surprise."
	icon = 'icons/obj/implants.dmi'
	icon_state = "popout_shotgun"
	item_state = "coilgun"
	max_shells = 1
	w_class = ITEM_SIZE_HUGE
	force = 5
	obj_flags =  OBJ_FLAG_CONDUCTIBLE
	caliber = "12g"
	load_method = 1 // SINGLE CASING
	ammo_type = /obj/item/ammo_casing/shotgun/pellet
	handle_casings = 2 // EJECT
	has_safety = FALSE // No brakes on this train baby
	unacidable = TRUE
