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
	sound_human_female = SFX_FEMALE_WHIMPER
	sound_human_male = SFX_MALE_WHIMPER

	statpanel_proc = /mob/proc/whimper_emote

/mob/proc/whimper_emote()
	set name = "Whimper"
	set category = "Noises"
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
	set category = "Noises"
	emote("gasp", intentional = TRUE)


/datum/emote/gag
	key = "gag"

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_GAG
	sound_human_male = SFX_MALE_GAG

	statpanel_proc = /mob/proc/gag_emote

/datum/emote/gag/get_sfx_volume()
	return rand(40, 50)

/mob/proc/gag_emote()
	set name = "Gag"
	set category = "Noises"
	emote("gag", intentional = TRUE)


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
	set category = "Noises"
	emote("sneeze", intentional = TRUE)


/datum/emote/burp
	key = "burp"

	message_1p = "You burp."
	message_3p = "burps."

	message_impaired_production = "makes a noise."

	message_miming = "burps."
	message_muzzled = "makes a noise."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_BURP
	sound_human_male = SFX_MALE_BURP

	statpanel_proc = /mob/proc/burp_emote

/datum/emote/burp/get_impaired_msg(mob/user)
	return "makes a noise!"

/datum/emote/burp/get_sfx_volume()
	return rand(25, 45)

/mob/proc/burp_emote()
	set name = "Burp"
	set category = "Noises"
	emote("burp", intentional = TRUE)

/datum/emote/choke
	key = "choke"

	message_1p = "You choke."
	message_3p = "chokes."

	message_impaired_production = "makes a weak noise."

	message_miming = "chokes."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_CHOKE
	sound_human_male = SFX_MALE_CHOKE

	statpanel_proc = /mob/proc/choke_emote

/datum/emote/choke/get_impaired_msg(mob/user)
	return "clutches [P_THEIR(user.gender)] throat desperately!"

/datum/emote/choke/get_sfx_volume()
	return rand(25, 45)

/mob/proc/choke_emote()
	set name = "Choke"
	set category = "Noises"
	emote("choke", intentional = TRUE)


/datum/emote/clearthroat
	key = "clearthroat"

	message_1p = "You clear your throat."
	message_3p = "clears their throat."

	message_impaired_production = "makes a muffled noise."

	message_miming = "clears throat."
	message_muzzled = "makes a muffled noise."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_CLEARHTROAT
	sound_human_male = SFX_MALE_CLEARHTROAT

	statpanel_proc = /mob/proc/clearthroat_emote

/datum/emote/clearthroat/get_impaired_msg(mob/user)
	return "makes a muffled noise!"

/datum/emote/clearthroat/get_sfx_volume()
	return rand(25, 45)

/mob/proc/clearthroat_emote()
	set name = "Clearthroat"
	set category = "Noises"
	emote("clearthroat", intentional = TRUE)


/datum/emote/chuckle
	key = "chuckle"

	message_1p = "You chuckle."
	message_3p = "chuckles."

	message_impaired_production = "makes a weak noise."

	message_miming = "appears to be chuckling."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_CHUCKLE
	sound_human_male = SFX_MALE_CHUCKLE

	statpanel_proc = /mob/proc/chuckle_emote

/datum/emote/chuckle/get_impaired_msg(mob/user)
	return "clutches [P_THEIR(user.gender)] throat!"

/datum/emote/chuckle/get_sfx_volume()
	return rand(25, 40)

/mob/proc/chuckle_emote()
	set name = "Chuckle"
	set category = "Noises"
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


/datum/emote/painmoan
	key = "painmoan"

	message_1p = "You moan in pain!"
	message_3p = "moans in pain!"

	message_impaired_production = "moans in pain, silently."

	sound_human_female = SFX_FEMALE_PAINMOAN
	sound_human_male = SFX_MALE_PAINMOAN

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/painmoan_emote

/datum/emote/moan/get_impaired_msg(mob/user)
	return "makes a muffled sound"

/mob/proc/painmoan_emote()
	set name = "Moan (pain)"
	set category = "Emotes"
	emote("painmoan", intentional = TRUE)


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
	set category = "Noises"
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
	return rand(40, 55)

/mob/proc/cry_emote()
	set name = "Cry"
	set category = "Noises"
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
	set category = "Noises"
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
	return rand(50, 70)

/mob/proc/scream_long_emote()
	set name = "Scream (long)"
	set category = "Noises"
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
	set category = "Noises"
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
	set category = "Noises"
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

	sound_human_female = SFX_FEMALE_GIGGLE
	sound_human_male = SFX_MALE_LAUGH // Sadly, I had to leave it as is. Hopefully someone will find the right SFX. ~Filatelele.

	statpanel_proc = /mob/proc/giggle_emote

/datum/emote/giggle/get_impaired_msg(mob/user)
	return "opens and closes [P_THEIR(user.gender)] mouth slightly, smiling."

/datum/emote/giggle/get_sfx_volume()
	return rand(25, 35)

/mob/proc/giggle_emote()
	set name = "Giggle"
	set category = "Noises"
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
	set category = "Noises"
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

	sound_human_female = SFX_FEMALE_GROAN
	sound_human_male = SFX_MALE_GROAN

	statpanel_proc = /mob/proc/groan_emote

/datum/emote/groan/get_impaired_msg(mob/user)
	return "opens [P_THEIR(user.gender)] mouth slightly."

/datum/emote/groan/get_sfx_volume()
	return rand(25, 40)

/mob/proc/groan_emote()
	set name = "Groan"
	set category = "Noises"
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
	set category = "Noises"
	emote("hiccup", intentional = TRUE)

/datum/emote/hum
	key = "hum"

	message_1p = "You hum."
	message_3p = "hums."

	message_impaired_production = "makes a noise."

	message_miming = "hums."
	message_muzzled = "makes a noise."

	message_type = AUDIBLE_MESSAGE

	sound_human_female = SFX_FEMALE_HUM
	sound_human_male = SFX_MALE_HUM

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/hum_emote

/datum/emote/hum/get_sfx_volume()
	return rand(40, 50)

/mob/proc/hum_emote()
	set name = "Hum"
	set category = "Noises"
	emote("hum", intentional = TRUE)


/datum/emote/huh
	key = "huh"

	message_1p = "You huh."
	message_3p = "huhs."

	message_impaired_production = "makes a noise."

	message_miming = "huhs."
	message_muzzled = "makes a noise."

	message_type = AUDIBLE_MESSAGE

	sound_human_female = SFX_FEMALE_HUH
	sound_human_male = SFX_MALE_HUH

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/huh_emote

/datum/emote/huh/get_sfx_volume()
	return rand(40, 50)

/mob/proc/huh_emote()
	set name = "Huh"
	set category = "Noises"
	emote("huh", intentional = TRUE)


/datum/emote/hmm
	key = "hmm"

	message_1p = "You hmm."
	message_3p = "hmms."

	message_impaired_production = "makes a noise."

	message_miming = "hmms."
	message_muzzled = "makes a noise."

	message_type = AUDIBLE_MESSAGE

	sound_human_female = SFX_FEMALE_HMM
	sound_human_male = SFX_MALE_HMM

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/hmm_emote

/mob/proc/hmm_emote()
	set name = "Hmm"
	set category = "Noises"
	emote("hmm", intentional = TRUE)


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
	set category = "Noises"
	emote("snore", intentional = TRUE)

/datum/emote/shh
	key = "shh"

	message_1p = "You shhs."
	message_3p = "shhs."

	message_impaired_production = "makes a weak noise."

	message_miming = "shooshes."
	message_muzzled = "makes a weak noise."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	sound_human_female = SFX_FEMALE_SHH
	sound_human_male = SFX_MALE_SHH

	statpanel_proc = /mob/proc/shh_emote

/mob/proc/shh_emote()
	set name = "Shh"
	set category = "Noises"
	emote("shh", intentional = TRUE)

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
	set category = "Noises"
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
	set category = "Noises"
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
	sound_human_female = SFX_FEMALE_WHISTLE
	sound_human_male = SFX_MALE_WHISTLE

	state_checks = EMOTE_CHECK_CONSCIOUS

	cooldown = 5 SECONDS
	audio_cooldown = 5 SECONDS

	statpanel_proc = /mob/proc/whistle_emote

/datum/emote/whistle/get_sfx_volume()
	return 40

/mob/proc/whistle_emote()
	set name = "Whistle"
	set category = "Noises"
	emote("whistle")


/datum/emote/attnwhistle
	key = "attnwhistle"

	message_1p = "You whistle."
	message_3p = "whistles!"

	message_type = AUDIBLE_MESSAGE

	sound = SFX_WHISTLE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/attnwhistle_emote

/datum/emote/whistle/get_sfx_volume()
	return 40

/mob/proc/attnwhistle_emote()
	set name = "Attnwhistle"
	set category = "Noises"
	emote("attnwhistle")


/datum/emote/fatigue
	key = "fatigue"

	message_type = AUDIBLE_MESSAGE

	sound_human_female = SFX_FEMALE_FATIGUE
	sound_human_male = SFX_MALE_FATIGUE

	state_checks = EMOTE_CHECK_CONSCIOUS

	cooldown = 2.5 SECONDS
	audio_cooldown = 3 SECONDS

	statpanel_proc = /mob/proc/fatigue_emote

/datum/emote/fatigue/get_sfx_volume()
	return rand(40, 50)

/mob/proc/fatigue_emote()
	set name = "Fatigue"
	set category = "Noises"
	emote("fatigue")


/datum/emote/psst
	key = "psst"

	message_type = AUDIBLE_MESSAGE

	sound = SFX_PSST

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/psst_emote

/mob/proc/psst_emote()
	set name = "Psst"
	set category = "Noises"
	emote("psst")
