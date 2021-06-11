GLOBAL_LIST_EMPTY(friend_list)
/mob/living/imaginary_friend
	name = "imaginary friend"
	real_name = "imaginary friend"
	desc = "A wonderful yet fake friend."
	density = 0
	alpha = 127
	plane = OBSERVER_PLANE
	invisibility = INVISIBILITY_OBSERVER
	see_invisible = SEE_INVISIBLE_OBSERVER
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS
	simulated = FALSE
	status_flags = GODMODE
	see_in_dark = 3 // human see_in_dark + 1, because of fun.
	stat = CONSCIOUS
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	see_invisible = SEE_INVISIBLE_LIVING
	invisibility = INVISIBILITY_MAXIMUM
	movement_handlers = list(/datum/movement_handler/mob/incorporeal, /datum/movement_handler/mob/friend)
	var/friend_type = "Not Defined"
	var/image/ghost_image
	var/mob/living/carbon/human/host // who contains the constr... Khem, imaginary friend
	var/mob/living/carbon/human/virtual_human // Fred Collon holder, use for get virtual clothes, virtual ID card, tl;dr icons
	var/friend_initialized = FALSE
	var/forced = FALSE // if True you can't delete imaginary_friend
	var/hidden = FALSE

	var/datum/action/imaginary_join/join
	var/datum/action/imaginary_hide/hide
	var/datum/action/imaginary_appearance/edit


/mob/living/imaginary_friend/Login()
	..()
	greet()
	Show()

/mob/living/imaginary_friend/Logout()
	..()
	addtimer(CALLBACK(src, .proc/reroll_friend), 1 MINUTE)

/mob/living/imaginary_friend/examine(mob/user, infix, suffix)
	. = ..()
	. += "\n[virtual_human?.examine()]"

/mob/living/imaginary_friend/Destroy()
	if(host.client)
		host.client.images.Remove(ghost_image)
	GLOB.friend_list.Remove(src)
	return ..()

/mob/living/imaginary_friend/proc/greet()
	to_chat(src, SPAN_NOTICE("<b>You are the imaginary friend of [host]!</b>\n\
	You are absolutely loyal to your friend, no matter what.\n\
	You cannot directly influence the world around you, but you can see what [host] cannot."))

/mob/living/imaginary_friend/say(message, datum/language/speaking = null, verb="says", alt_name="", whispering)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return

	friend_talk(message, speaking, verb, alt_name, whispering)

/mob/living/imaginary_friend/proc/friend_talk(message, datum/language/speaking = null, verb="says", alt_name="", whispering)
	message = capitalize(trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)))

	if(!message)
		return

	if(whispering)
		log_whisper("[name]/[key] : [message]")
		log_message(message, INDIVIDUAL_SAY_LOG)
	else
		log_say("[name]/[key] : [message]")
		log_message(message, INDIVIDUAL_SAY_LOG)

	var/rendered =      SPAN("game say", "[SPAN("name", "[name]")] [SPAN("message", "[say_quote(message, speaking)]")]")
	var/dead_rendered = SPAN("game say", "[SPAN("name", "[name] (Imaginary friend of [host])")] [SPAN("message", "[say_quote(message, speaking)]")]")

	to_chat(host, "[rendered]")
	to_chat(src, "[rendered]")

	//speech bubble
	if(host.client)
		var/speech_bubble_test = say_test(message)
		var/image/speech_bubble = image('icons/mob/talk.dmi',src,"h[speech_bubble_test]")
		speech_bubble.alpha = 0
		speech_bubble.plane = MOUSE_INVISIBLE_PLANE
		speech_bubble.layer = FLOAT_LAYER
		INVOKE_ASYNC(GLOBAL_PROC, /.proc/animate_speech_bubble, speech_bubble, list(host, src), 3 SECONDS)

	for(var/mob/observer/ghost/O in GLOB.ghost_mob_list)
		to_chat(O, "[ghost_follow_link(host, O)] [dead_rendered]")

/mob/living/imaginary_friend/Initialize(mob/living/carbon/human/H)
	. = ..()

	get_ghost()

	GLOB.friend_list.Add(src)
	host = H
	transfer_languages(host, src)
	setup_friend()

	join = new
	join.Grant(src)
	hide = new
	hide.Grant(src)
	edit = new
	edit.Grant(src)

/mob/living/imaginary_friend/forceMove(atom/destination)
	dir = get_dir(get_turf(src), destination)
	loc = destination
	Show()

/mob/living/imaginary_friend/proc/recall()
	if(!host || loc == host)
		return FALSE
	forceMove(host)
