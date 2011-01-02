//
//  Note: If you disable this file, enable "chat_tabs_disabled".
//

/mob/proc/ctab_message(var/tab, var/message)
	if(src.client)
		src.client.ctab_message(tab, message)

/client/proc/ctab_message(var/tab, var/message)
	if(cmptext(tab, "game"))
		src << message
		return

	if(!winexists(src, "ctab_[tab]"))
		winclone(src, "ctab_template", "ctab_[tab]")
		winset(src, "ctab_[tab]", "title=\"[tab]\"")
		winset(src, "ctabs.tabs", "tabs=\"+ctab_[tab]\"")
		if(tab_blocked(tab))
			ctab_message("System", "<b>System: Tab opened: [tab]  (<a href=?tab_action=show;tab_name=[tab]>Show tab's messages in Game</a>)</b>")
		else
			ctab_message("System", "<b>System: Tab opened: [tab]  (<a href=?tab_action=hide;tab_name=[tab]>Hide tab's messages from Game</a>)</b>")

	src << output(message, "ctab_[tab].output")

	if(!tab_blocked(tab))
		src << message

/client/proc/tab_blocked(var/tab)
	for(var/t in src.tab_only)
		if(cmptext(tab, t))
			return 1
	return 0

/client/verb/list_blocked_tabs()
	for(var/t in src.tab_only)
		ctab_message("System", "<b>System: [t] is hidden from Game</b>")

/client/Topic(href,href_list[],hsrc)
	..()
	if(href_list["tab_action"] == "hide")
		if(!tab_blocked(href_list["tab_name"]))
			src.tab_only += href_list["tab_name"]
			ctab_message("System", "<b>System: [href_list["tab_name"]] is no longer copying to Game  (<a href=?tab_action=show;tab_name=[href_list["tab_name"]]>Show tab's messages in Game again</a>)</b>")

	else if(href_list["tab_action"] == "show")
		src.tab_only -= href_list["tab_name"]
		ctab_message("System", "<b>System: [href_list["tab_name"]] is now copying to Game  (<a href=?tab_action=hide;tab_name=[href_list["tab_name"]]>Hide tab's messages from Game again</a>)</b>")
