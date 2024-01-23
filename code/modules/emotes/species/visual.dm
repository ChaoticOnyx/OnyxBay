/datum/emote/species/swish
	key = "swish"

	statpanel_proc = /mob/living/carbon/human/proc/swish_emote

/datum/emote/species/swish/do_emote(mob/living/carbon/human/user)
	user.animate_tail_once()

/mob/living/carbon/human/proc/swish_emote()
	set name = "~ Animate tail (once)"
	set category = "Emotes"
	emote("swish", intentional = TRUE)


/datum/emote/species/wag
	key = "wag"

	statpanel_proc = /mob/living/carbon/human/proc/wag_emote

/datum/emote/species/wag/do_emote(mob/living/carbon/human/user)
	user.animate_tail_start()

/mob/living/carbon/human/proc/wag_emote()
	set name = "~ Animate tail (start)"
	set category = "Emotes"
	emote("wag", intentional = TRUE)


/datum/emote/species/sway
	key = "sway"

	statpanel_proc = /mob/living/carbon/human/proc/sway_tail_emote

/datum/emote/species/sway/do_emote(mob/living/carbon/human/user)
	user.animate_tail_start()

/mob/living/carbon/human/proc/sway_tail_emote()
	set name = "~ Animate tail (start)"
	set category = "Emotes"
	emote("sway", intentional = TRUE)


/datum/emote/species/qwag
	key = "qwag"

	statpanel_proc = /mob/living/carbon/human/proc/qwag_emote

/datum/emote/species/qwag/do_emote(mob/living/carbon/human/user)
	user.animate_tail_fast()

/mob/living/carbon/human/proc/qwag_emote()
	set name = "~ Animate tail (fast)"
	set category = "Emotes"
	emote("qwag", intentional = TRUE)


/datum/emote/species/fastsway
	key = "fastsway"

	statpanel_proc = /mob/living/carbon/human/proc/fastsway_emote

/datum/emote/species/fastsway/do_emote(mob/living/carbon/human/user)
	user.animate_tail_fast()

/mob/living/carbon/human/proc/fastsway_emote()
	set name = "~ Animate tail (fast)"
	set category = "Emotes"
	emote("fastsway", intentional = TRUE)


/datum/emote/species/swag
	key = "swag"

	statpanel_proc = /mob/living/carbon/human/proc/swag_emote

/datum/emote/species/swag/do_emote(mob/living/carbon/human/user)
	user.animate_tail_stop()

/mob/living/carbon/human/proc/swag_emote()
	set name = "~ Animate tail (stop)"
	set category = "Emotes"
	emote("fastsway", intentional = TRUE)

/datum/emote/species/stopsway
	key = "stopsway"

	statpanel_proc = /mob/living/carbon/human/proc/stopsway_emote

/datum/emote/species/stopsway/do_emote(mob/living/carbon/human/user)
	user.animate_tail_stop()

/mob/living/carbon/human/proc/stopsway_emote()
	set name = "~ Animate tail (stop)"
	set category = "Emotes"
	emote("stopsway", intentional = TRUE)
