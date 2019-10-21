/* Base Datum */

/datum/lifeform
	var/mob/mob_type = null				// A mob which this lifeorm is
	var/kingdom = ""
	var/class = ""
	var/genus = ""
	var/species = ""
	var/desc = ""
	var/neuromod_prod_scans = -1		// Minimum scan count for creating a neuromod for this lifeform
	var/list/tech_rewards = list()		// Techs which you can possible open
	var/list/neuromod_rewards = list()	// Neuromods which you can possible open
	var/tech_chance = 50				// Chance to open a technology

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

/* Diona */
/datum/lifeform/diona
	mob_type = /mob/living/carbon/alien/diona
	kingdom = "Animalia"
	class = "Reptilia"
	genus = "Dionaea"
	species = "Diona"
	desc = "The Dionaea (or Diona for singular) are a group of slow organisms that are in fact clusters of individual, smaller organisms. They exhibit a high degree of structural flexibility, and can form themselves into multiple humanoid shapes in an attempt to blend in to humanoid societies."
	tech_rewards = list(
		// A number in quotes - minimal scan count.
		"2" = list(
			TECH_BIO = 2
		),
		"3" = list(
			TECH_BIO = 3
		)
	)

	neuromod_rewards = list(
		"4" = list(
			/datum/neuromod/light_regeneration
		)
	)

/* Human */
/datum/lifeform/human
	mob_type = /mob/living/carbon/human
	kingdom = "Animalia"
	class = "Mammalia"
	genus = "Homo"
	species = "Homo Sapiens"
	desc = "Homo sapiens is the only extant human species.\nExtinct species of the genus Homo include Homo erectus, extant from roughly 1.9 to 0.4 million years ago, and a number of other species (by some authors considered subspecies of either H. sapiens or H. erectus). The age of speciation of H. sapiens out of ancestral H. erectus (or an intermediate species such as Homo antecessor) is estimated to have been roughly 350,000 years ago."
	neuromod_prod_scans = 2
	tech_chance = 30
	tech_rewards = list(
		"3" = list(
			TECH_BIO = 2
		),
		"6" = list(
			TECH_BIO = 3
		)
	)

/* Tajaran */
/datum/lifeform/tajaran
	mob_type = /mob/living/carbon/human/tajaran
	kingdom = "Animalia"
	class = "Mammalia"
	genus = "Tajaran"
	species = "Tajaran Sapiens"
	desc = "The “Tajara” (plural Tajara “Ta-jaw-rah”, singular Tajaran “Ta-jaw-run”) are a species of furred mammalian bipeds hailing from the chilly planet of Ahdomai, in the Zamsiin-lr system. They are superstitious species, which led them to the technological advancement of their society throughout history. Their pride for the struggles they went through is heavily tied to their spiritual beliefs."
	neuromod_prod_scans = 2
	tech_rewards = list(
		"3" = list(
			TECH_BIO = 3
		)
	)

	neuromod_rewards = list(
		"2" = list(
			/datum/neuromod/language/siik_maas
		)
	)

/* Unathi */
/datum/lifeform/unathi
	mob_type = /mob/living/carbon/human/unathi
	kingdom = "Animalia"
	class = "Reptilia"
	genus = "Unathi"
	species = "Unathi Sapiens"
	desc = "The Unathi (U-nah-thee) are tall, reptilian humanoids that possess both crocodile-like and serpent-like features. Their scales are hard and plate-like, except for the softer ones that line the inside of their legs, armpits, and groin. Hailing from the planet Moghes, their ways can seem savage and brutal to the outsider, but the Unathi see themselves as honoring their traditions and upholding their faith, and their society incredibly divided due to these two aspects and how they relate to the core ideas of Unathi society: Growth and Rebirth."
	neuromod_prod_scans = 2
	tech_rewards = list(
		"3" = list(
			TECH_BIO = 3
		)
	)

	neuromod_rewards = list(
		"2" = list(
			/datum/neuromod/language/soghun
		)
	)