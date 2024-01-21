/datum/emote/airguitar
	key = "airguitar"

	message_1p = "You are strumming the air and headbanging like a safari chimp!"
	message_3p = "is strumming the air and headbanging like a safari chimp."

	message_type = VISIBLE_MESSAGE

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS)
	)

	statpanel_proc = /mob/proc/airguitar_emote

/mob/proc/airguitar_emote()
	set name = "Airguitar"
	set category = "Emotes"
	usr.emote("airguitar", intentional = TRUE)


/datum/emote/dap
	key = "dap"

	message_type = VISIBLE_MESSAGE

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS)
	)

	statpanel_proc = /mob/proc/dap_emote

/datum/emote/dap/get_emote_message_1p(mob/user, target)
	if(!isnull(target))
		return "You give daps to \the [target]"
	else
		return "You give daps to yourself!"

/datum/emote/dap/get_emote_message_3p(mob/user, target)
	if(!isnull(target))
		return "gives daps to \the [target]"
	else
		return "sadly can't find anybody to give daps to, and daps themselves"

/mob/proc/dap_emote()
	set name = "Dap"
	set category = "Emotes"
	target_emote("dap")


/datum/emote/dance
	key = "dance"

	message_1p = "You dances!"
	message_3p = "dances around."

	message_type = VISIBLE_MESSAGE

	cooldown = 5 SECONDS

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

	statpanel_proc = /mob/proc/dance_emote

	var/list/mob/dancing = list()

/datum/emote/dance/do_emote(mob/user, emote_key, intentional)
	. = ..()
	INVOKE_ASYNC(src, nameof(.proc/dance), user)

/datum/emote/dance/proc/dance(mob/user)
	if(weakref(user) in dancing)
		dancing.Remove(weakref(user))
		return

	dancing.Add(weakref(user))
	user.pixel_y = initial(user.pixel_y)
	var/oldpixely = user.pixel_y
	while(weakref(user) in dancing)
		var/pixely = rand(5, 6)
		animate(user, pixel_y = pixely, time = 0.5)
		sleep(1)
		animate(user, pixel_y = oldpixely, time = 0.7)
		sleep(2)
		animate(user, pixel_y = 2, time = 0.2)
		sleep(1)
		animate(user, pixel_y = oldpixely, time = 0.2)
		if(user.resting || user.buckled || user.is_ic_dead())
			dancing.Remove(weakref(user))
			break

/mob/proc/dance_emote()
	set name = "Dance"
	set category = "Emotes"
	usr.emote("dance", intentional = TRUE)


/datum/emote/clap
	key = "clap"

	message_1p = "You clap."
	message_3p = "claps."

	message_impaired_reception = "You hear someone clapping."

	message_type = VISIBLE_MESSAGE

	sound = SFX_CLAP

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable)
	)

	statpanel_proc = /mob/proc/clap_emote

/mob/proc/clap_emote()
	set name = "Clap"
	set category = "Emotes"
	usr.emote("clap", intentional = TRUE)


/datum/emote/wave
	key = "wave"

	message_1p = "You wave your hand."
	message_3p = "waves."

	message_type = VISIBLE_MESSAGE

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable)
	)

	statpanel_proc = /mob/proc/wave_emote

/mob/proc/wave_emote()
	set name = "Wave"
	set category = "Emotes"
	usr.emote("wave", intentional = TRUE)


/datum/emote/salute
	key = "salute"

	message_1p = "You salute."
	message_3p = "salutes."

	message_type = VISIBLE_MESSAGE

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable)
	)

	statpanel_proc = /mob/proc/salute_emote

/mob/proc/salute_emote()
	set name = "Salute"
	set category = "Emotes"
	usr.emote("salute", intentional = TRUE)


/datum/emote/raise
	key = "raise"

	message_1p = "You raise your hand."

	message_type = VISIBLE_MESSAGE

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable)
	)

	statpanel_proc = /mob/proc/raise_emote

/datum/emote/raise/get_emote_message_3p(mob/user)
	return "raises [P_THEIR(user.gender)] hand."

/mob/proc/raise_emote()
	set name = "Raise"
	set category = "Emotes"
	usr.emote("raise")


/datum/emote/hug
	key = "hug"

	message_type = VISIBLE_MESSAGE

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS)
	)

	statpanel_proc = /mob/proc/hug_emote

/datum/emote/hug/get_emote_message_1p(mob/user, target)
	if(!isnull(target))
		return "You hug \the [target]"
	else
		return "You hug yourself."

/datum/emote/hug/get_emote_message_3p(mob/user, target)
	if(!isnull(target))
		return "hugs \the [target]"
	else
		return "hugs themselves."

/mob/proc/hug_emote()
	set name = "Hug"
	set category = "Emotes"
	target_emote("hug")

/datum/emote/handshake
	key = "handshake"

	message_type = VISIBLE_MESSAGE

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS)
	)

	statpanel_proc = /mob/proc/handshake_emote

/datum/emote/handshake/get_emote_message_1p(mob/user, target)
	if(!isnull(target))
		return "You shake hands with \the [target]"
	else
		return "You shake hands with yourself."

/datum/emote/handshake/get_emote_message_3p(mob/user, target)
	if(!isnull(target))
		return "shakes hands with \the [target]"

/mob/proc/handshake_emote()
	set name = "handshake"
	set category = "Emotes"
	target_emote("handshake")
