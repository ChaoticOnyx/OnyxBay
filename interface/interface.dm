//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "Wiki"
	set desc = "Visit the wiki."
	set hidden = 1
	if( config.link.wiki )
		send_link(src, config.link.wiki)
	else
		to_chat(src, "<span class='warning'>The wiki URL is not set in the server configuration.</span>")
	return

/client/verb/rules()
	set name = "Rules"
	set desc = "Show Server Rules."
	set hidden = 1
	if( config.link.rules )
		send_link(src, config.link.rules)
	else
		to_chat(src, "<span class='warning'>The rules URL is not set in the server configuration.</span>")
	return

/client/verb/backstory()
	set name = "Backstory"
	set desc = "Show server Backstory."
	set hidden = 1
	if( config.link.backstory )
		send_link(src, config.link.backstory)
	else
		to_chat(src, "<span class='warning'>The backstory URL is not set in the server configuration.</span>")
	return

/client/verb/forum()
	set name = "Forum"
	set desc = "Visit the forum."
	set hidden = 1
	if( config.link.forum )
		send_link(src, config.link.forum)
	else
		to_chat(src, "<span class='warning'>The forum URL is not set in the server configuration.</span>")
	return

/client/verb/discord()
	set name = "Discord"
	set desc = "Visit the community Discord."
	set hidden = 1
	if( config.link.discord )
		send_link(src, config.link.discord)
	else
		to_chat(src, "<span class='warning'>The Discord URL is not set in the server configuration.</span>")
	return

/client/verb/bugreport()
	set name = "Report Bug"
	set desc = "Create bug report to developers."
	set hidden = 1

	mob?.report_bug() // As per byond documentation verbs are slower than procs, so we execute minimal amount of code here.
