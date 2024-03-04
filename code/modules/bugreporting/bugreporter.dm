/proc/report_bug(mob/reporter)
	if(!reporter)
		return

	var/datum/bugreporter/bugreporter = new ()
	if(jobban_isbanned(reporter, "BUGREPORT"))
		to_chat(reporter, SPAN_WARNING("You are banned from using in-game bug report system."))
		return

	bugreporter.tgui_interact(reporter)

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
			if(!isnull(title) && !isnull(text) && !isnull(ckey))
				GLOB.indigo_bot.bug_report_webhook(config.indigo_bot.bug_report_webhook, title, text, ckey)
