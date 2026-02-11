/obj/item/organ_module/active/simple/surgical
	name = "embedded incision manager"
	desc = "An embedded incision manager."
	action_button_name = "Deploy embedded incision manager"
	icon_state = "multitool_medical"
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	holding_type = /obj/item/scalpel/manager
	loadout_cost = 0
	allowed_roles = list(/datum/job/cmo)
	augment_cost = 6
	cpu_load = 2
	w_class = 2
	available_in_charsetup = TRUE
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_MECHANICAL

/obj/item/organ_module/active/multitool/surgical
	name = "surgical multitool module"
	desc = "An augment designed to hold multiple surgical instruments."
	verb_name = "Deploy Surgical Tool"
	icon_state = "multitool_medical"
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	augment_cost = 3
	cpu_load = 1
	w_class = 3
	available_in_charsetup = TRUE
	allowed_roles = list(/datum/job/cmo, /datum/job/doctor)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_MECHANICAL
	items = list(
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/circular_saw/plasmasaw,
		/obj/item/hemostat/pico,
		/obj/item/retractor,
		/obj/item/scalpel/laser3,
		/obj/item/surgicaldrill,
		/obj/item/bonegel,
		/obj/item/FixOVein/clot,
		/obj/item/organfixer/advanced,
	)

/obj/item/organ_module/active/multitool/surgical/emp_act(severity)
	. = ..()

	var/obj/item/organ/external/E = loc
	var/mob/living/carbon/human/H = E?.owner
	if(!istype(E) || !istype(H))
		return

	var/chance = 10 * (4 - severity)
	if(!prob(chance))
		return

	H.visible_message(
		SPAN_WARNING("[H]'s surgical saw jerks and bites inside \his hand!"),
		SPAN_DANGER("Your surgical saw jerks and bites inside your hand!")
	)
	H.apply_damage(rand(6, 12), BRUTE, E.organ_tag)
