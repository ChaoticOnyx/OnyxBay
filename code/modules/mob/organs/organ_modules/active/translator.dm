/obj/item/organ_module/active/translator
	name = "universal translator"
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
	allowed_organs = list(BP_HEAD)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	loadout_cost = 8
