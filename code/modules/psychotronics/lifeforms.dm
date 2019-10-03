/* BASE DATUM */

/datum/lifeform
	var/mob/mob_type = null
	var/kingdom = ""
	var/class = ""
	var/genus = ""
	var/species = ""
	var/desc = ""
	var/neuromod_prod_scans = -1
	var/list/tech_rewards = null
	var/list/neuromod_rewards = null
	var/tech_chance = 50

/datum/lifeform/New()
	if (!tech_rewards) 		tech_rewards = list()
	if (!neuromod_rewards) 	neuromod_rewards = list()

/datum/lifeform/proc/ToList(mob/user)

	var/list/D = list(
		"mob_type" 				= "[mob_type]",
		"kingdom"				= kingdom,
		"class"					= class,
		"genus"					= genus,
		"species"				= species,
		"desc"					= desc,
		"tech_rewards"			= tech_rewards,
		"neuromod_rewards"		= neuromod_rewards,
		"type"					= "[type]",
		"img"					= icon2html(initial(mob_type.icon), user, initial(mob_type.icon_state), style="height:64px;width:64px;"),
		"neuromod_prod_scans" 	= neuromod_prod_scans
	)

	return D

/* -- DIONA -- */

/datum/lifeform/diona
	mob_type = /mob/living/carbon/alien/diona
	kingdom = "Animalia"
	class = "Reptilia"
	genus = "Dionaea"
	species = "Diona"
	desc = "The Dionaea (or Diona for singular) are a group of slow organisms that are in fact clusters of individual, smaller organisms. They exhibit a high degree of structural flexibility, and can form themselves into multiple humanoid shapes in an attempt to blend in to humanoid societies."

/datum/lifeform/diona/New()
	tech_rewards = list(
		"2" = list(
			TECH_BIO = 2
		),
		"3" = list(
			TECH_BIO = 3
		)
	)

	neuromod_rewards = list(
		"4" = list(
			NEUROMOD_LIGHT_REGENERATION
		)
	)

	..()

/* -- HUMAN -- */

/datum/lifeform/human
	mob_type = /mob/living/carbon/human
	kingdom = "Animalia"
	class = "Mammalia"
	genus = "Homo"
	species = "Homo Sapiens"
	desc = "Homo sapiens is the only extant human species.\nExtinct species of the genus Homo include Homo erectus, extant from roughly 1.9 to 0.4 million years ago, and a number of other species (by some authors considered subspecies of either H. sapiens or H. erectus). The age of speciation of H. sapiens out of ancestral H. erectus (or an intermediate species such as Homo antecessor) is estimated to have been roughly 350,000 years ago. Sustained archaic admixture is known to have taken place both in Africa and (following the recent Out-Of-Africa expansion) in Eurasia, between about 100,000 and 30,000 years ago."
	neuromod_prod_scans = 2

/datum/lifeform/human/New()
	tech_rewards = list(
		"2" = list(
			TECH_BIO = 1
		),
		"3" = list(
			TECH_BIO = 3,
			TECH_MAGNET = 2
		)
	)

	neuromod_rewards = list(
		"4" = list(
			NEUROMOD_LIGHT_REGENERATION
		)
	)

	..()