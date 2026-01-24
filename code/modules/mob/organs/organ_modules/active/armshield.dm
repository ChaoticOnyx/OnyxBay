/obj/item/organ_module/active/simple/armshield
	name = "embedded shield"
	desc = "An embedded shield designed to be inserted into an arm."
	action_button_name = "Deploy embedded shield"
	icon_state = "armshield"
	matter = list(
		MATERIAL_DURANIUM = 2000,
		MATERIAL_GOLD = 5000,
		MATERIAL_DIAMOND = 2000
	)
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	holding_type = /obj/item/shield/energy
	available_in_charsetup = FALSE
	w_class = 3
	cpu_load = 2
	origin_tech = list(TECH_COMBAT = 9, TECH_ILLEGAL = 5)

/obj/item/organ_module/active/simple/armshield/emp_act(severity)
	. = ..()

	var/obj/item/organ/external/E = loc
	var/mob/living/carbon/human/H = E?.owner
	if(!istype(E) || !istype(H))
		return

	var/chance = 10 * (4 - severity)
	if(!prob(chance))
		return

	H.visible_message(
		SPAN_DANGER("[H]'s embedded shield snaps open violently, tearing the arm off!"),
		SPAN_DANGER("Your embedded shield snaps open violently, tearing your arm off!")
	)
	E.droplimb(FALSE, DROPLIMB_EDGE)

/obj/item/organ_module/active/simple/armshield/activate(obj/item/organ/external/E, mob/living/carbon/human/H)
	if(!can_activate(E, H))
		return
	if(holding && holding.loc != src)
		var/obj/item/shield/energy/S = holding
		if(istype(S) && S.active)
			to_chat(H, SPAN_WARNING("Your [S.name] is active and cannot be retracted."))
			return
		retract(H, E)
		return
	deploy(H, E)
