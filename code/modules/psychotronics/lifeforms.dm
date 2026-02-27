/* Base Datum */

/datum/lifeform
	var/mob/mob_type = null				// A mob which this lifeform is
	var/kingdom = ""
	var/class = ""
	var/genus = ""
	var/species = ""
	var/desc = ""
	var/list/tech_rewards = list()		// Techs which you can possible open
	var/list/neuromod_rewards = list()	// Neuromods which you can possible open
	var/tech_chance = 50				// Chance to open a technology

/datum/lifeform/proc/ToList()

	var/list/D = list(
		"mob_type" 				= "[mob_type]",
		"kingdom"				= kingdom,
		"class"					= class,
		"genus"					= genus,
		"species"				= species,
		"desc"					= desc,
		"tech_rewards"			= tech_rewards,
		"neuromod_rewards"		= neuromod_rewards,
		"type"					= "[type]"
	)

	return D

/* Diona Nymph */
/datum/lifeform/diona_hymph
	mob_type = /mob/living/carbon/larva/diona
	kingdom = "Animalia"
	class = "Plantia"
	genus = "Dionaea"
	species = "Diona Nymph"
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
	desc = "The 'Tajara' (plural Tajara 'Ta-jaw-rah', singular Tajaran 'Ta-jaw-run') are a species of furred mammalian bipeds hailing from the chilly planet of Ahdomai, in the Zamsiin-lr system. They are superstitious species, which led them to the technological advancement of their society throughout history. Their pride for the struggles they went through is heavily tied to their spiritual beliefs."
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

/* Skrell */
/datum/lifeform/skrell
	mob_type = /mob/living/carbon/human/skrell
	kingdom = "Animalia"
	class = "Amphibia"
	genus = "Skrell"
	species = "Skrell Sapiens"
	desc = "The Skrell are a species of amphibious humanoids hailing from the world of Qerrbalak, a hot, humid planet with numerous swamps and jungles."
	tech_rewards = list(
		"3" = list(
			TECH_BIO = 3
		)
	)

	neuromod_rewards = list(
		"2" = list(
			/datum/neuromod/language/skrellian
		)
	)

/* Vox */
/datum/lifeform/vox
	mob_type = /mob/living/carbon/human/vox
	kingdom = "Animalia"
	class = "Aves"
	genus = "Vox"
	species = "Vox Sapiens"
	desc = "The Vox (voks) are nomadic, bio-engineered alien creatures that operate in and around human space at the behest of crazed and dreaming gods."
	tech_rewards = list(
		"2" = list(
			TECH_BIO = 4
		),
		"4" = list(
			TECH_BIO = 5
		)
	)

/* Diona */
/datum/lifeform/diona
	mob_type = /mob/living/carbon/larva/diona
	kingdom = "Animalia"
	class = "Plantia"
	genus = "Dionaea"
	species = "Diona"
	desc = "The Dionaea (or Diona for singular) are a group of slow organisms that are in fact clusters of individual, smaller organisms. They exhibit a high degree of structural flexibility, and can form themselves into multiple humanoid shapes in an attempt to blend in to humanoid societies."
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
			/datum/neuromod/light_regeneration
		)
	)

/* Mouse */
/datum/lifeform/mouse
	mob_type = /mob/living/simple_animal/mouse
	kingdom = "Animalia"
	class = "Mammalia"
	genus = "Mus"
	species = "Mus Musculus"
	desc = "The Muridae, or murids, are the largest family of rodents and of mammals. Murids generally have excellent senses of hearing and smell."

/* AI */
/datum/lifeform/ai
	mob_type = /mob/living/silicon/ai
	kingdom = "UNKNOWN"
	class = "UNKNOWN"
	genus = "UNKNOWN"
	species = "AI"
	desc = "A silicon lifeform. Living and intelligence machine, has the most fastest analytical thinking."
	tech_rewards = list(
		"1" = list(
			TECH_DATA = 4,
			TECH_ENGINEERING = 4,
		)
	)

/* Robot */
/datum/lifeform/robot
	mob_type = /mob/living/silicon/robot
	kingdom = "UNKNOWN"
	class = "UNKNOWN"
	genus = "UNKNOWN"
	species = "Robot"
	desc = "A silicon lifeform. Helps crew in work."
	tech_rewards = list(
		"2" = list(
			TECH_DATA = 3
		),
		"4" = list(
			TECH_ENGINEERING = 3
		)
	)

/* Combat Drone */
/datum/lifeform/combat_drone
	mob_type = /mob/living/silicon/robot/combat
	kingdom = "UNKNOWN"
	class = "UNKNOWN"
	genus = "UNKNOWN"
	species = "Combat Drone"
	desc = "A silicon lifeform. Contains a weapon system."
	tech_rewards = list(
		"2" = list(
			TECH_COMBAT = 2
		),
		"4" = list(
			TECH_COMBAT = 4
		)
	)

/* Metroid */
/datum/lifeform/metroid
	mob_type = /mob/living/carbon/metroid
	kingdom = "UNKNOWN"
	class = "UNKNOWN"
	genus = "UNKNOWN"
	species = "Metroid"
	desc = "Metroids have vulnerability to water. When an adult metroid dies - it splits in to a pair of small metroids."
	tech_chance = 10
	tech_rewards = list(
		"2" = list(
			TECH_BIO = 2
		),
		"4" = list(
			TECH_BIO = 3
		),
		"6" = list(
			TECH_BIO = 5
		),
		"8" = list(
			TECH_BIO = 6
		),
		"10" = list(
			TECH_BIO = 8
		)
	)

	neuromod_rewards = list(
		"6" = list(
			/datum/neuromod/remoteview,
			/datum/neuromod/increase_speed,
			/datum/neuromod/morph,
			/datum/neuromod/telepathy
		)
	)
