/datum/flick_overlay/speech_bubble/New(image/image, list/client/show_to, time_to_live)
	. = ..()
	add_think_ctx("fade_bubble", CALLBACK(src, nameof(.proc/fade_bubble)), world.time + duration - 0.5 SECONDS)

/datum/flick_overlay/speech_bubble/proc/fade_bubble()
	animate(image, alpha = 0, time = 0.5 SECONDS, easing = EASE_IN)

/datum/flick_overlay/Destroy()
	remove_image_from_clients(image, seeing_clients)
	QDEL_NULL(image)
	seeing_clients.Cut()
	return ..()

/mob/living/proc/animate_speech_bubble(image/I, list/show_to, duration)
	flick_overlay(I, show_to, duration)

/// Returns the speech bubble image with an apropriate layer and plane set.
/mob/living/proc/create_speech_bubble_image(bubble_icon, bubble_icon_state, atom/source)
	var/image/speech_bubble = image('icons/mob/effects/talk.dmi', source, "[bubble_icon][bubble_icon_state]", FLOAT_LAYER)
	speech_bubble.appearance_flags |= APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART | TILE_BOUND
	return speech_bubble

/mob/living/proc/show_bubble_to_clients(bubble_icon, bubble_icon_state, atom/source, list/show_to)
	var/image/speech_bubble = create_speech_bubble_image(bubble_icon, bubble_icon_state, source)
	INVOKE_ASYNC(src, nameof(.proc/animate_speech_bubble), speech_bubble, show_to, 3 SECONDS)

/mob/living/proc/show_bubble_to_client(bubble_icon, bubble_icon_state, atom/source, client/show_to)
	show_bubble_to_clients(bubble_icon, bubble_icon_state, source, list(show_to))
