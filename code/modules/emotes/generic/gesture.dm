/datum/emote/airguitar
	key = "airguitar"

	message_1p = "You play an imaginary guitar!"
	message_3p = "is strumming the air and headbanging like a safari chimp."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/airguitar_emote

/mob/proc/airguitar_emote()
	set name = "Airguitar"
	set category = "Emotes"
	emote("airguitar", intentional = TRUE)


/datum/emote/dap
	key = "dap"

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

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
	target_emote("dap", max_range = 1)


/datum/emote/dance
	key = "dance"

	message_type = VISIBLE_MESSAGE

	cooldown = 0.5 SECONDS

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/proc/dance_emote

	var/list/mob/dancing = list()

/datum/emote/dance/do_emote(mob/user, emote_key, intentional)
	LAZYINITLIST(user.next_emote_use)
	set_cooldown(user.next_emote_use, cooldown, intentional)
	log_emote("[key_name(user)] : dances")
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
	emote("dance", intentional = TRUE)


/datum/emote/clap
	key = "clap"

	message_1p = "You clap."
	message_3p = "claps."

	message_impaired_reception = "You hear someone clapping."

	message_type = VISIBLE_MESSAGE

	sound = SFX_CLAP

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_ONE_HAND_USABLE

	statpanel_proc = /mob/proc/clap_emote

/datum/emote/clap/get_sfx_volume()
	return rand(25, 35)

/datum/emote/clap/do_emote(mob/user, emote_key, intentional, target, additional_params)
	. = ..()

	if(rand(0, 5000))
		return

	var/area/A = get_area(user)
	if(!istype(A))
		return

	A.set_lightswitch(!A.lightswitch)

/mob/proc/clap_emote()
	set name = "Clap"
	set category = "Emotes"
	emote("clap", intentional = TRUE)


/datum/emote/wave
	key = "wave"

	message_1p = "You wave your hand."
	message_3p = "waves."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_ONE_HAND_USABLE

	statpanel_proc = /mob/proc/wave_emote

/mob/proc/wave_emote()
	set name = "Wave"
	set category = "Emotes"
	emote("wave", intentional = TRUE)


/datum/emote/salute
	key = "salute"

	message_1p = "You salute."
	message_3p = "salutes."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_ONE_HAND_USABLE

	statpanel_proc = /mob/proc/salute_emote

/mob/proc/salute_emote()
	set name = "Salute"
	set category = "Emotes"
	emote("salute", intentional = TRUE)


/datum/emote/raise
	key = "raise"

	message_1p = "You raise your hand."

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS | EMOTE_CHECK_ONE_HAND_USABLE

	statpanel_proc = /mob/proc/raise_emote

/datum/emote/raise/get_emote_message_3p(mob/user)
	return "raises [P_THEIR(user.gender)] hand."

/mob/proc/raise_emote()
	set name = "Raise"
	set category = "Emotes"
	emote("raise")


/datum/emote/hug
	key = "hug"

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

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
	target_emote("hug", max_range = 1)

/datum/emote/handshake
	key = "handshake"

	message_type = VISIBLE_MESSAGE

	state_checks = EMOTE_CHECK_CONSCIOUS

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
	set name = "Handshake"
	set category = "Emotes"
	target_emote("handshake", max_range = 1)

/mob/living/carbon/human/proc/push_up_emote()
	set name = "Push-up"
	set category = "Emotes"
	emote("push_up", intentional = TRUE)

/datum/emote/push_up
	key = "push_up"

	message_type = VISIBLE_MESSAGE

	cooldown = 2 SECONDS

	state_checks = EMOTE_CHECK_CONSCIOUS

	statpanel_proc = /mob/living/carbon/human/proc/push_up_emote

/datum/emote/push_up/can_emote(mob/living/carbon/human/user, intentional)
	if(user.push_ups)
		return FALSE
	return ..(user, intentional)

/datum/emote/push_up/do_emote(mob/user, emote_key, intentional, target, additional_params)
	LAZYINITLIST(user.next_emote_use)
	set_cooldown(user.next_emote_use, cooldown, intentional)
	user.visible_message("<i><b>[user]</b> drops to the floor and starts doing push-ups.</i>",
						 "<i>You drop to the floor and start doing push-ups.</i>")
	log_emote("[key_name(user)] : push ups")
	INVOKE_ASYNC(src, nameof(.proc/push_up), user)

/datum/emote/push_up/proc/push_up(mob/living/carbon/human/user)
	var/datum/push_up/P = new(user)

	user.dir = 4
	user.set_resting(TRUE)
	user.push_ups = TRUE
	user.update_transform()

	sleep(20)
	animate(user, time = 10, pixel_y = 5)
	sleep(10)

	var/body_build_mult = P.get_body_build_mult()
	var/oldpixely = user.pixel_y
	while(!P.interrupted && user.resting && !user.buckled && !user.stat)
		var/mult = P.get_mult() * body_build_mult + rand(-1, 1) / 100
		if(!P.down)
			animate(user, time = 10 * mult, pixel_y = oldpixely - 10)
		else
			P.times += 1

			if(mult >= 2 && prob(mult * 10))
				user.pixel_y = 0
				user.push_ups = FALSE
				user.visible_message(FONT_LARGE("<i><b>[user] clumsily falls in an attempt to do \his [P.times] push-up.</b></i>"),
									FONT_LARGE("<i><b>You clumsily fall in an attempt to do your [P.times] push-up.</b></i>"))
				playsound(user.loc, 'sound/effects/bangtaper.ogg', 50, 1, -1)
				return

			animate(user, time = 10 * mult, pixel_y = oldpixely)

			if(P.times % 10 == 0)
				user.visible_message("<i><b>[user]</b> has done \his <b>[P.times]</b> push-up!</i>",
									 "<i>You've done your <b>[P.times]</b> push-up!</i>", checkghosts = FALSE)
			user.remove_nutrition(1)
			user.remove_hydration(5.0)

		P.down = !P.down
		sleep(12 * mult)

	if(P.times)
		user.visible_message("<i><b>[user]</b> stops \his exercise at <b>[P.times]</b> push-ups.</i>",
							 "<i>You stop your exercise at <b>[P.times]</b> push-ups.</i>")

	user.pixel_y = 0
	user.push_ups = FALSE

/datum/push_up
	var/mob/living/carbon/human/user = null
	var/times = 0
	var/down = FALSE
	var/interrupted = FALSE

/datum/push_up/New(mob/living/carbon/human/user)
	src.user = user

	register_signal(user, SIGNAL_MOVED, nameof(.proc/interrupt))
	register_signal(user, SIGNAL_DIR_SET, nameof(.proc/interrupt))

/datum/push_up/proc/interrupt()
	interrupted = TRUE

	unregister_signal(user, SIGNAL_MOVED)
	unregister_signal(user, SIGNAL_DIR_SET)

/datum/push_up/proc/get_mult()
	. = 1

	if(user.full_pain && !user.no_pain)
		. *= 1 + user.full_pain / 100

	if(user.nutrition > STOMACH_FULLNESS_SUPER_HIGH)
		. *= 1 + (user.nutrition - STOMACH_FULLNESS_SUPER_HIGH) / 400

	else if(user.nutrition <= STOMACH_FULLNESS_SUPER_LOW)
		. *= 1 + (STOMACH_FULLNESS_SUPER_LOW - user.nutrition) / 100

	if(user.reagents.has_reagent(/datum/reagent/hyperzine))
		. *= 0.2

	else if(user.reagents.has_reagent(/datum/reagent/adrenaline))
		. *= 0.8

/datum/push_up/proc/get_body_build_mult()
	if(istype(user.body_build, /datum/body_build/slim))
		return 2

	else if(istype(user.body_build, /datum/body_build/fat) || istype(user.body_build, /datum/body_build/tajaran/fat))
		return 3

	return 1
