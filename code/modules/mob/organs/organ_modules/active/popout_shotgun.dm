/obj/item/organ_module/active/simple/shotgun
	name = "pop-out shotgun"
	desc = "A galvanized steel mechanism that replaces most of the flesh below the elbow. Using the arm's natural range of motion as a hinge, it can be flicked open to reveal a 12-gauge shotgun with room for a single shell."
	action_button_name = "Deploy shotgun"
	icon_state = "popout_shotgun"
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	holding_type = /obj/item/gun/projectile/shotgun/popout
	origin_tech = list(TECH_MATERIAL = 3, TECH_COMBAT = 3)
	module_flags = OM_FLAG_DEFAULT
	available_in_charsetup = TRUE

/obj/item/organ_module/active/simple/shotgun/emp_act(severity)
	. = ..()

	var/obj/item/organ/external/E = loc
	var/mob/living/carbon/human/H = E?.owner
	if(!istype(E) || !istype(H))
		return

	var/chance = 10 * (4 - severity)
	if(!prob(chance))
		return

	if(QDELETED(holding) && holding_type)
		holding = new holding_type(src)
		holding.canremove = FALSE
	if(!holding || !istype(holding, /obj/item/gun/projectile))
		return

	var/obj/item/gun/projectile/G = holding
	if(!G.chambered && (!islist(G.loaded) || !G.loaded.len))
		return

	H.visible_message(
		SPAN_WARNING("[H]'s pop-out shotgun fires inside \his arm!"),
		SPAN_DANGER("Your pop-out shotgun fires inside your arm!")
	)
	G.Fire(H, H, pointblank = TRUE, target_zone = E.organ_tag)

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
	has_safety = FALSE // fuck naw
	unacidable = TRUE
