/mob/verb/adminhelp(msg as text)
	set category = "Commands"
	set name = "adminhelp"

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	if (usr.muted)
		return

	for (var/client/C)
		if (C.holder)
			C.ctab_message("Admin", "\blue <b><font color=red>HELP: </font>[key_name(src, C.mob)](<A HREF='?src=\ref[C.holder];adminplayeropts=\ref[src]'>X</A>):</b> [msg]")
	send2adminirc("#bs12admin","HELP: [key_name(src)]: [msg]")
	usr << "Your message has been broadcast to administrators."
	log_admin("HELP: [key_name(src)]: [msg]")
