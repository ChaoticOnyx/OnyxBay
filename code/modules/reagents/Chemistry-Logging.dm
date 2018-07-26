
/var/list/chemical_reaction_logs = list()

/datum/chemical_reaction/proc/log_it(atom/A)
	var/logstr = "[usr ? key_name(usr) : "EVENT"] mixed [name] ([result]) in \the [A ? A : "ERROR"]"

	chemical_reaction_logs += "\[[time_stamp()]\] [logstr]"

	log_admin(logstr, A, log_is_important)

/client/proc/view_chemical_reaction_logs()
	set name = "Show Chemical Reactions"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/html = ""
	for(var/entry in chemical_reaction_logs)
		html += "[entry]<br>"

	usr << browse(html, "window=chemlogs")
