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

//CYBERSOLUTIONS
/datum/robolimb/cybersolutions
	company = "Cyber Solutions"
	desc = "This limb is grey and rough, with little in the way of aesthetic."
	icon = 'icons/mob/human_races/cyberlimbs/cybersolutions/cybersolutions_main.dmi'
	can_eat = 1
	skintone = 1
	unavailable_to_build = 1
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_DIONA, SPECIES_VOX, SPECIES_PROMETHEAN, SPECIES_UNATHI, SPECIES_TAJARA, SPECIES_SKRELL)

/datum/robolimb/cybersolutions/cybersolutions_alt1
	company = "Cyber Solutions - Wight"
	desc = "This limb has cheap plastic panels mounted on grey metal."
	icon = 'icons/mob/human_races/cyberlimbs/cybersolutions/cybersolutions_alt1.dmi'

/datum/robolimb/cybersolutions/cybersolutions_alt2
	company = "Cyber Solutions - Outdated"
	desc = "This limb is of severely outdated design; there's no way it's comfortable or very functional to use."
	icon = 'icons/mob/human_races/cyberlimbs/cybersolutions/cybersolutions_alt2.dmi'

/datum/robolimb/cybersolutions/cybersolutions_alt3
	company = "Cyber Solutions - Array"
	desc = "This limb is simple and functional; array of sensors on a featureless case."
	icon = 'icons/mob/human_races/cyberlimbs/cybersolutions/cybersolutions_alt3.dmi'
	parts = list(BP_HEAD)