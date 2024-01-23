/mob/proc/target_emote(emote, min_range = null)
	var/datum/click_handler/handler = GetClickHandler()
	if(handler.type == /datum/click_handler/emotes/target_emote)
		show_splash_text(src, "Target selection canceled.")
		usr.PopClickHandler()
	else
		show_splash_text(src, "Select a target.")
		PushClickHandler(/datum/click_handler/emotes/target_emote, list(emote, min_range))

/mob/proc/prepare_target_emote(mob/living/target, parameters)
	var/emote = parameters[1]
	var/min_range = parameters[2]
	if(min_range != null && !(target in view(min_range)))
		to_chat(src, SPAN_WARNING("Target is too far."))
		return
	if(target != usr)
		usr.emote(emote, TRUE, target)
		return
	else
		usr.emote(emote, intentional = TRUE)
