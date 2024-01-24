/datum/emote/synth/beep
	key = "beep"

	message_1p = "You beep."
	message_3p = "beeps."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "flickers."

	message_miming = "makes synth noises."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	sound = 'sound/signals/ping7.ogg'

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_SYNTH_OR_ROBOT

	statpanel_proc = /mob/living/proc/beep_emote

/mob/living/proc/beep_emote()
	set name = "Beep"
	set category = "Emotes"
	emote("beep", intentional = TRUE)


/datum/emote/synth/ping
	key = "ping"

	message_1p = "You ping."
	message_3p = "pings."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "flickers."

	message_miming = "makes synth noises."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	sound = 'sound/signals/ping1.ogg'

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_SYNTH_OR_ROBOT

	statpanel_proc = /mob/living/proc/ping_emote

/mob/living/proc/ping_emote()
	set name = "Ping"
	set category = "Emotes"
	emote("ping", intentional = TRUE)


/datum/emote/synth/buzz
	key = "buzz"

	message_1p = "You buzz."
	message_3p = "buzzes."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "flickers."

	message_miming = "makes synth noises."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	sound = 'sound/signals/warning2.ogg'

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_SYNTH_OR_ROBOT

	statpanel_proc = /mob/living/proc/buzz_emote

/mob/living/proc/buzz_emote()
	set name = "Buzz"
	set category = "Emotes"
	emote("buzz", intentional = TRUE)


/datum/emote/synth/deny
	key = "deny"

	message_1p = "You emit a negative blip."
	message_3p = "emits a negative blip."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "flickers."

	message_miming = "makes synth noises."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	sound = 'sound/signals/warning7.ogg'

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_SYNTH_OR_ROBOT

	statpanel_proc = /mob/living/proc/deny_emote

/mob/living/proc/deny_emote()
	set name = "Deny"
	set category = "Emotes"
	emote("deny", intentional = TRUE)


/datum/emote/synth/confirm
	key = "confirm"

	message_1p = "You emit an affirmative blip."
	message_3p = "emits an affirmative blip."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "flickers."

	message_miming = "makes synth noises."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	sound = 'sound/signals/ping5.ogg'

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_SYNTH_OR_ROBOT

	statpanel_proc = /mob/living/proc/confirm_emote

/mob/living/proc/confirm_emote()
	set name = "Confirm"
	set category = "Emotes"
	emote("confirm", intentional = TRUE)


/datum/emote/synth/law
	key = "law"

	message_1p = "You show your legal authorization barcode."
	message_3p = "shows it's legal authorization barcode."

	message_impaired_production = "makes a noise."
	message_impaired_reception = "flickers."

	message_miming = "makes synth noises."
	message_muzzled = "makes a noise."

	message_type = AUDIBLE_MESSAGE

	sound = 'sound/voice/biamthelaw.ogg'

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_ROBOT_SEC_MODULE

	statpanel_proc = /mob/living/proc/law_emote

/mob/living/proc/law_emote()
	set name = "Law"
	set category = "Emotes"
	emote("law", intentional = TRUE)


/datum/emote/synth/halt
	key = "halt"

	message_1p = "You skreech with your speakers, \"Halt! Security!\""
	message_3p = "skreeches with it's skeapers, \"Halt! Security!\""

	message_impaired_production = "makes a loud noise."
	message_impaired_reception = "flickers with red."

	message_miming = "makes loud synth noises."
	message_muzzled = "makes a loud noise."

	message_type = AUDIBLE_MESSAGE

	sound = 'sound/voice/halt.ogg'

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_ROBOT_SEC_MODULE

	statpanel_proc = /mob/living/proc/halt_emote

/mob/living/proc/halt_emote()
	set name = "Halt"
	set category = "Emotes"
	emote("halt", intentional = TRUE)
