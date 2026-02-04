/obj/item/organ_module/active/simple/drill
	name = "integrated drill"
	desc = "Miner specialized, can help you with free space on mining journey."
	icon_state = "augment-tool"
	action_button_name = "Deploy drill"
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	holding_type = /obj/item/pickaxe/drill
	available_in_charsetup = TRUE
	w_class = 3
	cpu_load = 1
	augment_cost = 3
	origin_tech = list(TECH_ENGINEERING = 3, TECH_MATERIAL = 2, TECH_BIO = 2)
	matter = list(
		MATERIAL_STEEL = 8000,
		MATERIAL_PLASTIC = 2000,
		MATERIAL_PLASTEEL = 1000
	)
	allowed_roles = list(/datum/job/mining)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_MECHANICAL

/obj/item/organ_module/active/simple/drill/emp_act(severity)
	. = ..()

	var/obj/item/organ/external/E = loc
	var/mob/living/carbon/human/H = E?.owner
	if(!istype(E) || !istype(H))
		return

	var/chance = 10 * (4 - severity)
	if(!prob(chance))
		return

	H.visible_message(
		SPAN_WARNING("[H]'s integrated drill spins out of control inside \his hand!"),
		SPAN_DANGER("Your integrated drill spins out of control inside your hand!")
	)
	H.apply_damage(rand(8, 16), BRUTE, E.organ_tag)
