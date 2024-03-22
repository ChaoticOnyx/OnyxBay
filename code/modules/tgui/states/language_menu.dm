/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui state: language_menu_state
 */

GLOBAL_DATUM_INIT(language_menu_state, /datum/ui_state/language_menu, new)

/datum/ui_state/language_menu/can_use_topic(src_object, mob/user)
	. = UI_CLOSE
	if(check_rights(R_ADMIN, FALSE, user.client))
		. = UI_INTERACTIVE
	else if(istype(src_object, /datum/language_menu))
		var/datum/language_menu/lang_menu = src_object
		if(lang_menu.owner == user)
			. = UI_INTERACTIVE
