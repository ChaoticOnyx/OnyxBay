//
//  Note: If you disable this file, enable "chat_tabs_disabled".
//

/mob/proc/ctab_message(var/tab, var/message)
	if(src.client)
		src.client.ctab_message(tab, message)

/client/proc/ctab_message(var/tab, var/message)
	if(!winexists(src, "ctab_[tab]"))
		winclone(src, "outputwindow", "ctab_[tab]")
		winset(src, "ctab_[tab]", "title=\"[tab]\"")
		winset(src, "ctabs.tabs", "tabs=\"+ctab_[tab]\"")
	src << output(message, "ctab_[tab].output")