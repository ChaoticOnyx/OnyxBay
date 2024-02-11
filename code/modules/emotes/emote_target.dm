/mob/proc/target_emote(emote, max_range = 7)
	var/datum/click_handler/handler = GetClickHandler()
	if(handler.type == /datum/click_handler/emotes/target_emote)
		to_chat(src, "Target selection canceled.")
		usr.PopClickHandler()
	else
		to_chat(src, "Select a target.")
		PushClickHandler(/datum/click_handler/emotes/target_emote, list(emote, max_range))

/mob/proc/prepare_target_emote(mob/living/target, parameters)
	var/emote = parameters[1]
	var/max_range = parameters[2]
	if(max_range != null && !(target in view(max_range)))
		to_chat(src, SPAN_WARNING("Target is too far."))
		return
	if(target != usr)
		usr.emote(emote, TRUE, target)
		return
	else
		usr.emote(emote, intentional = TRUE)
