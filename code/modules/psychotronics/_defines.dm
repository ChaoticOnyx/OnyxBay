
/* GLOBAL LISTS */
GLOBAL_LIST_EMPTY(psychoscope_hud_users)  // List of all entities using a psychoscope HUD.

GLOBAL_LIST_INIT(psychoscope_life_data, list(
	/mob = new /datum/PsychoscopeLifeformData("Unknown", "Unknown", "Unknown", "Unknown", "Unknown"),
	/mob/living/carbon/human = new /datum/PsychoscopeLifeformData(
		"Animalia", "Primates", "Homo", "Homo sapiens",
		"Homo sapiens is the only extant human species.\nExtinct species of the genus Homo include Homo erectus, extant from roughly 1.9 to 0.4 million years ago, and a number of other species (by some authors considered subspecies of either H. sapiens or H. erectus). The age of speciation of H. sapiens out of ancestral H. erectus (or an intermediate species such as Homo antecessor) is estimated to have been roughly 350,000 years ago. Sustained archaic admixture is known to have taken place both in Africa and (following the recent Out-Of-Africa expansion) in Eurasia, between about 100,000 and 30,000 years ago."
	)
))

/* ICONS */

// Indexes for /mob/var/list/psychoscope_icons
#define PSYCHOSCOPE_ICON_DOT 1
#define PSYCHOSCOPE_ICON_SCAN 2

/* HUD */

#define HUD_PSYCHOSCOPE	0x6