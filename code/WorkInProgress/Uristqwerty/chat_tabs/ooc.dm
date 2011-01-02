/mob/verb/listen_ooc()
	set name = "(Un)Mute OOC"

	if (src.client)
		src.client.listen_ooc = !src.client.listen_ooc
		if (src.client.listen_ooc)
			src << "\blue You are now listening to messages on the OOC channel."
		else
			src << "\blue You are no longer listening to messages on the OOC channel."

/mob/verb/ooc(msg as text)
	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return
	else if (!src.client.listen_ooc)
		return
	else if (!ooc_allowed && !src.client.holder)
		return
	else if (src.muted)
		return
	else if (findtext(msg, "byond://") && !src.client.holder)
		src << "<B>Advertising other servers is not allowed.</B>"
		log_admin("[key_name(src)] has attempted to advertise in OOC.")
		message_admins("[key_name_admin(src)] has attempted to advertise in OOC.")
		return

	log_ooc("[src.name]/[src.key] : [msg]")

	for (var/client/C)
		if (src.client.holder && (!src.client.stealth || C.holder))
			C.ctab_message("OOC", "<span class=\"adminooc\"><span class=\"prefix\">OOC:</span> <span class=\"name\">[src.key][src.client.stealth ? "/([src.client.fakekey])" : ""]:</span> <span class=\"message\">[msg]</span></span>")
		else if (C.listen_ooc)
			C.ctab_message("OOC", "<span class=\"ooc\"><span class=\"prefix\">OOC:</span> <span class=\"name\">[src.client.stealth ? src.client.fakekey : src.key]:</span> <span class=\"message\">[msg]</span></span>")
	for(var/mob/C)
		C.log_m("OOC:[msg]")