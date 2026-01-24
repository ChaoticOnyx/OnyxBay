/obj/item/organ_module/active/translator
	name = "universal translator"
	desc = "NanoTrasen designed. Translates to you other races and some human languages."
	/// List of languages that the augment can translate.
	var/list/languages = list(
		LANGUAGE_GALCOM,
		LANGUAGE_SOL_COMMON,
		LANGUAGE_GUTTER,
		LANGUAGE_INDEPENDENT,
		LANGUAGE_SPACER,
		LANGUAGE_UNATHI,
		LANGUAGE_SKRELLIAN,
		LANGUAGE_SIIK_MAAS
	)
	icon_state = "cranial_aug"
	action_button_name = "Toggle translator"
	allowed_organs = list(BP_HEAD)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	loadout_cost = 0
	available_in_charsetup = TRUE
	augment_cost = 3
	cpu_load = 1
	w_class = 1
	origin_tech = list(TECH_BIO = 4, TECH_DATA = 3)

/obj/item/organ_module/active/translator/activate(obj/item/organ/E, mob/living/carbon/human/H)
	toggled = !toggled
	if(toggled)
		to_chat(H, SPAN_NOTICE("Your translator hums to life."))
	else
		to_chat(H, SPAN_NOTICE("Your translator powers down."))

/obj/item/organ_module/active/translator/deactivate(obj/item/organ/E, mob/living/carbon/human/H)
	toggled = FALSE

/obj/item/organ_module/active/translator/is_cpu_active(mob/living/carbon/human/H)
	return toggled
