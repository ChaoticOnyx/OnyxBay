/mob
	/// Holder for a bugreporter datum.
	var/datum/bugreporter/bugreporter

/mob/Destroy()
	QDEL_NULL(bugreporter)
	return ..()

/proc/report_bug(mob/reporter)
	if(!reporter)
		return

	THROTTLE(cooldown, 1 SECOND)
	if(!cooldown)
		to_chat(usr, SPAN_DANGER("Wait a bit before sending another report!"))
		return

	if(!istype(reporter.bugreporter))
		reporter.bugreporter = new ()

	if(jobban_isbanned(reporter, "BUGREPORT"))
		to_chat(reporter, SPAN_WARNING("You are banned from using in-game bug report system."))
		return

	reporter.bugreporter.tgui_interact(reporter)

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
				return TRUE
				//GLOB.indigo_bot.bug_report_webhook(config.indigo_bot.bug_report_webhook, title, text, ckey)
			return TRUE
