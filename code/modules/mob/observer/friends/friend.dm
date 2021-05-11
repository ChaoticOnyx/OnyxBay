/mob/observer/imaginary_friend
	name = "imaginary friend"
	real_name = "imaginary friend"
	move_on_shuttle = TRUE
	desc = "A wonderful yet fake friend."
	see_in_dark = 3 // human see_in_dark + 1, because of fun.
	sight = NONE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	see_invisible = SEE_INVISIBLE_LIVING
	invisibility = INVISIBILITY_MAXIMUM
	movement_handlers = list(/datum/movement_handler/mob/incorporeal, /datum/movement_handler/mob/friend)
	var/mob/living/carbon/human/host // who contains the constr... Khem, imaginary friend
	var/mob/living/carbon/human/virtual_human // Fred Collon holder, use for get virtual clothes, virtual ID card, tl;dr icons
	var/friend_initialized = FALSE
	var/forced = FALSE // if True you can't delete imaginary_friend

/mob/observer/imaginary_friend/Login()
	..()
	greet()
	Show()

/mob/observer/imaginary_friend/proc/get_ghost()
	set waitfor = FALSE
	if(owner.stat == DEAD)
		qdel(src)
		return

/mob/observer/imaginary_friend/Destroy()
	if(owner.client)
		owner.client.images.Remove(ghost_image)
	return ..()

/mob/observer/imaginary_friend/proc/greet()
	to_chat(src, SPAN_NOTICE("<b>You are the imaginary friend of [owner]!</b>\n\
	You are absolutely loyal to your friend, no matter what.\n\
	You cannot directly influence the world around you, but you can see what [owner] cannot."))

/mob/observer/imaginary_friend/say(message, datum/language/speaking = null, verb="says", alt_name="", whispering)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return

	friend_talk(message, speaking, verb, alt_name, whispering)

/mob/observer/imaginary_friend/proc/friend_talk(message, datum/language/speaking = null, verb="says", alt_name="", whispering)
	message = capitalize(trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)))

	if(!message)
		return

	log_say("[name]/[key] (Friend) : [message]")
	log_message(message, INDIVIDUAL_SAY_LOG)

	var/rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[say_quote(message)]</span></span>"
	var/dead_rendered = "<span class='game say'><span class='name'>[name] (Imaginary friend of [owner])</span> <span class='message'>[say_quote(message)]</span></span>"

	to_chat(owner, "[rendered]")
	to_chat(src, "[rendered]")

	//speech bubble
	if(owner.client)
		var/speech_bubble_test = say_test(message)
		var/image/speech_bubble = image('icons/mob/talk.dmi',src,"h[speech_bubble_test]")
		speech_bubble.alpha = 0
		speech_bubble.plane = MOUSE_INVISIBLE_PLANE
		speech_bubble.layer = FLOAT_LAYER
		INVOKE_ASYNC(GLOBAL_PROC, /.proc/animate_speech_bubble, speech_bubble, speech_bubble_recipients, 3 SECONDS)

	say_dead(message)

/mob/observer/imaginary_friend/New(mob/living/carbon/human/H)
	. = ..()

	owner = H
	transfer_languages(owner, src)
	setup_friend()

/mob/observer/imaginary_friend/forceMove(atom/destination)
	dir = get_dir(get_turf(src), destination)
	loc = destination
	Show()

/mob/observer/imaginary_friend/proc/recall()
	if(!owner || loc == owner)
		return FALSE
	forceMove(owner)
