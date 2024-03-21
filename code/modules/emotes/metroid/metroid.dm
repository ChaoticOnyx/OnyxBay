/datum/emote/metroid
	key = "nomood"
	var/mood

/datum/emote/metroid/do_emote(mob/living/carbon/metroid/user, emote_key, intentional, target)
	. = ..()
	user.mood = mood
	user.regenerate_icons()

/datum/emote/metroid/pout
	key = "pout"
	mood = "pout"

	statpanel_proc = /mob/living/carbon/metroid/proc/pout_emote

/mob/living/carbon/metroid/proc/pout_emote()
	set name = "Pout"
	set category = "Emotes"
	emote("pout", intentional = TRUE)

/datum/emote/metroid/sad
	key = "sad"
	mood = "sad"

	statpanel_proc = /mob/living/carbon/metroid/proc/sad_emote

/mob/living/carbon/metroid/proc/sad_emote()
	set name = "Sad"
	set category = "Emotes"
	emote("sad", intentional = TRUE)

/datum/emote/metroid/angry
	key = "angry"
	mood = "angry"

	statpanel_proc = /mob/living/carbon/metroid/proc/angry_emote

/mob/living/carbon/metroid/proc/angry_emote()
	set name = "Angry"
	set category = "Emotes"
	emote("angry", intentional = TRUE)

/datum/emote/metroid/frown
	key = "frown"
	mood = "mischevous"

	statpanel_proc = /mob/proc/frown_emote

/datum/emote/metroid/smile
	key = "smile"
	mood = ":3"

	statpanel_proc = /mob/proc/smile_emote
