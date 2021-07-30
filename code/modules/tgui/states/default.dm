/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui state: default_state
 *
 * Checks a number of things -- mostly physical distance for humans
 * and view for robots.
 */

GLOBAL_DATUM_INIT(tgui_default_state, /datum/ui_state/default, new)

/datum/ui_state/default/can_use_topic(src_object, mob/user)
	return user.tgui_default_can_use_topic(src_object) // Call the individual mob-overridden procs.

/mob/proc/tgui_default_can_use_topic(src_object)
	return UI_CLOSE // Don't allow interaction by default.

/mob/living/tgui_default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. > UI_CLOSE && loc) // must not be in nullspace.
		. = min(., shared_living_ui_distance(src_object)) // Check the distance...

	var/mob/living/carbon/human/H = src
	if(. == UI_INTERACTIVE && !H?.IsAdvancedToolUser(TRUE)) // unhandy living mobs can only look, not touch.
		return UI_UPDATE

/mob/living/silicon/robot/tgui_default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. <= UI_DISABLED)
		return

	// Robots can interact with anything they can see.
	var/list/clientviewlist = getviewsize(client.view)
	if(get_dist(src, src_object) <= min(clientviewlist[1], clientviewlist[2]))
		return UI_INTERACTIVE
	return UI_DISABLED // Otherwise they can keep the UI open.

/mob/living/silicon/ai/tgui_default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. < UI_INTERACTIVE)
		return

	// The AI can interact with anything it can see nearby, or with cameras while wireless control is enabled.
	if(!control_disabled)
		return UI_INTERACTIVE
	return UI_CLOSE

/mob/living/silicon/pai/tgui_default_can_use_topic(src_object)
	// pAIs can only use themselves
	if(src_object == src && !stat)
		return UI_INTERACTIVE
	else
		return min(..(), UI_UPDATE)
