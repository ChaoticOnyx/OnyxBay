/obj/item/organ_module/active/simple/surgical
	name = "embedded incision manager"
	desc = "An embedded incision manager."
	action_button_name = "Deploy embedded incision manager"
	icon_state = "multitool_medical"
	allowed_organs = list(BP_L_HAND, BP_R_HAND)
	holding_type = /obj/item/scalpel/manager
	loadout_cost = 10
	allowed_jobs = list(/datum/job/cmo, /datum/job/doctor, /datum/job/psychiatrist, /datum/job/chemist, /datum/job/paramedic)

/obj/item/organ_module/active/multitool/surgical
	name = "surgical multitool module"
	desc = "An augment designed to hold multiple surgical instruments."
	verb_name = "Deploy Surgical Tool"
	icon_state = "multitool_medical"
	items = list(
		/obj/item/bonesetter/bone_mender,
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
