/obj/item/organ_module/language
	name = "language processor"
	desc = "An augment installed into the head that interfaces with the user's neural interface, " \
		+ "intercepting and assisting language faculties."
	allowed_organs = list(BP_HEAD)
	icon_state = "cranial_aug"
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	loadout_cost = 5
	/// A list of languages that this augment will add. add your language to this
	var/list/augment_languages = list()
	/// A list of languages that get added when it's installed. used to remove languages later. don't touch this.
	var/list/added_languages = list()
	/// A list of language-related verbs granted by the augment.
	var/list/granted_verbs = list()

/obj/item/organ_module/language/post_install(obj/item/organ/E)
	. = ..()
	add_languages(usr)

/obj/item/organ_module/language/post_removed(obj/item/organ/E)
	. = ..()
	remove_languages(usr)

/obj/item/organ_module/language/organ_installed()
	. = ..()
	add_languages(usr)

/obj/item/organ_module/language/organ_removed()
	. = ..()
	remove_languages(usr)

/obj/item/organ_module/language/proc/add_languages(mob/living/carbon/human/H)
	for(var/language in augment_languages)
		if(!(language in H.languages))
			H.add_language(language)
			added_languages += language
	add_verb(H, granted_verbs)

/obj/item/organ_module/language/proc/remove_languages(mob/living/carbon/human/H)
	for(var/language in added_languages)
		H.remove_language(language)
	added_languages = list()
	remove_verb(H, granted_verbs)

/obj/item/organ_module/language/emp_act()
	. = ..()

	var/obj/item/organ/O = loc
	if(!istype(O))
		return

	var/mob/living/carbon/human/H = O.loc
	if(!istype(H))
		return

	for(var/language in added_languages)
		if(prob(25))
			H.remove_language(language)

	H.set_default_language(pick(H.languages))
