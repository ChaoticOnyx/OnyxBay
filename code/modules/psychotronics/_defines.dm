
/* NEUROMODS */
#define NEUROMOD_LIGHT_REGENERATION /datum/NeuromodData/LightRegeneration

/* GLOBAL LISTS */
GLOBAL_LIST_EMPTY(psychoscope_hud_users)  // List of all entities using a psychoscope HUD.

GLOBAL_LIST_INIT(psychoscope_lifeform_data, list(
	/mob = new /datum/PsychoscopeLifeformData("Unknown", "Unknown", "Unknown", "Unknown", "Unknown"),
	/mob/living/carbon/human = new /datum/PsychoscopeLifeformData(
		"Animalia", "Mammalia", "Homo", "Homo sapiens",
		"Homo sapiens is the only extant human species.\nExtinct species of the genus Homo include Homo erectus, extant from roughly 1.9 to 0.4 million years ago, and a number of other species (by some authors considered subspecies of either H. sapiens or H. erectus). The age of speciation of H. sapiens out of ancestral H. erectus (or an intermediate species such as Homo antecessor) is estimated to have been roughly 350,000 years ago. Sustained archaic admixture is known to have taken place both in Africa and (following the recent Out-Of-Africa expansion) in Eurasia, between about 100,000 and 30,000 years ago.",
		list(
			"2" = list(
				TECH_BIO = 1
			)
		)
	),
	/mob/living/carbon/alien/diona = new /datum/PsychoscopeLifeformData(
		"Animalia", "Reptilia", "Dionaea", "Diona",
		"The Dionaea (or Diona for singular) are a group of slow organisms that are in fact clusters of individual, smaller organisms. They exhibit a high degree of structural flexibility, and can form themselves into multiple humanoid shapes in an attempt to blend in to humanoid societies.",
		list(
			"2" = list(
				TECH_BIO = 2
			)
		),
		list(
			"4" = list(
				NEUROMOD_LIGHT_REGENERATION
			)
		)
	)
))

/* ICONS */

// Indexes for /mob/var/list/psychoscope_icons
#define PSYCHOSCOPE_ICON_DOT 1
#define PSYCHOSCOPE_ICON_SCAN 2

/* HUD */

#define HUD_PSYCHOSCOPE	0x6
