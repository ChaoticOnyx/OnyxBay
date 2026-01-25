/obj/item/organ_module/active/simple/shotgun
	name = "pop-out shotgun"
	desc = "A galvanized steel mechanism that replaces most of the flesh below the elbow. Using the arm's natural range of motion as a hinge, it can be flicked open to reveal a 12-gauge shotgun with room for a single shell."
	action_button_name = "Deploy shotgun"
	icon_state = "popout_shotgun"
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	holding_type = /obj/item/gun/projectile/shotgun/popout
	origin_tech = list(TECH_COMBAT = 8, TECH_ILLEGAL = 6, TECH_BIO = 5, TECH_MATERIAL = 4)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_MECHANICAL
	available_in_charsetup = FALSE
	cpu_load = 1
	w_class = 3
	matter = list(
		MATERIAL_DURANIUM = 1000,
		MATERIAL_PLASTEEL = 2000,
		MATERIAL_SILVER = 500,
		MATERIAL_GOLD = 500
	)

/obj/item/organ_module/active/simple/shotgun/emp_act(severity)
	. = ..()

	var/obj/item/organ/external/E = loc
	var/mob/living/carbon/human/H = E?.owner
	if(!istype(E) || !istype(H))
		return

	var/chance = 10 * (4 - severity)
	if(!prob(chance))
		return

	var/obj/item/gun/projectile/G = get_shotgun()
	if(!G || !has_ammo(G))
		return

	H.visible_message(
		SPAN_WARNING("[H]'s pop-out shotgun fires inside \his arm!"),
		SPAN_DANGER("Your pop-out shotgun fires inside your arm!")
	)
	G.Fire(H, H, pointblank = TRUE, target_zone = E.organ_tag)

/obj/item/organ_module/active/simple/shotgun/proc/get_shotgun()
	if(QDELETED(holding))
		holding = null
	if(!holding && holding_type)
		holding = new holding_type(src)
		holding.canremove = FALSE
	if(istype(holding, /obj/item/gun/projectile))
		return holding
	return null

/obj/item/organ_module/active/simple/shotgun/proc/has_ammo(obj/item/gun/projectile/G)
	return G.chambered || (islist(G.loaded) && G.loaded.len)

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
