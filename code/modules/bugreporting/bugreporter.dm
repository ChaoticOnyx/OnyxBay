/mob
	/// Holder for a bugreporter datum.
	var/datum/bugreporter/bugreporter

/mob/Destroy()
	QDEL_NULL(bugreporter)
	return ..()

/mob/proc/report_bug()
	THROTTLE(cooldown, 1 SECOND)
	if(!cooldown)
		to_chat(src, SPAN_DANGER("Wait a bit before sending another report!"))
		return

	if(!istype(bugreporter))
		bugreporter = new ()

	if(jobban_isbanned(src, "BUGREPORT"))
		to_chat(src, SPAN_WARNING("You are banned from using in-game bug report system."))
		return

	bugreporter.tgui_interact(src)

/datum/bugreporter/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/bugreporter/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "BugReporter", "Report a bug")
		ui.open()

/datum/bugreporter/tgui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("sendReport")
			var/title = sanitize(params["title"], max_length = 100)
			var/text = sanitize(params["text"])
			var/ckey = usr.ckey
			THROTTLE(cooldown, 1 SECOND)
			if(!cooldown)
				to_chat(usr, SPAN_DANGER("Wait a bit before sending another report!"))
				return

			if(!isnull(title) && !isnull(text) && !isnull(ckey))
				GLOB.indigo_bot.bug_report_webhook(config.indigo_bot.bug_report_webhook, title, text, ckey)
				to_chat(usr, SPAN_DANGER("Thank you for submitting this bug report!"))
			else
				to_chat(usr, SPAN_DANGER("Something went wrong. Check whether you have filled all input fields correctly."))

			return TRUE
