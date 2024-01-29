/datum/emote/whimper
	key = "whimper"

	message_1p = "You whimper."
	message_3p = "whimpers."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "makes a sad face."

	message_miming = "whimpers."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/whimper_emote

/mob/proc/whimper_emote()
	set name = "Whimper"
	set category = "Emotes"
	emote("whimper", intentional = TRUE)


/datum/emote/roar
	key = "roar"

	message_1p = "You roar!"
	message_3p = "roars!"

	message_impaired_production = "makes a loud noise!"

	message_miming = "acts out a roar!"
	message_muzzled = "makes a loud noise!"

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/roar_emote

/datum/emote/roar/get_impaired_msg(mob/user)
	return "opens [P_THEIR(user.gender)] mouth wide and scary!"

/mob/proc/roar_emote()
	set name = "Roar"
	set category = "Emotes"
	emote("roar", intentional = TRUE)


/datum/emote/gasp
	key = "gasp"

	message_1p = "You gasp!"
	message_3p = "gasps!"

	message_impaired_production = "sucks in air violently!"
	message_impaired_reception = "sucks in air violently!"

	message_miming = "appears to be gasping!"
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_HEAVY_BREATH
	sound_human_male = SFX_MALE_HEAVY_BREATH

	statpanel_proc = /mob/proc/gasp_emote

/datum/emote/gasp/get_sfx_volume()
	return rand(25, 45)

/mob/proc/gasp_emote()
	set name = "Gasp"
	set category = "Emotes"
	emote("gasp", intentional = TRUE)


/datum/emote/sneeze
	key = "sneeze"

	message_1p = "You sneeze"
	message_3p = "sneezes."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_SNEEZE
	sound_human_male = SFX_MALE_SNEEZE

	statpanel_proc = /mob/proc/sneeze_emote

/mob/proc/sneeze_emote()
	set name = "Sneeze"
	set category = "Emotes"
	emote("sneeze", intentional = TRUE)


/datum/emote/choke
	key = "choke"

	message_1p = "You choke."
	message_3p = "chokes."

	message_impaired_production = "makes a weak noise."

	message_miming = "chokes."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_HEAVY_BREATH
	sound_human_male = SFX_MALE_HEAVY_BREATH

	statpanel_proc = /mob/proc/choke_emote

/datum/emote/choke/get_impaired_msg(mob/user)
	return "clutches [P_THEIR(user.gender)] throat desperately!"

/datum/emote/choke/get_sfx_volume()
	return rand(25, 45)

/mob/proc/choke_emote()
	set name = "Choke"
	set category = "Emotes"
	emote("choke", intentional = TRUE)


/datum/emote/chuckle
	key = "chuckle"

	message_1p = "You chuckle."
	message_3p = "chuckles."

	message_impaired_production = "makes a weak noise."

	message_miming = "appears to be chuckling."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_LAUGH
	sound_human_male = SFX_MALE_LAUGH

	statpanel_proc = /mob/proc/chuckle_emote

/datum/emote/chuckle/get_impaired_msg(mob/user)
	return "clutches [P_THEIR(user.gender)] throat!"

/datum/emote/chuckle/get_sfx_volume()
	return rand(25, 40)

/mob/proc/chuckle_emote()
	set name = "Chuckle"
	set category = "Emotes"
	emote("chuckle", intentional = TRUE)


/datum/emote/moan
	key = "moan"

	message_1p = "You moan!"
	message_3p = "moans!"

	message_impaired_production = "moans silently."

	message_miming = "appears to moan!"
	message_muzzled = "moans silently!"

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/moan_emote

/datum/emote/moan/get_impaired_msg(mob/user)
	return "opens [P_THEIR(user.gender)] mouth wide"

/mob/proc/moan_emote()
	set name = "Moan"
	set category = "Emotes"
	emote("moan", intentional = TRUE)


/datum/emote/cough
	key = "cough"

	message_1p = "You cough."
	message_3p = "coughs."

	message_impaired_production = "spasms violently!"

	message_miming = "acts out a cough."
	message_muzzled = "appears to cough."

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_COUGH
	sound_human_male = SFX_MALE_COUGH

	statpanel_proc = /mob/proc/cough_emote

/datum/emote/cough/get_impaired_msg(mob/user)
	return "moves [P_THEIR(user.gender)] face forward as [P_THEY(user.gender)] open and close [P_THEIR(user.gender)] mouth!"

/datum/emote/cough/get_sfx_volume()
	return rand(30, 50)

/mob/proc/cough_emote()
	set name = "Cough"
	set category = "Emotes"
	emote("cough", intentional = TRUE)


/datum/emote/cry
	key = "cry"

	message_1p = "You cry."
	message_3p = "cries."

	message_impaired_production = "twists their face into an agonised expression!"

	message_miming = "acts out a cry."
	message_muzzled = "makes a noise!"

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_CRY
	sound_human_male = SFX_MALE_CRY

	statpanel_proc = /mob/proc/cry_emote

/datum/emote/cry/get_sfx_volume()
	return rand(25, 45)

/mob/proc/cry_emote()
	set name = "Cry"
	set category = "Emotes"
	emote("cry", intentional = TRUE)


/datum/emote/scream
	key = "scream"

	message_1p = "You scream!"
	message_3p = "screams!"

	message_impaired_production = "twists their face into an agonised expression!"

	message_miming = "acts out a scream!"
	message_muzzled = "makes a loud noise!"

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_PAIN
	sound_human_male = SFX_MALE_PAIN

	statpanel_proc = /mob/proc/scream_emote

/datum/emote/scream/get_impaired_msg(mob/user)
	return "opens [P_THEIR(user.gender)] mouth like a fish gasping for air!"

/datum/emote/scream/get_sfx_volume()
	return rand(30, 45)

/mob/proc/scream_emote()
	set name = "Scream"
	set category = "Emotes"
	emote("scream", intentional = TRUE)


/datum/emote/scream_long
	key = "scream_long"

	message_1p = "You scream!"
	message_3p = "screams!"

	message_impaired_production = "twists their face into an agonised expression!"

	message_miming = "acts out a scream!"
	message_muzzled = "makes a loud noise!"

	message_type = AUDIBLE_MESSAGE

	sound_human_female = SFX_FEMALE_LONG_SCREAM
	sound_human_male = SFX_MALE_LONG_SCREAM

	statpanel_proc = /mob/proc/scream_long_emote

/datum/emote/scream_long/get_sfx_volume()
	return rand(40, 60)

/mob/proc/scream_long_emote()
	set name = "Scream (long)"
	set category = "Emotes"
	emote("scream_long", intentional = TRUE)


/datum/emote/oink
	key = "oink"

	message_1p = "You oink."
	message_3p = "oinks."

	message_impaired_production = "makes a weak noise."

	message_miming = "acts out an oink."
	message_muzzled = "appears to oink."

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/oink_emote

/datum/emote/oink/get_sound(mob/user, intentional)
	return pick(SFX_OINK)

/datum/emote/oink/get_sfx_volume()
	return 100

/mob/proc/oink_emote()
	set name = "Oink"
	set category = "Emotes"
	emote("oink", intentional = TRUE)


/datum/emote/laugh
	key = "laugh"

	message_1p = "You laugh."
	message_3p = "laughs."

	message_impaired_production = "laughs silently."

	message_miming = "acts out a laugh."
	message_muzzled = "giggles sligthly."

	message_type = AUDIBLE_MESSAGE

	pitch_age_variation = TRUE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_LAUGH
	sound_human_male = SFX_MALE_LAUGH

	statpanel_proc = /mob/proc/laugh_emote

/datum/emote/laugh/get_impaired_msg(mob/user)
	return "opens and closes [P_THEIR(user.gender)] mouth, smiling."

/datum/emote/laugh/get_sfx_volume()
	return rand(25, 45)

/mob/proc/laugh_emote()
	set name = "Laugh"
	set category = "Emotes"
	emote("laugh", intentional = TRUE)


/datum/emote/giggle
	key = "giggle"

	message_1p = "You giggle."
	message_3p = "giggles."

	message_impaired_production = "smiles slightly."

	message_miming = "appears to giggle."
	message_muzzled = "giggles slightly."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_LAUGH
	sound_human_male = SFX_MALE_LAUGH

	statpanel_proc = /mob/proc/giggle_emote

/datum/emote/giggle/get_impaired_msg(mob/user)
	return "opens and closes [P_THEIR(user.gender)] mouth slightly, smiling."

/datum/emote/giggle/get_sfx_volume()
	return rand(25, 35)

/mob/proc/giggle_emote()
	set name = "Giggle"
	set category = "Emotes"
	emote("giggle", intentional = TRUE)


/datum/emote/grunt
	key = "grunt"

	message_1p = "You grunt."
	message_3p = "grunts."

	message_impaired_production = "writhes and sighs slightly."

	message_miming = "appears to grunt!"
	message_muzzled = "grunts silently!"

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_PAIN
	sound_human_male = SFX_MALE_PAIN

	statpanel_proc = /mob/proc/grunt_emote

/datum/emote/grunt/get_impaired_msg(mob/user)
	return "clenches [P_THEIR(user.gender)] teeth."

/datum/emote/grunt/get_sfx_volume()
	return rand(25, 40)

/mob/proc/grunt_emote()
	set name = "Grunt"
	set category = "Emotes"
	emote("grunt", intentional = TRUE)


/datum/emote/groan
	key = "groan"

	message_1p = "You groan."
	message_3p = "groans."

	message_impaired_production = "writhes and sighs slightly."

	message_miming = "appears to be in pain!"
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_PAIN
	sound_human_male = SFX_MALE_PAIN

	statpanel_proc = /mob/proc/groan_emote

/datum/emote/groan/get_impaired_msg(mob/user)
	return "opens [P_THEIR(user.gender)] mouth slightly."

/datum/emote/groan/get_sfx_volume()
	return rand(25, 40)

/mob/proc/groan_emote()
	set name = "Groan"
	set category = "Emotes"
	emote("groan", intentional = TRUE)

/datum/emote/hiccup
	key = "hiccup"

	message_1p = "You hiccup."
	message_3p = "hiccups."

	message_impaired_production = "makes a weak noise."

	message_miming = "hiccups."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	//sound = 'sound/voice/hiccup.ogg'

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/hiccup_emote

/datum/emote/hiccup/get_impaired_msg(mob/user)
	return "spasms suddenly while opening [P_THEIR(user.gender)] mouth."

/mob/proc/hiccup_emote()
	set name = "Hiccup"
	set category = "Emotes"
	emote("hiccup", intentional = TRUE)

/datum/emote/snore
	key = "snore"

	message_1p = "You snore."
	message_3p = "snores."

	message_impaired_production = "makes a noise."

	message_miming = "snores."
	message_muzzled = "makes a noise."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound = SFX_SNORE

	statpanel_proc = /mob/proc/snore_emote

/datum/emote/snore/get_sfx_volume()
	return rand(15, 25)

/datum/emote/snore/get_impaired_msg(mob/user)
	return "clutches [P_THEIR(user.gender)] throat desperately!"

/mob/proc/snore_emote()
	set name = "Snore"
	set category = "Emotes"
	emote("snore", intentional = TRUE)


/datum/emote/sniff
	key = "sniff"

	message_1p = "You sniff."
	message_3p = "sniffs."

	message_impaired_production = "sniffs."
	message_impaired_reception = "sniffs."

	message_miming = "whimpers."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/sniff_emote

/mob/proc/sniff_emote()
	set name = "Sniff"
	set category = "Emotes"
	emote("sniff", intentional = TRUE)


/datum/emote/sigh
	key = "sigh"

	message_1p = "You sigh."
	message_3p = "sighs."

	message_impaired_production = "makes a weak noise."

	message_miming = "sighs."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_SIGH
	sound_human_male = SFX_MALE_SIGH

	statpanel_proc = /mob/proc/sigh_emote

/datum/emote/sigh/get_impaired_msg(mob/user)
	return "opens [P_THEIR(user.gender)] mouth."

/datum/emote/sigh/get_sfx_volume()
	return rand(30, 50)

/mob/proc/sigh_emote()
	set name = "Sigh"
	set category = "Emotes"
	emote("sigh", intentional = TRUE)


/datum/emote/mumble
	key = "mumble"

	message_1p = "You mumble."
	message_3p = "mumbles."

	message_impaired_production = "makes a weak noise."

	message_miming = "sighs."
	message_muzzled = "makes an annoyed face!"

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/mumble_emote

/datum/emote/mumble/get_impaired_msg(mob/user)
	return "opens and closes [P_THEIR(user.gender)] mouth."

/mob/proc/mumble_emote()
	set name = "Mumble"
	set category = "Emotes"
	emote("mumble", intentional = TRUE)


/datum/emote/grumble
	key = "grumble"

	message_1p = "You grumble."
	message_3p = "grumbles."

	message_impaired_production = "makes a weak noise."

	message_miming = "sighs."
	message_muzzled = "makes an annoyed face!"

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

/datum/emote/human/mumble/get_impaired_msg(mob/user)
	return "opens and closes [P_THEIR(user)] mouth."


/datum/emote/spit
	key = "spit"

	message_1p = "You spit tactlessly."
	message_3p = "spits tactlessly."

	message_impaired_production = "spits tactlessly."
	message_impaired_reception = "spits tactlessly."

	message_miming = "silently gathers invisible spittle and spits it out."
	message_muzzled = "tries to gather some spittle."

	message_type = AUDIBLE_MESSAGE

	pitch_age_variation = TRUE

	state_checks = EMOTE_CHECK_CONSCIOUS
	statpanel_proc = /mob/proc/spit_emote

/datum/emote/mumble/get_impaired_msg(mob/user)
	return "opens and closes [P_THEIR(user.gender)] mouth."

/mob/proc/spit_emote()
	set name = "Spit"
	set category = "Emotes"
	emote("spit", intentional = TRUE)


/datum/emote/yawn
	key = "yawn"

	message_1p = "You yawn."
	message_3p = "yawns."

	message_impaired_reception = "You hear someone yawn."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_YAWN
	sound_human_male = SFX_MALE_YAWN

	statpanel_proc = /mob/proc/yawn_emote

/datum/emote/yawn/get_sfx_volume()
	return rand(15, 30)

/mob/proc/yawn_emote()
	set name = "Yawn"
	set category = "Emotes"
	emote("yawn")

/datum/emote/chirp
	key = "chirp"

	message_1p = "You chirp."
	message_3p = "chirps!"

	message_type = AUDIBLE_MESSAGE

	sound = 'sound/misc/nymphchirp.ogg'

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/chirp_emote

/mob/proc/chirp_emote()
	set name = "Chirp"
	set category = "Emotes"
	emote("chirp")

/datum/emote/whistle
	key = "whistle"

	message_1p = "You whistle."
	message_3p = "whistles!"

	message_type = AUDIBLE_MESSAGE

	sound = SFX_WHISTLE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/whistle_emote

/datum/emote/whistle/get_sfx_volume()
	return 40

/mob/proc/whistle_emote()
	set name = "Whistle"
	set category = "Emotes"
	emote("whistle")
