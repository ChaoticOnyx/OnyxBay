// This is something of an intermediary species used for species that
// need to emulate the appearance of another race. Currently it is only
// used for metroids but it may be useful for changelings later.
var/list/wrapped_species_by_ref = list()

/datum/species/shapeshifter

	inherent_verbs = list(
		/mob/living/carbon/human/proc/shapeshifter_select_shape,
		// /mob/living/carbon/human/proc/shapeshifter_select_hair,
		/mob/living/carbon/human/proc/shapeshifter_select_gender,
		/mob/living/carbon/human/proc/shapeshifter_select_body_build
		)

	var/list/valid_transform_species = list()
	var/monochromatic
	var/default_form = SPECIES_HUMAN

/datum/species/shapeshifter/get_valid_shapeshifter_forms(mob/living/carbon/human/H)
	return valid_transform_species

/datum/species/shapeshifter/get_icobase(mob/living/carbon/human/H, get_deform)
	if(!H) return ..(null, get_deform)
	var/datum/species/S = all_species[wrapped_species_by_ref["\ref[H]"]]
	return S.get_icobase(H, get_deform)

/datum/species/shapeshifter/get_race_key(mob/living/carbon/human/H)
	return "[..()]-[wrapped_species_by_ref["\ref[H]"]]"

// /datum/species/shapeshifter/get_bodytype(var/mob/living/carbon/human/H)
// 	if(!H) return ..()
// 	var/datum/species/S = all_species[wrapped_species_by_ref["\ref[H]"]]
// 	return S.get_bodytype(H)

/datum/species/shapeshifter/get_damage_mask(mob/living/carbon/human/H)
	if(!H) return ..()
	var/datum/species/S = all_species[wrapped_species_by_ref["\ref[H]"]]
	return S.get_damage_mask(H)

/datum/species/shapeshifter/get_damage_overlays(mob/living/carbon/human/H)
	if(!H) return ..()
	var/datum/species/S = all_species[wrapped_species_by_ref["\ref[H]"]]
	return S.get_damage_overlays(H)

/datum/species/shapeshifter/get_tail(mob/living/carbon/human/H)
	if(!H) return ..()
	var/datum/species/S = all_species[wrapped_species_by_ref["\ref[H]"]]
	return S.get_tail(H)

/datum/species/shapeshifter/get_tail_animation(mob/living/carbon/human/H)
	if(!H) return ..()
	var/datum/species/S = all_species[wrapped_species_by_ref["\ref[H]"]]
	return S.get_tail_animation(H)

/datum/species/shapeshifter/get_tail_hair(mob/living/carbon/human/H)
	if(!H) return ..()
	var/datum/species/S = all_species[wrapped_species_by_ref["\ref[H]"]]
	return S.get_tail_hair(H)

/datum/species/shapeshifter/handle_pre_spawn(mob/living/carbon/human/H)
	..()
	wrapped_species_by_ref["\ref[H]"] = default_form

/datum/species/shapeshifter/handle_post_spawn(mob/living/carbon/human/H)
	..()
	if(monochromatic)
		H.r_hair =   H.r_skin
		H.g_hair =   H.g_skin
		H.b_hair =   H.b_skin
		H.r_facial = H.r_skin
		H.g_facial = H.g_skin
		H.b_facial = H.b_skin

	for(var/obj/item/organ/external/E in H.organs)
		E.sync_colour_to_human(H)

// Verbs follow.
/* -- Incredibly Broken. TODO: Try to fix it later with ignore hair species flags in get_hair_icon() --
/mob/living/carbon/human/proc/shapeshifter_select_hair()

	set name = "Select Hair"
	set category = "Abilities"

	if(stat || world.time < last_special)
		return

	last_special = world.time + 10

	visible_message("<span class='notice'>\The [src]'s form contorts subtly.</span>")
	if(species.get_hair_styles())
		var/new_hair = input("Select a hairstyle.", "Shapeshifter Hair") as null|anything in species.get_hair_styles()
		change_hair(new_hair ? new_hair : "Bald")
	if(species.get_facial_hair_styles(gender))
		var/new_hair = input("Select a facial hair style.", "Shapeshifter Hair") as null|anything in species.get_facial_hair_styles(gender)
		change_facial_hair(new_hair ? new_hair : "Shaved")
*/
/mob/living/carbon/human/proc/shapeshifter_select_gender()

	set name = "Select Gender"
	set category = "Abilities"

	if(stat)
		to_chat(usr, SPAN("warning", "You can't use your abilities while you unconscious."))
		return
	if(world.time < last_special)
		to_chat(usr, SPAN("warning", "You can't use your abilities so fast!"))
		return

	last_special = world.time + 50

	var/new_gender = input("Please select a gender.", "Shapeshifter Gender") as null|anything in list(FEMALE, MALE)
	if(!new_gender)
		return

	visible_message(SPAN("notice", "\The [src]'s form contorts subtly."))
	change_gender(new_gender)
	shapeshifter_sanitize_body()

/mob/living/carbon/human/proc/shapeshifter_select_shape()

	set name = "Select Body Shape"
	set category = "Abilities"

	if(stat)
		to_chat(usr, SPAN("warning", "You can't use your abilities while you unconscious."))
		return
	if(world.time < last_special)
		to_chat(usr, SPAN("warning", "You can't use your abilities so fast!"))
		return

	last_special = world.time + 50

	var/new_species = input("Please select a species to emulate.", "Shapeshifter Body") as null|anything in species.get_valid_shapeshifter_forms(src)
	if(!new_species || !all_species[new_species] || wrapped_species_by_ref["\ref[src]"] == new_species)
		return

	wrapped_species_by_ref["\ref[src]"] = new_species
	shapeshifter_sanitize_body()
	visible_message("<span class='notice'>\The [src] shifts and contorts, taking the form of \a ["\improper [new_species]"]!</span>")
	regenerate_icons()

/mob/living/carbon/human/proc/shapeshifter_select_colour()

	set name = "Select Body Colour"
	set category = "Abilities"

	if(stat)
		to_chat(usr, SPAN("warning", "You can't use your abilities while you unconscious."))
		return
	if(world.time < last_special)
		to_chat(usr, SPAN("warning", "You can't use your abilities so fast!"))
		return

	last_special = world.time + 50

	var/new_skin = input("Please select a new body color.", "Shapeshifter Colour") as color
	if(!new_skin)
		return
	shapeshifter_set_colour(new_skin)

/mob/living/carbon/human/proc/shapeshifter_set_colour(new_skin) // something is wrong with colours on humans. TODO: fix

	r_skin =   hex2num(copytext(new_skin, 2, 4))
	g_skin =   hex2num(copytext(new_skin, 4, 6))
	b_skin =   hex2num(copytext(new_skin, 6, 8))

	var/datum/species/shapeshifter/S = species
	if(S.monochromatic)
		r_hair =   r_skin
		g_hair =   g_skin
		b_hair =   b_skin
		r_facial = r_skin
		g_facial = g_skin
		b_facial = b_skin

	for(var/obj/item/organ/external/E in organs)
		E.sync_colour_to_human(src)

	regenerate_icons()

/mob/living/carbon/human/proc/shapeshifter_select_body_build()

	set name = "Select Body Build"
	set category = "Abilities"

	if(stat)
		to_chat(usr, SPAN("warning", "You can't use your abilities while you unconscious."))
		return
	if(world.time < last_special)
		to_chat(usr, SPAN("warning", "You can't use your abilities so fast!"))
		return

	last_special = world.time + 30

	var/datum/species/S = all_species[wrapped_species_by_ref["\ref[src]"]]

	if(S.get_body_build_datum_list(gender))
		var/new_body_build = input("Please select a new body build.", "Shapeshifter Body Build") as null|anything in S.get_body_build_datum_list(gender)
		if(!new_body_build || body_build == new_body_build)
			return
		change_body_build(new_body_build)
		visible_message(SPAN("notice", "\The [src]'s form contorts subtly."))

/mob/living/carbon/human/proc/shapeshifter_sanitize_body()
	var/datum/species/S = all_species[wrapped_species_by_ref["\ref[src]"]]
	var/list/body_builds = S.get_body_build_datum_list(src.gender)
	if(!(body_build in body_builds))
		body_build = body_builds[1]
		regenerate_icons()
