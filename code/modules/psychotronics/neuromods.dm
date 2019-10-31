/mob/living
	var/list/datum/neuromod/neuromods = list()	// Contains paths of all injected neuromods
	var/additional_speed = 0

/* BASE DATUM */

/datum/neuromod
	var/name = "Name"
	var/desc = "Description"
	var/chance = 0				// Chance to be unlocked after scan
	var/research_time = 100		// How long this neuromod takes to research

/datum/neuromod/proc/Handle(mob/living/user)
	return

/datum/neuromod/proc/ToList()
	var/list/N = list()

	N["name"] 			= name
	N["desc"] 			= desc
	N["type"] 			= type
	N["chance"]			= chance
	N["research_time"] 	= research_time

	return N

/* - SUPER POWERS - */

/* -- LIGHT REGENERATION -- */
/datum/neuromod/light_regeneration
	name = "Light Regeneration"
	desc = "The neuromod changes skin structure and makes possible cure wounds just by light."
	chance = 25

/datum/neuromod/light_regeneration/Handle(mob/living/user)
	var/turf/checking = get_turf(user)

	if (!checking)
		return

	var/light_amount = checking.get_lumcount() * 5

	if (light_amount > 2) //if there's enough light, heal
		user.adjustBruteLoss(-(rand(1, 4) / 10))
		user.adjustFireLoss(-(rand(1, 4) / 10))

/* -- REMOVE VIEW -- */
/datum/neuromod/remoteview
	name = "Remote View"
	desc = "The neuromod expands mind's possibilities in sight."
	chance = 1

/datum/neuromod/remoteview/Handle(mob/living/user)
	if (/mob/living/carbon/human/proc/remoteobserve in user.verbs)
		return

	user.verbs += /mob/living/carbon/human/proc/remoteobserve
	user.mutations.Add(mRemote)

/* -- INCREASE SPEED -- */
/datum/neuromod/increase_speed
	name = "Powerful Legs"
	desc = "The neuromod strengths a legs and increases moving speed."
	chance = 5

/datum/neuromod/increase_speed/Handle(mob/living/user)
	if (!user.additional_speed)
		user.additional_speed = 1
		user.mutations.Add(mRun)

/* Morph */
/datum/neuromod/morph
	name = "Morph"
	desc = "The neuromod makes possible to change appearance."

/datum/neuromod/morph/Handle(mob/living/user)
	if (/mob/living/carbon/human/proc/morph in user.verbs)
		return

	user.verbs += /mob/living/carbon/human/proc/morph
	user.mutations.Add(mMorph)

/* -- TELEPATHY -- */
/datum/neuromod/telepathy
	name = "Telepathy"
	desc = "The neuromod makes possible to talk on large distances."
	chance = 5

/datum/neuromod/telepathy/Handle(mob/living/user)
	if (/mob/living/carbon/human/proc/remotesay in user.verbs)
		return

	user.verbs += /mob/living/carbon/human/proc/remotesay
	user.mutations.Add(mRemotetalk)

/* - LANGUAGES - */

/datum/neuromod/language
	var/language = null
	chance = 50

/datum/neuromod/language/Handle(mob/living/user)
	if (!language)
		crash_with("empty language neuromod")
		return

	var/datum/language/L = all_languages[language]

	if (L in user.languages)
		return

	user.add_language(language)

/* -- SIIK'MAAS -- */
/datum/neuromod/language/siik_maas
	name = "Language: Siik'maas"
	desc = "The neuromod makes possible to speak on 'Siik'maas'"
	language = LANGUAGE_SIIK_MAAS

/* -- SOGHUN -- */
/datum/neuromod/language/soghun
	name = "Language: Soghun"
	desc = "The neuromod makes possible to speak on 'Soghun'"
	language = LANGUAGE_UNATHI

/* -- SKRELLIAN -- */
/datum/neuromod/language/skrellian
	name = "Language: Skrellian"
	desc = "The neuromod makes possible to speak on 'Skrellian'"
	language = LANGUAGE_SKRELLIAN
