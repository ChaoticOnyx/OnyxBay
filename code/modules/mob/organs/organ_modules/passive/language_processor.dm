/obj/item/organ_module/language
	name = "language processor"
	desc = "An augment installed into the head that interfaces with the user's neural interface, " \
		+ "intercepting and assisting language faculties."
	allowed_organs = list(BP_HEAD)
	icon_state = "cranial_aug"
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	loadout_cost = 0
	/// A list of languages that this augment will add. add your language to this
	var/list/augment_languages = list(
		LANGUAGE_GALCOM,
		LANGUAGE_SOL_COMMON,
		LANGUAGE_GUTTER,
		LANGUAGE_INDEPENDENT,
		LANGUAGE_SPACER,
		LANGUAGE_UNATHI,
		LANGUAGE_SKRELLIAN,
		LANGUAGE_SIIK_MAAS
	)
	/// A list of languages that get added when it's installed. used to remove languages later. don't touch this.
	var/list/added_languages = list()
	/// A list of language-related verbs granted by the augment.
	var/list/granted_verbs = list()

/obj/item/organ_module/language/post_install(obj/item/organ/E)
	. = ..()
	var/mob/living/carbon/human/H = E?.owner
	if(istype(H))
		add_languages(H)

/obj/item/organ_module/language/post_removed(obj/item/organ/E)
	. = ..()
	var/mob/living/carbon/human/H = E?.owner
	if(istype(H))
		remove_languages(H)

/obj/item/organ_module/language/organ_installed()
	. = ..()
	var/obj/item/organ/O = loc
	var/mob/living/carbon/human/H = O?.owner
	if(istype(H))
		add_languages(H)

/obj/item/organ_module/language/organ_removed()
	. = ..()
	var/obj/item/organ/O = loc
	var/mob/living/carbon/human/H = O?.owner
	if(istype(H))
		remove_languages(H)

/obj/item/organ_module/language/proc/add_languages(mob/living/carbon/human/H)
	LAZYINITLIST(H.speak_only_languages)
	for(var/language in augment_languages)
		var/datum/language/L = all_languages[language]
		if(!L)
			continue
		if(!(L in H.speak_only_languages))
			H.speak_only_languages += L
			added_languages += L
	for(var/verb_path in granted_verbs)
		H.add_verb(verb_path)

/obj/item/organ_module/language/proc/remove_languages(mob/living/carbon/human/H)
	if(!H)
		return
	LAZYINITLIST(H.speak_only_languages)
	for(var/datum/language/L in added_languages)
		H.speak_only_languages -= L
	added_languages = list()

/obj/item/organ_module/language/emp_act()
	. = ..()

	var/obj/item/organ/O = loc
	if(!istype(O))
		return

	var/mob/living/carbon/human/H = O.loc
	if(!istype(H))
		return

	if(LAZYLEN(added_languages) && prob(25))
		H.set_default_language(pick(added_languages))
