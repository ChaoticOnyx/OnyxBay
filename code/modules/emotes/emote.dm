GLOBAL_LIST_INIT(all_emotes, list(); for(var/emotepath in subtypesof(/datum/emote)) all_emotes.Add(list(initial(emotepath["type"]) = new emotepath));)

#define MIN_VOICE_FREQUENCY 0.85
#define MAX_VOICE_FREQUENCY 1.05
#define EMOTE_DEFAULT_VOLUME 75

/datum/emote
	/// Default command to use emote ie. '*[key]'
	var/key

	/// 'laughs!' -> 'You laugh!'
	var/message_1p
	/// 'laughs!' -> 'Trottine Piggington laughs!'
	var/message_3p
	/// 'laughs silently.' -> 'Trottine Piggington laughs silently.'
	var/message_impaired_production
	/// For deaf/blind e.g. 'You hear someone laughing.'
	var/message_impaired_reception
	/// 'laughs!' -> 'Trottine Piggington acts out a laugh!'
	var/message_miming
	/// 'chokes!' -> 'makes a weak noise!'
	var/message_muzzled
	/// Audible/visual flag
	var/message_type = AUDIBLE_MESSAGE

	/// Range outside which emote is not shown
	var/emote_range = 7

	/// Sound produced (oink!)
	var/sound
	/// Sound for human with male gender. Prioritized over var/sound, e.g. if both variables are set this one will be used for sound production over var/sound.
	var/sound_human_male
	/// Similar as the previous var, but for gender == FEMALE
	var/sound_human_female
	/// Whether sound pitch varies with age.
	var/pitch_age_variation = FALSE

	/// What group does this emote belong to. By default uses emote type
	var/cooldown_group = null
	/// Cooldown for emote usage.
	var/cooldown = 1 SECOND
	/// Cooldown for the audio of the emote, if it has one.
	var/audio_cooldown = 3 SECONDS

	var/state_checks

	var/statpanel_proc = null

/datum/emote/proc/get_emote_message_1p(mob/user, target, additional_params)
	return "<i>[message_1p]</i>"

/datum/emote/proc/get_impaired_msg(mob/user)
	return (length(message_impaired_reception) > 0) ? message_impaired_reception : null

/datum/emote/proc/get_emote_message_3p(mob/living/user, target, additional_params)
	var/msg = message_3p
	var/mute = FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.silent > 0)
			mute = TRUE

	if(message_miming && mute)
		msg = message_miming
	else if(message_muzzled && istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
		msg = message_muzzled
	else if(message_impaired_production && (message_type & AUDIBLE_MESSAGE) && (user.silent || (user.sdisabilities & MUTE)))
		msg = message_impaired_production

	if(!msg)
		return null

	return msg

/datum/emote/proc/get_sound(mob/user, intentional)
	if(ishuman(user) && !isMonkey(user))
		if(!isnull(sound_human_female) && user.gender == FEMALE)
			return pick(sound_human_female)
		else if(!isnull(sound_human_male) && user.gender == MALE)
			return pick(sound_human_male)

	return sound

/// Override this in order (to get specific or random volume for example)
/datum/emote/proc/get_sfx_volume()
	return EMOTE_DEFAULT_VOLUME

/datum/emote/proc/get_cooldown_group()
	if(isnull(cooldown_group))
		return type

	return cooldown_group

/datum/emote/proc/check_cooldown(list/cooldowns, intentional)
	if(!cooldowns)
		return TRUE

	return cooldowns[get_cooldown_group()] < world.time

/datum/emote/proc/set_cooldown(list/cooldowns, value, intentional)
	LAZYSET(cooldowns, get_cooldown_group(), world.time + value)

/datum/emote/proc/play_sound(mob/user, intentional, emote_sound)
	var/sound_frequency = null
	if(pitch_age_variation && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/voice_frequency = TRANSLATE_RANGE(H.age, H.species.min_age, H.species.max_age, MIN_VOICE_FREQUENCY, MAX_VOICE_FREQUENCY)
		sound_frequency = MAX_VOICE_FREQUENCY - (voice_frequency - MIN_VOICE_FREQUENCY)

	playsound(user, emote_sound, get_sfx_volume(), frequency = sound_frequency)

/datum/emote/proc/can_emote(mob/user, intentional)
	if(!check_cooldown(user.next_emote_use, intentional))
		if(intentional)
			to_chat(user, SPAN_NOTICE("You can't emote so much, give it a rest."))
		return FALSE

	if((state_checks & EMOTE_CHECK_CONSCIOUS) && !emote_check_conscious(CONSCIOUS, user, intentional))
		return FALSE

	if((state_checks & EMOTE_CHECK_ONE_HAND_USABLE) && !is_one_hand_usable(user, intentional))
		return FALSE

	if((state_checks & EMOTE_CHECK_IS_HEAD_PRESENT) && !is_present_bodypart(BP_HEAD, user, intentional))
		return FALSE

	if((state_checks & EMOTE_CHECK_IS_SYNTH_OR_ROBOT) && !is_synth_or_robot(user, intentional))
		return FALSE

	if((state_checks & EMOTE_CHECK_ROBOT_SEC_MODULE) && !has_robot_module(/obj/item/robot_module/security, user, intentional))
		return FALSE

	if((state_checks & EMOTE_CHECK_CONSCIOUS_OR_NOT_INTENTIONAL) && !conscious_or_not_intentional(CONSCIOUS, user, intentional))
		return FALSE

	return TRUE

/datum/emote/proc/do_emote(mob/user, emote_key, intentional, target, additional_params)
	LAZYINITLIST(user.next_emote_use)
	set_cooldown(user.next_emote_use, cooldown, intentional)

	for(var/obj/item/implant/I in user)
		if(!I.implanted)
			continue
		I.trigger(emote_key, user)

	var/msg_1p = get_emote_message_1p(user, target, additional_params)
	var/text_3p = get_emote_message_3p(user, target, additional_params)
	var/msg_3p = text_3p ? "<b>[user]</b> [text_3p]" : null
	var/range = !isnull(emote_range) ? emote_range : world.view
	var/impaired_msg = get_impaired_msg(user)
	if(impaired_msg)
		if(message_type & VISIBLE_MESSAGE)
			impaired_msg = "<i>[impaired_msg]</i>"
		else if(message_type & AUDIBLE_MESSAGE)
			impaired_msg = "<b>[user]</b> [impaired_msg]"

	if(!msg_1p)
		msg_1p = msg_3p

	log_emote("[key_name(user)] : [msg_3p]")

	if(msg_3p)
		if(message_type & VISIBLE_MESSAGE)
			user.visible_message(message = msg_3p, self_message = msg_1p, blind_message = impaired_msg, range = range, checkghosts = /datum/client_preference/staff/ghost_sight)
		else if(message_type & AUDIBLE_MESSAGE)
			user.audible_message(message = msg_3p, self_message = msg_1p, deaf_message = impaired_msg, hearing_distance = range, checkghosts = /datum/client_preference/staff/ghost_sight)

	else if(msg_1p)
		to_chat(user, msg_1p)

	var/emote_sound = get_sound(user, intentional)
	if(emote_sound && can_play_sound(user, intentional))
		LAZYINITLIST(user.next_audio_emote_produce)
		set_cooldown(user.next_audio_emote_produce, audio_cooldown, intentional)
		play_sound(user, intentional, emote_sound)

/datum/emote/proc/can_play_sound(mob/user, intentional)
	if(user.is_muzzled())
		return FALSE

	if(isliving(user))
		var/mob/living/L = user
		if(L.silent)
			return FALSE

	if(!check_cooldown(user.next_audio_emote_produce, intentional))
		return FALSE

	return TRUE

#undef MIN_VOICE_FREQUENCY
#undef MAX_VOICE_FREQUENCY
#undef EMOTE_DEFAULT_VOLUME
