var/global/ntnrc_uid = 0

/datum/ntnet_conversation/
	var/id = null
	var/title = "Untitled Conversation"
	var/datum/computer_file/program/chatclient/operator // "Administrator" of this channel. Creator starts as channel's operator,
	var/list/messages = list()
	var/list/message_data = list()
	var/list/clients = list()
	var/list/client_admins = list()
	var/list/pda_members = list()
	var/list/pda_admins = list()
	var/password

/datum/ntnet_conversation/New()
	id = ntnrc_uid
	ntnrc_uid++
	if(ntnet_global)
		ntnet_global.chat_channels.Add(src)
	..()

/datum/ntnet_conversation/Destroy()
	ntnet_global.chat_channels.Remove(src)
	return ..()

/datum/ntnet_conversation/proc/add_message(message, username)
	var/time_stamp = stationtime2text()
	var/safe_username = sanitize("[username]")
	var/safe_message = sanitize("[message]")
	messages.Add("[time_stamp] [safe_username]: [safe_message]")
	message_data.Add(list(
		"timestamp" = time_stamp,
		"username" = safe_username,
		"message" = safe_message,
		"status" = 0
	))
	trim_message_list()

/datum/ntnet_conversation/proc/add_status_message(message)
	var/time_stamp = stationtime2text()
	var/safe_message = sanitize("[message]")
	messages.Add("[time_stamp] -!- [safe_message]")
	message_data.Add(list(
		"timestamp" = time_stamp,
		"username" = "-!-",
		"message" = safe_message,
		"status" = 1
	))
	trim_message_list()

/datum/ntnet_conversation/proc/trim_message_list()
	while(messages.len > 50)
		messages.Cut(1, 2)
	while(message_data.len > 50)
		message_data.Cut(1, 2)

/datum/ntnet_conversation/proc/get_member_name(member_ref)
	if(isnull(member_ref))
		return "Unknown user"
	var/obj/item/device/pda/P = locate(member_ref)
	if(!istype(P))
		return "Unknown user"
	if(P.owner)
		return sanitize(P.owner)
	return sanitize("[P]")

/datum/ntnet_conversation/proc/is_pda_member(member_ref)
	return !isnull(member_ref) && (member_ref in pda_members)

/datum/ntnet_conversation/proc/is_pda_admin(member_ref)
	return !isnull(member_ref) && (member_ref in pda_admins)

/datum/ntnet_conversation/proc/add_pda_member(member_ref, actor_ref = null)
	if(isnull(member_ref) || (member_ref in pda_members))
		return FALSE
	pda_members += member_ref
	if(!pda_admins.len)
		pda_admins += member_ref
	if(actor_ref && actor_ref != member_ref)
		add_status_message("[get_member_name(actor_ref)] added [get_member_name(member_ref)] to the channel.")
	else
		add_status_message("[get_member_name(member_ref)] joined the channel.")
	return TRUE

/datum/ntnet_conversation/proc/remove_pda_member(member_ref, actor_ref = null)
	if(isnull(member_ref) || !(member_ref in pda_members))
		return FALSE
	pda_members -= member_ref
	pda_admins -= member_ref
	if(actor_ref && actor_ref != member_ref)
		add_status_message("[get_member_name(actor_ref)] removed [get_member_name(member_ref)] from the channel.")
	else
		add_status_message("[get_member_name(member_ref)] left the channel.")
	if(!pda_admins.len && pda_members.len)
		var/new_admin = pda_members[1]
		pda_admins += new_admin
		add_status_message("[get_member_name(new_admin)] is now a channel admin.")
	return TRUE

/datum/ntnet_conversation/proc/set_pda_admin(member_ref, actor_ref, make_admin = TRUE)
	if(isnull(actor_ref) || !is_pda_admin(actor_ref))
		return FALSE
	if(isnull(member_ref) || !(member_ref in pda_members))
		return FALSE
	if(make_admin)
		if(member_ref in pda_admins)
			return FALSE
		pda_admins += member_ref
		add_status_message("[get_member_name(actor_ref)] granted admin rights to [get_member_name(member_ref)].")
		return TRUE
	if(!(member_ref in pda_admins))
		return FALSE
	if(pda_admins.len <= 1)
		return FALSE
	pda_admins -= member_ref
	add_status_message("[get_member_name(actor_ref)] revoked admin rights from [get_member_name(member_ref)].")
	return TRUE

/datum/ntnet_conversation/proc/is_client_admin(datum/computer_file/program/chatclient/C)
	if(!istype(C))
		return FALSE
	return C == operator || (C in client_admins)

/datum/ntnet_conversation/proc/grant_client_admin(datum/computer_file/program/chatclient/target, datum/computer_file/program/chatclient/actor)
	if(!istype(target) || !(target in clients))
		return FALSE
	if(istype(actor) && !is_client_admin(actor))
		return FALSE
	if(target in client_admins)
		return FALSE
	client_admins += target
	add_status_message("[target.username] has been granted channel admin rights.")
	return TRUE

/datum/ntnet_conversation/proc/revoke_client_admin(datum/computer_file/program/chatclient/target, datum/computer_file/program/chatclient/actor)
	if(!istype(target) || !(target in clients))
		return FALSE
	if(istype(actor) && !is_client_admin(actor))
		return FALSE
	if(target == operator)
		return FALSE
	if(!(target in client_admins))
		return FALSE
	client_admins -= target
	add_status_message("[target.username] channel admin rights revoked.")
	return TRUE

/datum/ntnet_conversation/proc/kick_client(datum/computer_file/program/chatclient/target, datum/computer_file/program/chatclient/actor)
	if(!istype(target) || !(target in clients))
		return FALSE
	if(istype(actor) && !is_client_admin(actor))
		return FALSE
	remove_client(target)
	target.channel = null
	add_status_message("[target.username] was removed from the channel.")
	return TRUE

/datum/ntnet_conversation/proc/add_client(datum/computer_file/program/chatclient/C)
	if(!istype(C))
		return
	if(C in clients)
		return
	clients.Add(C)
	add_status_message("[C.username] has joined the channel.")
	// No operator, so we assume the channel was empty. Assign this user as operator.
	if(!operator)
		changeop(C)

/datum/ntnet_conversation/proc/remove_client(datum/computer_file/program/chatclient/C)
	if(!istype(C) || !(C in clients))
		return
	clients.Remove(C)
	client_admins.Remove(C)
	add_status_message("[C.username] has left the channel.")

	// Channel operator left, pick new operator
	if(C == operator)
		operator = null
		if(clients.len)
			var/datum/computer_file/program/chatclient/newop = null
			for(var/datum/computer_file/program/chatclient/admin in client_admins)
				if(admin in clients)
					newop = admin
					break
			if(!newop)
				newop = pick(clients)
			changeop(newop)


/datum/ntnet_conversation/proc/changeop(datum/computer_file/program/chatclient/newop, datum/computer_file/program/chatclient/actor = null)
	if(!istype(newop) || !(newop in clients))
		return FALSE
	if(istype(actor) && !is_client_admin(actor))
		return FALSE
	operator = newop
	add_status_message("Channel operator status transferred to [newop.username].")
	return TRUE

/datum/ntnet_conversation/proc/change_title(newtitle, datum/computer_file/program/chatclient/client)
	if(operator != client && !is_client_admin(client))
		return 0 // Not Authorised

	add_status_message("[client.username] has changed channel title from [title] to [newtitle]")
	title = newtitle
