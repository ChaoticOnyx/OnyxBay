
/obj/machinery/door/proc/edit_access(mob/user)
	if(!user || !can_edit_access(user))
		return

	if(!req_access || !istype(req_access, /list))
		req_access = list()

	var/text = "<h1>Edit access for [src]</h1><br>Any ID with one or more allowed access type can open this door. "
	text += "If there are no allowed access types, anyone can open the door.<br>"
	text += "<table border=1><tr><td>access type</td><td>allowed</td><td>toggle</td></tr>"
	var/list/accesses = get_all_accesses()

	for(var/access in accesses)
		text += "<tr><td>[get_access_desc(access)]</td>"

		if(access in req_access)
			text += "<td>Yes</td><td><a href='?src=\ref[src];edit_access=[access];remove_access=1'>X</a></td></tr>"

		else
			text += "<td>No</td><td><a href='?src=\ref[src];edit_access=[access]'>X</a></td></tr>"

	usr << browse(text, "window=edit-door-access")


/obj/machinery/door/proc/can_edit_access(mob/user)
	if(user.client && user.client.holder)
		return 1

	else if(istype(user, /mob/living/silicon)) //Might want to change this to AI-only
		return 1

	else
		return 0


/obj/machinery/door/Topic(href, href_list[])
	..()

	if(href_list["edit_access"])
		if(!can_edit_access(usr))
			return

		if(!req_access || !istype(req_access, /list))
			return

		if(href_list["remove_access"])
			req_access -= text2num(href_list["edit_access"])

		else if(!(text2num(href_list["edit_access"]) in req_access))
			req_access += text2num(href_list["edit_access"])

		edit_access(usr)
