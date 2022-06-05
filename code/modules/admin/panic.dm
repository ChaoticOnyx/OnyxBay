/client/proc/panicbunker()
	set category = "Server"
	set name = "Toggle Panic Bunker"

	if (!establish_db_connection())
		to_chat(usr, "<span class='adminnotice'>The Database is not connected!</span>")
		return

	if(config.multiaccount.panic_bunker == 0 && config.multiaccount.panic_bunker != initial(config.multiaccount.panic_bunker))
		config.multiaccount.panic_bunker = initial(config.multiaccount.panic_bunker)
		log_and_message_admins("[key_name(usr)] has enabled the Panic Bunker for account age less then [config.multiaccount.panic_bunker]")
		return
	else if(config.multiaccount.panic_bunker == 0 && config.multiaccount.panic_bunker == initial(config.multiaccount.panic_bunker))
		config.multiaccount.panic_bunker = 1
		log_and_message_admins("[key_name(usr)] has enabled the Panic Bunker")
		return
	else if(config.multiaccount.panic_bunker != 0)
		config.multiaccount.panic_bunker = 0
		log_and_message_admins("[key_name(usr)] has disabled the Panic Bunker")
		return
	else
		log_and_message_admins("Something went really wrong with Panic Bunker. Contact devs, please.")
