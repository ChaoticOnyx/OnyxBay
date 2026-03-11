/datum/emote/blink
	key = "blink"

	message_1p = "You blink."
	message_3p = "blinks."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/blink_emote

/mob/proc/blink_emote()
	set name = "Blink"
	set category = "Emotes"
	emote("blink", intentional = TRUE)


/datum/emote/blink_rapidly
	key = "blink_r"

	message_1p = "You blink rapidly."
	message_3p = "blinks rapidly."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_HEAD_PRESENT
	statpanel_proc = /mob/proc/blink_rapidly_emote

/mob/proc/blink_rapidly_emote()
	set name = "Blink (rapidly)"
	set category = "Emotes"
	emote("blink_r", intentional = TRUE)


/datum/emote/blush
	key = "blush"

	message_1p = "You blush."
	message_3p = "blushes."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/blush_emote

/mob/proc/blush_emote()
	set name = "Blush"
	set category = "Emotes"
	emote("blush", intentional = TRUE)


/datum/emote/pale
	key = "pale"

	message_1p = "You go pale for a second."
	message_3p = "goes pale for a second."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/pale_emote

/mob/proc/pale_emote()
	set name = "Pale"
	set category = "Emotes"
	emote("pale", intentional = TRUE)


/datum/emote/shiver
	key = "shiver"

	message_1p = "You shiver."
	message_3p = "shivers."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/shiver_emote

/mob/proc/shiver_emote()
	set name = "Shiver"
	set category = "Emotes"
	emote("shiver", intentional = TRUE)

#define SHIVER_LOOP_DURATION (1 SECONDS)
/datum/emote/shiver/do_emote(mob/user, emote_key, intentional, target, additional_params)
	. = ..()
	animate(user, pixel_x = 1, time = 0.1 SECONDS, tag = MOB_ANIM_SHIVER, flags = ANIMATION_RELATIVE)
	for(var/i in 1 to SHIVER_LOOP_DURATION / (0.2 SECONDS))
		animate(pixel_x = -1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
		animate(pixel_x = 1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
	animate(pixel_x = -1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
#undef SHIVER_LOOP_DURATION

/datum/emote/drool
	key = "drool"

	message_1p = "You drool."
	message_3p = "drools."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/drool_emote

/mob/proc/drool_emote()
	set name = "Drool"
	set category = "Emotes"
	emote("drool", intentional = TRUE)


/datum/emote/eyebrow
	key = "eyebrow"

	message_1p = "You raise an eyebrow."
	message_3p = "raises an eyebrow."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/eyebrow_emote

/mob/proc/eyebrow_emote()
	set name = "Eyebrow"
	set category = "Emotes"
	emote("eyebrow", intentional = TRUE)


/datum/emote/nod
	key = "nod"

	message_1p = "You nod."
	message_3p = "nods."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/nod_emote

/mob/proc/nod_emote()
	set name = "Nod"
	set category = "Emotes"
	emote("nod", intentional = TRUE)


/datum/emote/shake
	key = "shake"

	message_1p = "You shake your head."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/shake_emote


/datum/emote/shake/get_emote_message_3p(mob/user)
	return "shakes [P_THEIR(user.gender)] head."


/mob/proc/shake_emote()
	set name = "Shake"
	set category = "Emotes"
	emote("shake", intentional = TRUE)


/datum/emote/twitch
	key = "twitch"

	message_1p = "You twitch."
	message_3p = "twitches."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/twitch_emote

/mob/proc/twitch_emote()
	set name = "Twitch"
	set category = "Emotes"
	emote("twitch", intentional = TRUE)

/datum/emote/twitch/do_emote(mob/user, emote_key, intentional, target, additional_params)
	. = ..()
	animate(user, pixel_x = -1, time = 0.1 SECONDS, tag = MOB_ANIM_TWITCH, flags = ANIMATION_RELATIVE)
	animate(pixel_x = 1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
	animate(time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
	animate(pixel_x = -1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
	animate(pixel_x = 1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)

/datum/emote/twitch_violently
	key = "twitch_v"

	message_1p = "You twitch violently."
	message_3p = "twitches violently."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/twitch_violently_emote

/mob/proc/twitch_violently_emote()
	set name = "Twitch (violently)"
	set category = "Emotes"
	emote("twitch_v", intentional = TRUE)

/datum/emote/twitch_violently/do_emote(mob/user, emote_key, intentional, target, additional_params)
	. = ..()
	animate(user, pixel_x = -1, time = 0.1 SECONDS, tag = MOB_ANIM_TWITCH_V, flags = ANIMATION_RELATIVE)
	animate(pixel_x = 1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)

/datum/emote/tremble
	key = "tremble"

	message_1p = "You tremble!"
	message_3p = "trembles."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/tremble_emote

/mob/proc/tremble_emote()
	set name = "Tremble"
	set category = "Emotes"
	emote("tremble", intentional = TRUE)

#define TREMBLE_LOOP_DURATION (4.4 SECONDS)
/datum/emote/tremble/do_emote(mob/user, emote_key, intentional, target, additional_params)
	. = ..()
	animate(user, pixel_x = 2, time = 0.2 SECONDS, tag = MOB_ANIM_TREMBLE, flags = ANIMATION_RELATIVE)
	for(var/i in 1 to TREMBLE_LOOP_DURATION / (0.4 SECONDS))
		animate(pixel_x = -2, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE)
		animate(pixel_x = 2, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE)
	animate(pixel_x = -2, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE)
#undef TREMBLE_LOOP_DURATION

/datum/emote/collapse
	key = "collapse"

	message_1p = "You collapse!"
	message_3p = "collapses!"

	message_type = AUDIBLE_MESSAGE

	cooldown = 4 SECONDS

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/collapse_emote


/datum/emote/collapse/do_emote(mob/user, emote_key, intentional)
	. = ..()
	if(!intentional)
		user.Paralyse(2)

/mob/proc/collapse_emote()
	set name = "Collapse"
	set category = "Emotes"
	emote("collapse", intentional = TRUE)


/datum/emote/faint
	key = "faint"

	message_1p = "You faint!"
	message_3p = "faints!"

	message_type = AUDIBLE_MESSAGE

	cooldown = 20 SECONDS

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/faint_emote

/datum/emote/faint/do_emote(mob/user, emote_key, intentional)
	. = ..()
	if(!intentional && isliving(user))
		var/mob/living/L = user
		L.SetSleeping(10 SECONDS)

/mob/proc/faint_emote()
	set name = "Faint"
	set category = "Emotes"
	emote("faint", intentional = TRUE)


/datum/emote/deathgasp
	key = "deathgasp"

	message_1p = "You seize up and fall limp, your eyes dead and lifeless..."

	message_impaired_reception = "You hear a thud."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS_OR_NOT_INTENTIONAL

	statpanel_proc = /mob/proc/deathgasp

/datum/emote/deathgasp/get_emote_message_3p(mob/user)
	return "seizes up and falls limp, [P_THEIR(user.gender)] eyes dead and lifeless..."

/mob/proc/deathgasp()
	set name = "Deathgasp"
	set category = "Emotes"
	emote("deathgasp", intentional = TRUE)


/datum/emote/roll
	key = "roll"

	message_1p = "You roll."
	message_3p = "rolls."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/roll_emote

/mob/proc/roll_emote()
	set name = "Roll"
	set category = "Emotes"
	emote("roll", intentional = TRUE)


/datum/emote/jump
	key = "jump"

	message_1p = "You jump."
	message_3p = "jumps!"

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/jump_emote

/mob/proc/jump_emote()
	set name = "Jump"
	set category = "Emotes"
	emote("jump", intentional = TRUE)


/datum/emote/bow
	key = "bow"

	message_1p = "You bow."
	message_3p = "bows."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/bow_emote

/mob/proc/bow_emote()
	set name = "Bow"
	set category = "Emotes"
	emote("bow", intentional = TRUE)


/datum/emote/flap
	key = "flap"

	message_1p = "You flap your wings."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_HEAD_PRESENT

/datum/emote/flap/get_emote_message_3p(mob/user)
	return "flaps [P_THEIR(user)] wings."


/datum/emote/aflap
	key = "aflap"

	message_1p = "You flap your wings ANGRILY!."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_HEAD_PRESENT

/datum/emote/aflap/get_emote_message_3p(mob/user)
	return "flaps [P_THEIR(user)] wings ANGRILY!"


/datum/emote/frown
	key = "frown"

	message_1p = "You frown."
	message_3p = "frowns."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_HEAD_PRESENT
	statpanel_proc = /mob/proc/frown_emote

/mob/proc/frown_emote()
	set name = "Frown"
	set category = "Emotes"
	emote("frown", intentional = TRUE)


/datum/emote/grin
	key = "grin"

	message_1p = "You grin."
	message_3p = "grins."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_HEAD_PRESENT
	statpanel_proc = /mob/proc/grin_emote

/mob/proc/grin_emote()
	set name = "Grin"
	set category = "Emotes"
	emote("grin", intentional = TRUE)


/datum/emote/shrug
	key = "shrug"

	message_1p = "You shrug."
	message_3p = "shrugs."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/shrug_emote

/mob/proc/shrug_emote()
	set name = "Shrug"
	set category = "Emotes"
	emote("shrug", intentional = TRUE)


/datum/emote/smile
	key = "smile"

	message_1p = "You smile."
	message_3p = "smiles."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_HEAD_PRESENT
	statpanel_proc = /mob/proc/smile_emote

/mob/proc/smile_emote()
	set name = "Smile"
	set category = "Emotes"
	emote("smile", intentional = TRUE)


/datum/emote/wink
	key = "wink"

	message_1p = "You wink."
	message_3p = "winks."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_HEAD_PRESENT
	statpanel_proc = /mob/proc/wink_emote

/mob/proc/wink_emote()
	set name = "Wink"
	set category = "Emotes"
	emote("wink", intentional = TRUE)


/datum/emote/stare
	key = "stare"

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_HEAD_PRESENT

	statpanel_proc = /mob/proc/stare_emote

/datum/emote/stare/get_emote_message_1p(mob/user, target)
	if(!isnull(target))
		return "You stare at \the [target]."
	else
		return "You stare."

/datum/emote/stare/get_emote_message_3p(mob/living/user, target)
	if(!isnull(target))
		return "stares at \the [target]."
	else
		return "stares."

/mob/proc/stare_emote()
	set name = "Stare at"
	set category = "Emotes"
	target_emote("stare")


/datum/emote/look
	key = "look"

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_HEAD_PRESENT

	statpanel_proc = /mob/proc/look_emote

/datum/emote/look/get_emote_message_1p(mob/user, target)
	if(!isnull(target))
		return "You look at \the [target]."
	else
		return "You look."

/datum/emote/look/get_emote_message_3p(mob/living/user, target)
	if(!isnull(target))
		return "looks at \the [target]."
	else
		return "looks."

/mob/proc/look_emote()
	set name = "Look at"
	set category = "Emotes"
	target_emote("look")


/datum/emote/glare
	key = "glare"

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_IS_HEAD_PRESENT

	statpanel_proc = /mob/proc/glare_emote

/datum/emote/glare/get_emote_message_1p(mob/user, target)
	if(!isnull(target))
		return "You glare at \the [target]."
	else
		return "You glare."

/datum/emote/glare/get_emote_message_3p(mob/living/user, target)
	if(!isnull(target))
		return "glare at \the [target]."
	else
		return "glare."

/mob/proc/glare_emote()
	set name = "Glare at"
	set category = "Emotes"
	target_emote("glare")

/datum/emote/scratch
	key = "scratch"

	message_1p = "You scratch."
	message_3p = "scrathes."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/scratch_emote

/mob/proc/scratch_emote()
	set name = "Scratch"
	set category = "Emotes"
	emote("scratch", intentional = TRUE)

/datum/emote/sway
	key = "sway"

	message_1p = "You sway."
	message_3p = "sways around dizzily.."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/sway_emote

/mob/proc/sway_emote()
	set name = "Sway"
	set category = "Emotes"
	emote("sway", intentional = TRUE)

/datum/emote/sway/do_emote(mob/user, emote_key, intentional, target, additional_params)
	. = ..()
	animate(user, pixel_x = 2, time = 0.5 SECONDS, tag = MOB_ANIM_SWAY, flags = ANIMATION_RELATIVE)
	for(var/i in 1 to 2)
		animate(pixel_x = -4, time = 1.0 SECONDS, flags = ANIMATION_RELATIVE)
		animate(pixel_x = 4, time = 1.0 SECONDS, flags = ANIMATION_RELATIVE)
	animate(pixel_x = -2, time = 0.5 SECONDS, flags = ANIMATION_RELATIVE)

/datum/emote/sulk
	key = "sulk"

	message_1p = "You sulk."
	message_3p = "sulks down sadly."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/sulk_emote

/mob/proc/sulk_emote()
	set name = "Sulk"
	set category = "Emotes"
	emote("sulk", intentional = TRUE)

/datum/emote/hiss
	key = "hiss"

	message_1p = "You hiss."
	message_3p = "hisses softly."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/hiss_emote

/mob/proc/hiss_emote()
	set name = "Hiss"
	set category = "Emotes"
	emote("hiss", intentional = TRUE)


/datum/emote/deathgasp_alien
	key = "deathgasp"

	message_1p = "You seize up and fall limp, your eyes dead and lifeless..."
	message_3p = "lets out a waning guttural screech, green blood bubbling from its maw."

	message_impaired_reception = "You hear a thud."

	message_type = AUDIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS_OR_NOT_INTENTIONAL

	statpanel_proc = /mob/proc/deathgasp

/datum/emote/vomit
	key = "vomit"

	message_type = AUDIBLE_MESSAGE

	statpanel_proc = /mob/proc/vomit_emote

/datum/emote/vomit/get_emote_message_1p(mob/user, target, additional_params)
	return null

/datum/emote/vomit/get_emote_message_3p(mob/living/user, target, additional_params)
	return null

/datum/emote/vomit/do_emote(mob/user, emote_key, intentional)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(istype(H))
		H.vomit()

/mob/proc/vomit_emote()
	set name = "Vomit"
	set category = "Emotes"
	emote("vomit", intentional = TRUE)

/datum/emote/signal
	key = "signal"

	message_1p = "You signal."
	message_3p = "signals."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/signal_emote

/datum/emote/signal/get_emote_message_1p(mob/user, target, additional_params)
	var/t1 = round(text2num(additional_params))
	if(isnum(t1) && t1 <= 5 && t1 > 0)
		return "You raise [t1] finger\s"
	else return message_1p

/datum/emote/signal/get_emote_message_3p(mob/living/user, target, additional_params)
	var/t1 = round(text2num(additional_params))
	if(isnum(t1) && t1 <= 5 && t1 > 0)
		return "raises [t1] finger\s"
	else return message_3p

/mob/proc/signal_emote()
	set name = "Signal"
	set category = "Emotes"
	var/fingers_raised = tgui_input_number(src, "Choose how many fingers to raise.", "Signal", max_value = 5, min_value = 0)
	emote("signal [fingers_raised]", intentional = TRUE)
