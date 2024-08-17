GLOBAL_LIST_INIT(all_robolimbs, list())
GLOBAL_LIST_INIT(chargen_robolimbs, list())
var/datum/robolimb/basic_robolimb

/proc/populate_robolimb_list()
	basic_robolimb = new()
	for(var/limb_type in typesof(/datum/robolimb))
		var/datum/robolimb/R = new limb_type()
		GLOB.all_robolimbs[R.company] = R
		if(!R.unavailable_at_chargen)
			GLOB.chargen_robolimbs[R.company] = R

/datum/robolimb
	var/company = "Unbranded"                                                        // Shown when selecting the limb.
	var/desc = "A generic unbranded robotic prosthesis."                             // Seen when examining a limb.
	var/icon = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_main.dmi'       // Icon base to draw from.
	var/unavailable_at_chargen = FALSE                                               // If set, not available at chargen.
	var/unavailable_at_fab = TRUE                                                    // If set, cannot be fabricated.
	var/can_eat = FALSE
	var/has_eyes_icon = TRUE                                                         // If set, will draw eyes overlay.
	var/can_feel_pain = FALSE
	var/skintone
	var/list/species_cannot_use = list()
	var/list/restricted_to = list()
	var/list/applies_to_part = list()
	var/list/racial_icons = list(
		SPECIES_TAJARA = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_taj.dmi'
	)

/datum/robolimb/nanotrasen
	company = "NanoTrasen"
	desc = "This limb is made from a cheap polymer."
	unavailable_at_fab = FALSE
	racial_icons = list(
		SPECIES_TAJARA = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_taj.dmi'
	)

/datum/robolimb/nanotrasen/unathi
	company = "NanoTrasen - Unathi"
	icon = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_unathi.dmi'
	restricted_to = list(SPECIES_UNATHI)

/datum/robolimb/bishop
	company = "Bishop"
	desc = "This limb has a white polymer casing with blue holo-displays."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_main.dmi'
	racial_icons = list(
		SPECIES_TAJARA = 'icons/mob/human_races/cyberlimbs/bishop/bishop_taj.dmi'
	)

/datum/robolimb/hephaestus
	company = "Hephaestus Industries"
	desc = "This limb has a militaristic black and green casing with gold stripes."
	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_main.dmi'
	racial_icons = list(
		SPECIES_TAJARA = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_taj.dmi'
	)

/datum/robolimb/zenghu
	company = "Zeng-Hu"
	desc = "This limb has a rubbery fleshtone covering with visible seams."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_main.dmi'
	can_eat = TRUE
	racial_icons = list(
		SPECIES_TAJARA = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_taj.dmi'
	)

/datum/robolimb/xion
	company = "Xion"
	desc = "This limb has a minimalist black and red casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_main.dmi'
	racial_icons = list(
		SPECIES_TAJARA = 'icons/mob/human_races/cyberlimbs/xion/xion_taj.dmi'
	)

/datum/robolimb/xion/alt
	company = "Xion Alt."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_alt.dmi'
	has_eyes_icon = FALSE
	applies_to_part = list(BP_HEAD)

/datum/robolimb/wardtakahashi
	company = "Ward-Takahashi"
	desc = "This limb features sleek black and white polymers."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_main.dmi'
	can_eat = TRUE
	racial_icons = list(
		SPECIES_TAJARA = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_taj.dmi'
	)

/datum/robolimb/morpheus
	company = "Morpheus"
	desc = "This limb is simple and functional; no effort has been made to make it look realistic."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_main.dmi'
	racial_icons = list(
		SPECIES_TAJARA = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_taj.dmi'
	)

/datum/robolimb/veymed
	company = "Vey-Med"
	desc = "This high quality limb is nearly indistinguishable from an organic one."
	icon = 'icons/mob/human_races/cyberlimbs/veymed/veymed_main.dmi'
	skintone = 1
	can_eat = TRUE
	species_cannot_use = list(SPECIES_UNATHI, SPECIES_SKRELL, SPECIES_TAJARA)
	restricted_to = list(SPECIES_HUMAN)
