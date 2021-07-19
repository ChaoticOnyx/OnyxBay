var/list/all_robolimbs = list()
var/list/chargen_robolimbs = list()
var/datum/robolimb/basic_robolimb

/proc/populate_robolimb_list()
	basic_robolimb = new()
	for(var/limb_type in typesof(/datum/robolimb))
		var/datum/robolimb/R = new limb_type()
		all_robolimbs[R.company] = R
		if(!R.unavailable_at_chargen)
			chargen_robolimbs[R.company] = R

	for(var/comapany in all_robolimbs)
		var/datum/robolimb/R = all_robolimbs[comapany]
		if(R.species_alternates)
			for(var/species in R.species_alternates)
				var/species_company = R.species_alternates[species]
				if(species_company in all_robolimbs)
					R.species_alternates[species] = all_robolimbs[species_company]


//UNBRABDED
/datum/robolimb
	var/company = "Unbranded"                            // Shown when selecting the limb.
	var/desc = "A generic unbranded robotic prosthesis." // Seen when examining a limb.
	var/icon = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_main.dmi'       // Icon base to draw from.
	var/unavailable_at_chargen                           // If set, not available at chargen.
	var/unavailable_to_build                             // If set, cannot be fabricated.
	var/can_eat
	var/use_eye_icon = "eyes_s"
	var/can_feel_pain
	var/skintone
	// Species in these lists can't / can take these prosthetics.
	var/list/restricted_to = list(SPECIES_HUMAN)
	var/list/species_cannot_use = list(SPECIES_DIONA, SPECIES_VOX, SPECIES_PROMETHEAN)
	// Applyes to specific bodypart.
	var/list/applies_to_part = list()
	//Spicies alternatives._abs(A)
	var/list/species_alternates = list(SPECIES_TAJARA = "Unbranded - Tajaran", SPECIES_UNATHI = "Unbranded - Unathi")

/datum/robolimb/alt1
 	company = "Unbranded - Mantis Prosis"
 	desc = "This limb has a casing of sleek black metal and repulsive insectile design."
 	icon = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_alt1.dmi'

/datum/robolimb/tajaran
 	company = "Unbranded - Tajaran"
 	desc = "A simple robotic limb with feline design. Seems rather stiff."
 	icon = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_tajaran.dmi'
 	restricted_to = list(SPECIES_TAJARA)

/datum/robolimb/unathi
 	company = "Unbranded - Unathi"
 	desc = "A simple robotic limb with reptilian design. Seems rather stiff."
 	icon = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_unathi.dmi'
 	restricted_to = list(SPECIES_UNATHI)

//NANOTRASEN
/datum/robolimb/nanotrasen
	company = "NanoTrasen"
	desc = "A simple but efficient robotic limb, created by NanoTrasen."
	icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_main.dmi'
	species_cannot_use = list()

/datum/robolimb/nanotrasen/alt1
 	company = "NanoTrasen Plus"
 	icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_alt1.dmi'

/datum/robolimb/nanotrasen/tajaran
	company = "NanoTrasen - Tajaran"
	icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_tajaran.dmi'
	restricted_to = list(SPECIES_TAJARA)

/datum/robolimb/nanotrasen/unathi
	company = "NanoTrasen - Unathi"
	icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_unathi.dmi'
	restricted_to = list(SPECIES_UNATHI)

//ZENG-HU
/datum/robolimb/zenghu
	company = "Zeng-Hu"
	desc = "This limb has a rubbery fleshtone covering with visible seams."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_main.dmi'
	can_eat = 1
	unavailable_to_build = 1
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_DIONA, SPECIES_VOX, SPECIES_PROMETHEAN, SPECIES_UNATHI)
	species_alternates = list(SPECIES_UNATHI = "Zeng-Hu - Tajaran")

/datum/robolimb/zenghu/tajaran
	company = "Zeng-Hu - Tajaran"
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_taj.dmi'
	restricted_to = list(SPECIES_TAJARA)

//VEY-MED
/datum/robolimb/veymed
	company = "Vey-Med"
	desc = "This high quality limb is nearly indistinguishable from an organic one."
	icon = 'icons/mob/human_races/cyberlimbs/veymed/veymed_main.dmi'
	can_eat = 1
	skintone = 1
	unavailable_to_build = 1
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_DIONA, SPECIES_VOX, SPECIES_PROMETHEAN, SPECIES_UNATHI, SPECIES_TAJARA)
	species_alternates = list(SPECIES_SKRELL = "Vey-Med - Skrell")

/datum/robolimb/veymed
	company = "Vey-Med - Skrell"
	icon = 'icons/mob/human_races/cyberlimbs/veymed/veymed_skrell.dmi'
	restricted_to = list(SPECIES_SKRELL)

// /datum/robolimb/bishop
// 	company = "Bishop"
// 	desc = "This limb has a white polymer casing with blue holo-displays."
// 	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_main.dmi'
// 	unavailable_at_fab = 1

// /datum/robolimb/bishop/alt
// 	company = "Bishop Alt."
// 	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_alt.dmi'
// 	applies_to_part = list(BP_HEAD)
// 	unavailable_at_fab = 1

// /datum/robolimb/bishop/alt/monitor
// 	company = "Bishop Monitor."
// 	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_monitor.dmi'
// 	restricted_to = list()
// 	unavailable_at_fab = 1

/datum/robolimb/hephaestus
	company = "Hephaestus Industries"
	desc = "This limb has a militaristic black and green casing with gold stripes."
	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_main.dmi'
	unavailable_to_build = 1

/datum/robolimb/hephaestus/alt
	company = "Hephaestus Alt."
	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_alt1.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_to_build = 1

// /datum/robolimb/hesphiastos/alt/monitor
// 	company = "Hephaestus Monitor."
// 	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_monitor.dmi'
// 	restricted_to = list()
// 	can_eat = null
// 	unavailable_at_fab = 1

/datum/robolimb/xion
 	company = "Xion"
 	desc = "This limb has a minimalist black and red casing."
 	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_main.dmi'
 	unavailable_to_build = 1

/datum/robolimb/xion/alt
 	company = "Xion Alt."
 	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_alt1.dmi'
 	applies_to_part = list(BP_HEAD)
 	unavailable_to_build = 1

//  /datum/robolimb/xion/alt/monitor
// 	company = "Xion Monitor."
// 	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_monitor.dmi'
// 	restricted_to = list()
// 	can_eat = null
// 	unavailable_at_fab = 1



// /datum/robolimb/wardtakahashi
// 	company = "Ward-Takahashi"
// 	desc = "This limb features sleek black and white polymers."
// 	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_main.dmi'
// 	can_eat = 1
// 	unavailable_at_fab = 1

// /datum/robolimb/wardtakahashi/alt
// 	company = "Ward-Takahashi Alt."
// 	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_alt.dmi'
// 	applies_to_part = list(BP_HEAD)
// 	unavailable_at_fab = 1

// /datum/robolimb/wardtakahashi/alt/monitor
// 	company = "Ward-Takahashi Monitor."
// 	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_monitor.dmi'
// 	restricted_to = list()
// 	can_eat = null
// 	unavailable_at_fab = 1

// /datum/robolimb/morpheus
// 	company = "Morpheus"
// 	desc = "This limb is simple and functional; no effort has been made to make it look human."
// 	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_main.dmi'
// 	restricted_to = list()
// 	use_eye_icon = "blank_eyes"
// 	unavailable_at_fab = 1

// /datum/robolimb/morpheus/alt
// 	company = "Morpheus Alt."
// 	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_alt.dmi'
// 	applies_to_part = list(BP_HEAD)
// 	unavailable_at_fab = 1

