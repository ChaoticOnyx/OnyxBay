/obj/item/organ_module/active/simple/surgical
	name = "embedded surgical multitool"
	desc = "An embedded incision manager."
	verb_name = "Deploy embedded incision manager"
	icon_state = "multitool"
	allowed_organs = list(BP_R_ARM, BP_L_ARM)
	holding_type = /obj/item/scalpel/manager

/obj/item/organ_module/active/multitool/surgical
	name = "surgical multitool module"
	desc = "An augment designed to hold multiple surgical instruments."
	verb_name = "Deploy Surgical Tool"
	icon_state = "multitool"
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
