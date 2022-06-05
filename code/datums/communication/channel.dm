#define plain_key_name(A) key_name(A, highlight_special_characters = 0)

/decl/communication_channel
	var/name
	var/config_setting
	var/expected_communicator_type = /datum
	var/flags
	var/log_proc
	var/mute_setting

/*
* Procs for handling sending communication messages
*/
/decl/communication_channel/proc/communicate(datum/communicator, message)
	if(can_communicate(arglist(args)))
		call(log_proc)("[(flags&COMMUNICATION_LOG_CHANNEL_NAME) ? "([name]) " : ""][communicator.communication_identifier()]: [message]")
		return do_communicate(arglist(args))
	return FALSE

/decl/communication_channel/proc/can_communicate(datum/communicator, message)
	if(!message)
		return FALSE

	if(!istype(communicator, expected_communicator_type))
		log_debug("[log_info_line(communicator)] attempted to communicate over the channel [src] but was of an unexpected type.")
		return FALSE

	if(config_setting && !config.misc.vars[config_setting] && !check_rights(R_INVESTIGATE,0,communicator))
		to_chat(communicator, "<span class='danger'>[name] is globally muted.</span>")
		return FALSE

	var/client/C = communicator.get_client()

	if(C && mute_setting && (C.prefs.muted & mute_setting))
		to_chat(communicator, "<span class='danger'>You cannot use [name] (muted).</span>")
		return FALSE

	if(C && (flags & COMMUNICATION_NO_GUESTS) && IsGuestKey(C.key))
		to_chat(communicator, "<span class='danger'>Guests may not use the [name] channel.</span>")
		return FALSE

	return TRUE

/decl/communication_channel/proc/do_communicate(communicator, message)
	return

/decl/communication_channel/proc/get_message_type()
	CAN_BE_REDEFINED(TRUE)
	CRASH("Channel [src] has no message type")

/*
* Procs for handling the reception of communication messages
*/
/decl/communication_channel/proc/receive_communication(datum/communicator, datum/receiver, message)
	if(can_receive_communication(receiver))
		var/has_follow_links = FALSE
		if((flags & COMMUNICATION_ADMIN_FOLLOW))
			var/extra_links = receiver.get_admin_jump_link(communicator,"","\[","\]")
			if(extra_links)
				has_follow_links = TRUE
				message = "[extra_links] [message]"
		if(flags & COMMUNICATION_GHOST_FOLLOW && !has_follow_links)
			var/extra_links = receiver.get_ghost_follow_link(communicator,"","\[","\]")
			if(extra_links)
				message = "[extra_links] [message]"
		do_receive_communication(arglist(args))

/decl/communication_channel/proc/can_receive_communication(datum/receiver)
	return TRUE

/decl/communication_channel/proc/do_receive_communication(datum/communicator, datum/receiver, message)
	to_chat(receiver, message, type = get_message_type())

// Misc. helpers
/datum/proc/communication_identifier()
	return usr ? "[key_name(usr)]" : "[key_name(src)]"

/mob/communication_identifier()
	return usr != src ? "[key_name(usr)]" : "[key_name(src)]"

/proc/sanitize_and_communicate(channel_type, communicator, message)
	message = sanitize(message)
	return communicate(arglist(args))

/proc/communicate(channel_type, communicator, message)
	var/list/channels = decls_repository.get_decls_of_subtype(/decl/communication_channel)
	var/decl/communication_channel/channel = channels[channel_type]

	var/list/new_args = list(communicator, message)
	new_args += args.Copy(4)

	return channel.communicate(arglist(new_args))

#undef plain_key_name
