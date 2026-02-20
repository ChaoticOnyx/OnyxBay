/**
 * Creates a TGUI window for editing pencode text with HTML preview from /proc/pencode2html.
 * Returns user's response as text | null.
 *
 * Arguments:
 * * user - The user to show the editor to.
 * * message - Body text.
 * * title - Window title.
 * * default - Initial text (multiline, with \n).
 * * max_length - Max length for sanitize/validation.
 * * is_handwritten - Pass-through to pencode2html.
 * * timeout - Auto-close after timeout ticks (0 = no timeout).
 */
/proc/tgui_input_pencode_editor(mob/user, message, title = "Pencode Editor", default = "", max_length = MAX_MESSAGE_LEN, is_handwritten = FALSE, timeout = 0)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return null

	// Client does NOT have tgui_input on: fallback to regular input
	if(user.get_preference_value(/datum/client_preference/tgui_input) != GLOB.PREF_YES)
		return input(user, message, title, default) as message|null

	var/datum/tgui_input_pencode_editor/editor = new(user, message, title, default, max_length, is_handwritten, timeout)
	editor.ui_interact(user)
	editor.wait()
	if (editor)
		. = editor.entry
		qdel(editor)

/**
 * # tgui_input_pencode_editor
 */
/datum/tgui_input_pencode_editor
	var/closed
	var/default
	var/entry
	var/max_length
	var/max_fields = 50
	var/message
	var/title
	var/is_handwritten

	var/current_text
	var/preview_html

	var/error_message

	var/start_time
	var/timeout


/datum/tgui_input_pencode_editor/New(mob/user, message, title, default, max_length = MAX_MESSAGE_LEN, is_handwritten, timeout)
	src.default = istext(default) ? default : ""
	src.current_text = src.default
	src.max_length = max_length
	src.message = message
	src.title = title
	src.is_handwritten = is_handwritten

	src.preview_html = pencode2html(src.current_text, src.is_handwritten)

	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)


/datum/tgui_input_pencode_editor/Destroy(force, ...)
	SStgui.close_uis(src)
	return ..()


/datum/tgui_input_pencode_editor/proc/wait()
	while (!entry && !closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_input_pencode_editor/ui_interact(mob/user, datum/tgui/ui)
	src.tgui_interact(user, ui)

/datum/tgui_input_pencode_editor/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PencodeEditorModal")
		ui.open()
		ui.set_autoupdate(TRUE)


/datum/tgui_input_pencode_editor/ui_close(mob/user)
	. = ..()
	closed = TRUE


/datum/tgui_input_pencode_editor/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/tgui_input_pencode_editor/tgui_static_data(mob/user)
	var/list/data = list()
	data["title"] = title
	data["message"] = message
	data["init_value"] = default
	data["max_length"] = max_length
	data["max_fields"] = max_fields
	return data


/datum/tgui_input_pencode_editor/tgui_data(mob/user)
	var/list/data = list()

	// live
	data["value"] = current_text
	data["preview_html"] = preview_html
	data["length"] = length_char(current_text)
	data["error_message"] = error_message

	// field_count
	var/laststart = 1
	var/fields = 0
	while(TRUE)
		var/i = findtext_char(current_text, "\[field\]", laststart)
		if(i == 0)
			break
		laststart = i + 1
		fields++
	data["field_count"] = fields

	if(timeout)
		data["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))

	return data


/datum/tgui_input_pencode_editor/proc/_handle_update_text(t)
	error_message = null

	if(length_char(t) > max_length)
		t = copytext_char(t, 1, max_length + 1)

	current_text = t
	preview_html = pencode2html(current_text, is_handwritten)
	SStgui.update_uis(src)
	return TRUE


/datum/tgui_input_pencode_editor/proc/_handle_submit_text(t)
	if(length_char(t) > max_length)
		error_message = "Text is too long."
		return TRUE

	var/laststart = 1
	var/fields = 0
	while(TRUE)
		var/i = findtext_char(t, "\[field\]", laststart)
		if(i == 0)
			break
		laststart = i + 1
		fields++

	if(fields > max_fields)
		error_message = "Too many fields."
		return TRUE

	set_entry(t)
	closed = TRUE
	SStgui.close_uis(src)
	return TRUE



/datum/tgui_input_pencode_editor/tgui_act(action, list/params)
	. = ..()
	if (.)
		return

	// ----------------------------
	// Non-chunked fallback
	// ----------------------------
	switch(action)
		if("update")
			var/t = params["text"]
			if(!istext(t))
				return TRUE
			return _handle_update_text(t)

		if("submit")
			var/t = params["text"]
			if(!istext(t))
				return TRUE
			return _handle_submit_text(t)

		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

	return TRUE


/datum/tgui_input_pencode_editor/proc/set_entry(t)
	entry = t
