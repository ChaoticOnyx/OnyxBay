/// See SSmouse_entered comments to understand what the fuck is going on.
/atom/MouseEntered(location, control, params)
	SSmouse_entered.hovers[usr.client] = src

/// Fired whenever this atom is the most recent to be hovered over in the tick.
/// Preferred over MouseEntered if you do not need information such as the position of the mouse.
/// Especially because this is deferred over a tick, do not trust that `client` is not null.
/atom/proc/on_mouse_enter(client/client)
	SHOULD_NOT_SLEEP(TRUE)

	var/mob/user = client?.mob
	if (isnull(user))
		return

	// Screentips
	var/datum/hud/active_hud = user.hud_used
	if(!active_hud)
		return

	var/screentips_enabled = active_hud.screentips_enabled
	if(screentips_enabled == SCREENTIP_PREFERENCE_DISABLED || atom_flags & ATOM_FLAG_NO_SCREENTIPS)
		active_hud.screentip_text.maptext = ""
		return

	active_hud.screentip_text.maptext_y = 10
	var/lmb_rmb_line = ""
	var/ctrl_lmb_ctrl_rmb_line = ""
	var/alt_lmb_alt_rmb_line = ""
	var/shift_lmb_ctrl_shift_lmb_line = ""
	var/extra_lines = 0
	var/extra_context = ""

	if(isliving(user))
		var/obj/item/held_item = user.get_active_item()

		if(atom_flags & ATOM_FLAG_CONTEXTUAL_SCREENTIPS || held_item?.item_flags & ITEM_HAS_CONTEXTUAL_SCREENTIPS)
			var/list/context = list()

			var/contextual_screentip_returns = \
				SEND_SIGNAL(src, SIGNAL_ATOM_REQUESTING_CONTEXT_FROM_ITEM, context, held_item, user) \
				| (held_item && SEND_SIGNAL(held_item, SIGNAL_ITEM_REQUESTING_CONTEXT_FOR_TARGET, context, src, user))

			if(contextual_screentip_returns & CONTEXTUAL_SCREENTIP_SET)
				var/screentip_images = active_hud.screentip_images
				var/lmb_text = build_context(context, SCREENTIP_CONTEXT_LMB, screentip_images)
				var/rmb_text = build_context(context, SCREENTIP_CONTEXT_RMB, screentip_images)

				if(lmb_text != "")
					lmb_rmb_line = lmb_text
					if(rmb_text != "")
						lmb_rmb_line += " | [rmb_text]"
				else if(rmb_text != "")
					lmb_rmb_line = rmb_text

				if(lmb_rmb_line != "")
					lmb_rmb_line += "<br>"
					extra_lines++
				if(SCREENTIP_CONTEXT_CTRL_LMB in context)
					ctrl_lmb_ctrl_rmb_line += build_context(context, SCREENTIP_CONTEXT_CTRL_LMB, screentip_images)

				if(SCREENTIP_CONTEXT_CTRL_RMB in context)
					if(ctrl_lmb_ctrl_rmb_line != "")
						ctrl_lmb_ctrl_rmb_line += " | "
					ctrl_lmb_ctrl_rmb_line += build_context(context, SCREENTIP_CONTEXT_CTRL_RMB, screentip_images)

				if(ctrl_lmb_ctrl_rmb_line != "")
					ctrl_lmb_ctrl_rmb_line += "<br>"
					extra_lines++
				if(SCREENTIP_CONTEXT_ALT_LMB in context)
					alt_lmb_alt_rmb_line += build_context(context, SCREENTIP_CONTEXT_ALT_LMB, screentip_images)
				if(SCREENTIP_CONTEXT_ALT_RMB in context)
					if(alt_lmb_alt_rmb_line != "")
						alt_lmb_alt_rmb_line += " | "
					alt_lmb_alt_rmb_line += build_context(context, SCREENTIP_CONTEXT_ALT_RMB, screentip_images)

				if(alt_lmb_alt_rmb_line != "")
					alt_lmb_alt_rmb_line += "<br>"
					extra_lines++
				if(SCREENTIP_CONTEXT_SHIFT_LMB in context)
					shift_lmb_ctrl_shift_lmb_line += build_context(context, SCREENTIP_CONTEXT_SHIFT_LMB, screentip_images)
				if(SCREENTIP_CONTEXT_CTRL_SHIFT_LMB in context)
					if(shift_lmb_ctrl_shift_lmb_line != "")
						shift_lmb_ctrl_shift_lmb_line += " | "
					shift_lmb_ctrl_shift_lmb_line += build_context(context, SCREENTIP_CONTEXT_CTRL_SHIFT_LMB, screentip_images)

				if(shift_lmb_ctrl_shift_lmb_line != "")
					extra_lines++

				if(extra_lines)
					extra_context = "<br><span class='maptext'>[lmb_rmb_line][ctrl_lmb_ctrl_rmb_line][alt_lmb_alt_rmb_line][shift_lmb_ctrl_shift_lmb_line]</span>"
					//first extra line pushes atom name line up 11px, subsequent lines push it up 9px, this offsets that and keeps the first line in the same place
					active_hud.screentip_text.maptext_y = -1 + (extra_lines - 1) * -9

	var/message = MAPTEXT("<span style='text-align: center;'>[name][extra_context]</span>")

	if(screentips_enabled == SCREENTIP_PREFERENCE_CONTEXT_ONLY && extra_context == "")
		active_hud.screentip_text.maptext = ""
	else
		active_hud.screentip_text.maptext = message
