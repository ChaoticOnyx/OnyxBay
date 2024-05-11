/// Preset central command names to chose from for centcom reports.
#define CENTCOM_PRESET "Central Command"
#define SYNDICATE_PRESET "The Syndicate"
#define CUSTOM_PRESET "Custom Command Name"

/// Datum for holding the TGUI window for command reports.
/datum/command_report_menu
	/// The mob using the UI.
	var/mob/ui_user
	var/static/list/preset_names = list(CENTCOM_PRESET, SYNDICATE_PRESET, CUSTOM_PRESET)

/datum/command_report_menu/New(mob/user)
	ui_user = user

/datum/command_report_menu/tgui_state(mob/user)
	return GLOB.admin_state

/datum/command_report_menu/ui_close()
	qdel_self()

/datum/command_report_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CommandReport")
		ui.open()

/datum/command_report_menu/tgui_static_data(mob/user)
	var/list/data = list()
	data["commandNamePresets"] = preset_names
	data["announcerSounds"] = subtypesof(/datum/announce)

	return data

/datum/command_report_menu/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("submit_report")
			var/announce_type = text2path(params["sound"])
			var/text = params["text"]
			var/title = params["title"]
			var/sender = params["sender"]
			var/do_newscast = params["doNewscast"]
			var/print_report = params["printReport"]
			var/announce_contents = params["announceContents"]
			send_announcement(announce_type, text, title, sender, do_newscast, print_report, announce_contents)
			return TRUE

/*
 * The actual proc that sends the priority announcement and reports
 *
 * Uses the variables set by the user on our datum as the arguments for the report.
 */
/datum/command_report_menu/proc/send_announcement(
	announce_type,
	text,
	title,
	sender,
	do_newscast,
	print_report,
	announce_contents,
	client/sending_client
)
	ASSERT(announce_type && text && title)

	if(print_report)
		post_comm_message(title, replacetext(text, "\n", "<br/>"))

	if(announce_contents)
		SSannounce.play_station_announce(announce_type, text, title, sender, null, do_newscast, msg_sanitized = TRUE)
	else
		SSannounce.play_station_announce(
			announce_type,
			"New [title == CENTCOM_PRESET ? GLOB.using_map.company_name : ""] Update available at all communication consoles.",
			sender,
			null,
			do_newscast,
			msg_sanitized = TRUE
		)

	log_admin("[key_name(sending_client)] has created a command report: [text]")
	message_admins("[key_name_admin(sending_client)] has created a command report")
	feedback_add_details("admin_verb", "CCR") // If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#undef CENTCOM_PRESET
#undef SYNDICATE_PRESET
#undef CUSTOM_PRESET
