/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * Circumvents the message queue and sends the message
 * to the recipient (target) as soon as possible.
 */
/proc/to_chat_immediate(target, html,
		type = null,
		text = null,
		avoid_highlighting = FALSE,
		// FIXME: These flags are now pointless and have no effect
		handle_whitespace = TRUE,
		trailing_newline = TRUE,
		confidential = FALSE)
	if(!target || (!html && !text))
		return
	if(target == world)
		target = GLOB.clients
	// Build a message
	var/message = list()
	if(type) message["type"] = type
	if(text) message["text"] = text
	if(html) message["html"] = html
	if(avoid_highlighting) message["avoidHighlighting"] = avoid_highlighting
	var/message_blob = TGUI_CREATE_MESSAGE("chat/message", message)
	var/message_html = message_to_html(message)
	if(!confidential)
		SSdemo.write_chat(target, message)
	if(islist(target))
		for(var/_target in target)
			var/client/client = CLIENT_FROM_VAR(_target)
			if(client)
				// Send to tgchat
				client.tgui_panel?.window.send_raw_message(message_blob)
				// Send to old chat
				DIRECT_OUTPUT(client, message_html)
		return
	var/client/client = CLIENT_FROM_VAR(target)
	if(client)
		// Send to tgchat
		client.tgui_panel?.window.send_raw_message(message_blob)
		// Send to old chat
		DIRECT_OUTPUT(client, message_html)

/**
 * Sends the message to the recipient (target).
 *
 * Recommended way to write to_chat calls:
 * ```
 * to_chat(client,
 *     type = MESSAGE_TYPE_INFO,
 *     html = "You have found <strong>[object]</strong>")
 * ```
 */
/proc/to_chat(target, html,
		type,
		text = null,
		avoid_highlighting = FALSE,
		// FIXME: These flags are now pointless and have no effect
		handle_whitespace = TRUE,
		trailing_newline = TRUE,
		confidential = FALSE)
	if(Master.current_runlevel == RUNLEVEL_INIT || !SSchat?.initialized)
		to_chat_immediate(target, html, type, text, confidential)
		return
	if(!target || (!html && !text))
		return
	if(target == world)
		target = GLOB.clients
	// Build a message
	var/message = list()
	// Replace expanded \icon macro with icon2html
	// regex/Replace with a proc won't work here because icon2html takes target as an argument and there is no way to pass it to the replacement proc
	// not even hacks with reassigning usr work
	var/static/regex/i = new(@/<IMG CLASS=icon SRC=(\[[^]]+])(?: ICONSTATE='([^']+)')?>/, "g")
	//'
	if(type) message["type"] = type
	if(text)
		message["text"] = text
	if(html)
		while(i.Find(html))
			html = copytext(html, 1, i.index) + icon2html(locate(i.group[1]), target, icon_state = i.group[2]) + copytext(html, i.next)

		message["html"] = html
	if(avoid_highlighting) message["avoidHighlighting"] = avoid_highlighting
	SSchat.queue(target, message, confidential)
