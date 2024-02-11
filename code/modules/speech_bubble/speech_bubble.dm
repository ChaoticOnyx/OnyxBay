/proc/fade_out_speech_bubble(image/I, list/remove_from)
	animate(I, alpha = 0, time = 0.5 SECONDS, easing = EASE_IN)
	addtimer(CALLBACK(GLOBAL_PROC, /proc/remove_image_from_clients, I, remove_from), 0.5 SECONDS)

/proc/animate_speech_bubble(image/I, list/show_to, duration)
	add_image_to_clients(I, show_to)
	addtimer(CALLBACK(GLOBAL_PROC, /proc/fade_out_speech_bubble, I, show_to), duration - 0.5 SECONDS)

/// Returns the speech bubble image with an apropriate layer and plane set.
/proc/create_speech_bubble_image(bubble_icon, bubble_icon_state, atom/source)
	var/image/speech_bubble = image('icons/mob/effects/talk.dmi', source, "[bubble_icon][bubble_icon_state]", FLOAT_LAYER)
	speech_bubble.appearance_flags |= APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART | TILE_BOUND
	return speech_bubble

/proc/show_bubble_to_clients(bubble_icon, bubble_icon_state, atom/source, list/show_to)
	var/image/speech_bubble = create_speech_bubble_image(bubble_icon, bubble_icon_state, source)
	INVOKE_ASYNC(GLOBAL_PROC, /proc/animate_speech_bubble, speech_bubble, show_to, 3 SECONDS)

/proc/show_bubble_to_client(bubble_icon, bubble_icon_state, atom/source, client/show_to)
	show_bubble_to_clients(bubble_icon, bubble_icon_state, source, list(show_to))
