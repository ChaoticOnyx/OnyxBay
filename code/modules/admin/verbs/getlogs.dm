//This proc allows download of past server logs saved within the data/logs/ folder.
//It works similarly to show-server-log.
/client/proc/getserverlog()
	set name = ".getserverlog"
	set desc = "Fetch logfiles from data/logs"
	set category = null

	var/path = browse_files("data/logs/")
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	to_target(src, run(file(path)))
	to_chat(src, "Attempting to send file, this may take a fair few minutes if the file is very large.", confidential = TRUE)
	return


//Other log stuff put here for the sake of organisation

//Shows today's server log
/datum/admins/proc/view_txt_log()
	set category = "Admin"
	set name = "Show Server Log"
	set desc = "Shows today's server log."

	var/path = "data/logs/[time2text(world.realtime,"YYYY/MM-Month/DD-Day")].log"
	if( fexists(path) )
		to_target(src, run(file(path)))
	else
		to_chat(src, "<font color='red'>Error: view_txt_log(): File not found/Invalid path([path]).</font>", confidential = TRUE)
		return
	feedback_add_details("admin_verb","VTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

//Shows today's attack log
/datum/admins/proc/view_atk_log()
	set category = "Admin"
	set name = "Show Server Attack Log"
	set desc = "Shows today's server attack log."

	var/path = "data/logs/[time2text(world.realtime,"YYYY/MM-Month/DD-Day")] Attack.log"
	if( fexists(path) )
		to_target(src, run(file(path)))
	else
		to_chat(src, "<font color='red'>Error: view_atk_log(): File not found/Invalid path([path]).</font>", confidential = TRUE)
		return
	to_target(usr, run(file(path)))
	feedback_add_details("admin_verb","SSAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return
