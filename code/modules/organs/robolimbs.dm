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
	var/can_feel_pain
	// Eyes stuff
	var/has_eyes
	var/use_eye_icon = "eyes_s"
	// Skin & BP stuff
	var/can_eat
	var/skintone
	var/lifelike
	// Species in these lists can't / can take these prosthetics.
	var/list/restricted_to = list(SPECIES_HUMAN)
	var/list/species_cannot_use = list(SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)
	// Applyes to specific bodypart.
	var/list/applies_to_part = list()
	var/modular_bodyparts = MODULAR_BODYPART_INVALID
	// Spicies alternatives
	var/list/species_alternates = list(SPECIES_TAJARA = "Unbranded - Tajaran", SPECIES_UNATHI = "Unbranded - Unathi")

/datum/robolimb/unbranded_alt1
	company = "Unbranded - Mantis Prosis"
	desc = "This limb has a casing of sleek black metal and repulsive insectile design."
	icon = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_alt1.dmi'
	has_eyes = TRUE
	modular_bodyparts = MODULAR_BODYPART_PROSTHETIC


/datum/robolimb/unbranded_tajaran
	company = "Unbranded - Tajaran"
	desc = "A simple robotic limb with feline design. Seems rather stiff."
	icon = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_tajaran.dmi'
	restricted_to = list(SPECIES_TAJARA)
	species_cannot_use = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_UNATHI, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

/datum/robolimb/unbranded_unathi
	company = "Unbranded - Unathi"
	desc = "A simple robotic limb with reptilian design. Seems rather stiff."
	icon = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_unathi.dmi'
	restricted_to = list(SPECIES_UNATHI)
	species_cannot_use = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_TAJARA, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

//NANOTRASEN
/datum/robolimb/nanotrasen
	company = "NanoTrasen"
	desc = "A simple but efficient robotic limb, created by NanoTrasen."
	icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_main.dmi'

/datum/robolimb/nanotrasen_alt1
	company = "NanoTrasen Plus"
	desc = "A simple but efficient robotic limb, created by NanoTrasen."
	icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_alt1.dmi'

/datum/robolimb/nanotrasen_tajaran
	company = "NanoTrasen - Tajaran"
	desc = "A simple but efficient robotic limb, created by NanoTrasen."
	icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_tajaran.dmi'
	restricted_to = list(SPECIES_TAJARA)
	species_cannot_use = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_UNATHI, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

/datum/robolimb/nanotrasen_unathi
	company = "NanoTrasen - Unathi"
	desc = "A simple but efficient robotic limb, created by NanoTrasen."
	icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_unathi.dmi'
	restricted_to = list(SPECIES_UNATHI)
	species_cannot_use = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_TAJARA, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

//ZENG-HU
/datum/robolimb/zenghu
	company = "Zeng-Hu"
	desc = "This limb has a rubbery fleshtone covering with visible seams."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_main.dmi'
	lifelike = TRUE
	unavailable_to_build = TRUE
	modular_bodyparts = MODULAR_BODYPART_CYBERNETIC
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_TAJARA, SPECIES_UNATHI, SPECIES_SKRELL, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)
	species_alternates = list(SPECIES_TAJARA = "Zeng-Hu - Tajaran")

/datum/robolimb/zenghu_tajaran
	company = "Zeng-Hu - Tajaran"
	desc = "This limb has a rubbery fleshtone covering with visible seams."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_taj.dmi'
	lifelike = TRUE
	unavailable_to_build = TRUE
	modular_bodyparts = MODULAR_BODYPART_CYBERNETIC
	restricted_to = list(SPECIES_TAJARA)
	species_cannot_use = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_UNATHI, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

//BISHOP
/datum/robolimb/bishop
	company = "Bishop"
	desc = "This limb has a white polymer casing with blue holo-displays."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_main.dmi'
	unavailable_to_build = TRUE
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_UNATHI, SPECIES_TAJARA, SPECIES_SKRELL, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

/datum/robolimb/bishop_alt1
	company = "Bishop - Rook"
	desc = "This limb has a white polymer casing with blue holo-displays."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_alt1.dmi'
	has_eyes = TRUE
	unavailable_to_build = TRUE
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_UNATHI, SPECIES_TAJARA, SPECIES_SKRELL, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

//HEPHAESTUS
/datum/robolimb/hephaestus
	company = "Hephaestus"
	desc = "This limb has a militaristic black and green casing with gold stripes"
	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_main.dmi'
	unavailable_to_build = TRUE
	restricted_to = list(SPECIES_HUMAN)

/datum/robolimb/hephaestus/hephaestus_alt1
	company = "Hephaestus - Athena"
	desc = "This rather thick limb has a militaristic green plating."
	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_alt1.dmi'
	unavailable_to_build = TRUE
	restricted_to = list(SPECIES_HUMAN)

//VEY-MED
/datum/robolimb/veymed
	company = "Vey-Med"
	desc = "This high quality limb is nearly indistinguishable from an organic one."
	icon = 'icons/mob/human_races/cyberlimbs/veymed/veymed_main.dmi'
	skintone = 1
	can_eat = TRUE
	lifelike = TRUE
	unavailable_to_build = TRUE
	modular_bodyparts = MODULAR_BODYPART_CYBERNETIC
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_SKRELL, SPECIES_UNATHI, SPECIES_TAJARA, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)
	species_alternates = list(SPECIES_SKRELL = "Vey-Med - Skrell")

/datum/robolimb/veymed/skrell
	company = "Vey-Med - Skrell"
	desc = "This high quality limb is nearly indistinguishable from an organic one."
	icon = 'icons/mob/human_races/cyberlimbs/veymed/veymed_skrell.dmi'
	skintone = 1
	can_eat = TRUE
	lifelike = TRUE
	unavailable_to_build = TRUE
	restricted_to = list(SPECIES_SKRELL)
	species_cannot_use = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_TAJARA, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

//WOODEN
/datum/robolimb/wooden
	company = "Morgan Trading Co"
	desc = "A simplistic, metal-banded, wood-panelled prosthetic."
	icon = 'icons/mob/human_races/cyberlimbs/makeshift/wooden.dmi'
	unavailable_to_build = TRUE
	modular_bodyparts = MODULAR_BODYPART_PROSTHETIC
	applies_to_part = list(BP_L_FOOT, BP_R_FOOT, BP_L_LEG, BP_R_LEG, BP_L_HAND, BP_R_HAND, BP_L_ARM, BP_R_ARM)

//EINSTEIN
/datum/robolimb/einstein
	company = "Einstein Engines"
	desc = "This limb is lightweight with a sleek design."
	icon = 'icons/mob/human_races/cyberlimbs/einstein/einstein.dmi'
	unavailable_to_build = TRUE
	modular_bodyparts = MODULAR_BODYPART_PROSTHETIC
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_UNATHI, SPECIES_TAJARA, SPECIES_SKRELL, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

//ANCIENT
/datum/robolimb/ancient
	company = "Uesseka Prototyping Ltd."
	desc = "This limb seems meticulously hand-crafted, and distinctly Unathi in design."
	icon = 'icons/mob/human_races/cyberlimbs/ancient/ancient.dmi'
	unavailable_to_build = TRUE
	unavailable_at_chargen = TRUE
	restricted_to = list(SPECIES_UNATHI)
	species_cannot_use = list(SPECIES_HUMAN, SPECIES_TAJARA, SPECIES_SKRELL, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

//WARDTAKAHASHI
/datum/robolimb/wardtakahashi
	company = "Ward-Takahashi"
	desc = "This limb features sleek black and white polymers."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_main.dmi'
	unavailable_to_build = TRUE
	modular_bodyparts = MODULAR_BODYPART_PROSTHETIC
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_UNATHI, SPECIES_TAJARA, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

/datum/robolimb/wardtakahashi_alt1
	company = "Ward-Takahashi - Spirit"
	desc = "This limb has white and purple features, with a heavier casing."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_alt1.dmi'
	unavailable_to_build = TRUE
	modular_bodyparts = MODULAR_BODYPART_PROSTHETIC
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_UNATHI, SPECIES_TAJARA, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

//CYBERSOLUTIONS
/datum/robolimb/cybersolutions
	company = "Cyber Solutions"
	desc = "This limb is grey and rough, with little in the way of aesthetic."
	icon = 'icons/mob/human_races/cyberlimbs/cybersolutions/cybersolutions_main.dmi'
	unavailable_to_build = TRUE
	modular_bodyparts = MODULAR_BODYPART_CYBERNETIC
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_SKRELL, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

/datum/robolimb/cybersolutions_alt1
	company = "Cyber Solutions - Wight"
	desc = "This limb has cheap plastic panels mounted on grey metal."
	icon = 'icons/mob/human_races/cyberlimbs/cybersolutions/cybersolutions_alt1.dmi'
	unavailable_to_build = TRUE
	modular_bodyparts = MODULAR_BODYPART_PROSTHETIC
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_SKRELL, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

/datum/robolimb/cybersolutions_alt2
	company = "Cyber Solutions - Outdated"
	desc = "This limb is of severely outdated design; there's no way it's comfortable or very functional to use."
	icon = 'icons/mob/human_races/cyberlimbs/cybersolutions/cybersolutions_alt2.dmi'
	unavailable_to_build = TRUE
	modular_bodyparts = MODULAR_BODYPART_PROSTHETIC
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_SKRELL, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

//XION
/datum/robolimb/xion
	company = "Xion"
	desc = "This limb has a minimalist black and red casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_main.dmi'
	unavailable_to_build = TRUE
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_SKRELL, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

/datum/robolimb/xion_alt1
	company = "Xion - Whiteout"
	desc = "This limb has a minimalist black and white casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_alt1.dmi'
	unavailable_to_build = TRUE
	restricted_to = list(SPECIES_HUMAN)
	species_cannot_use = list(SPECIES_SKRELL, SPECIES_PROMETHEAN, SPECIES_DIONA, SPECIES_VOX)

// DESIGN DISKS
/obj/item/weapon/disk/limb
	name = "Limb Blueprints"
	desc = "A disk containing the blueprints for prosthetics."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk1"
	w_class = ITEM_SIZE_TINY
	var/list/company = list()

/obj/item/weapon/disk/limb/New(var/newloc)
	..()
	if(company)
		name = "[company[1]] [initial(name)]"

/obj/item/weapon/disk/limb/bishop
	company = list("Bishop", "Bishop - Rook")

/obj/item/weapon/disk/limb/cybersolutions
	company = list("Cyber Solutions", "Cyber Solutions - Wight", "Cyber Solutions - Outdated")

/obj/item/weapon/disk/limb/hephaestus
	company = list("Hephaestus", "Hephaestus - Athena")

/obj/item/weapon/disk/limb/veymed
	company = list("Vey-Med", "Vey-Med - Skrell")

/obj/item/weapon/disk/limb/wardtakahashi
	company = list("Ward-Takahashi", "Ward-Takahashi - Spirit")

/obj/item/weapon/disk/limb/xion
	company = list("Xion", "Xion - Whiteout")

/obj/item/weapon/disk/limb/zenghu
	company = list("Zeng-Hu", "Zeng-Hu - Tajaran")

// Rare ones
/obj/item/weapon/disk/limb/ancient
	company = list("Uesseka Prototyping Ltd.")
