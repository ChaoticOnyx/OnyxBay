/datum/nano_module
	var/name
	var/datum/host
	var/available_to_ai = TRUE
	var/datum/topic_manager/topic_manager
	var/list/using_access

/datum/nano_module/New(datum/host, topic_manager)
	..()
	src.host = host.nano_host()
	src.topic_manager = topic_manager

/datum/nano_module/nano_host()
	return host ? host : src

/datum/nano_module/proc/can_still_topic(datum/topic_state/state = GLOB.default_state)
	return CanUseTopic(usr, state) == STATUS_INTERACTIVE

/datum/nano_module/proc/check_eye(mob/user)
	return -1

/datum/nano_module/proc/check_access(mob/user, access)
	if(!access)
		return 1

	if(using_access)
		if(access in using_access)
			return 1
		else
			return 0

	if(!istype(user))
		return 0

	var/obj/item/weapon/card/id/I = user.GetIdCard()
	if(!I)
		return 0

	if(access in I.access)
		return 1

	return 0

/datum/nano_module/Topic(href, href_list)
	if(topic_manager && topic_manager.Topic(href, href_list))
		return TRUE
	. = ..()

/datum/nano_module/proc/get_host_z()
	var/atom/host = nano_host()
	return istype(host) ? get_z(host) : 0

/datum/nano_module/proc/print_text(text, mob/user, title, rawhtml = FALSE)
	var/obj/item/modular_computer/MC = nano_host()
	if(istype(MC))
		if(!MC.nano_printer)
			to_chat(user, "Error: No printer detected. Unable to print document.")
			return

		if(!MC.nano_printer.print_text(text, title, rawhtml))
			to_chat(user, "Error: Printer was unable to print the document. It may be out of paper.")
	else
		to_chat(user, "Error: Unable to detect compatible printer interface. Are you running NTOSv2 compatible system?")

/datum/proc/initial_data()
	return list()

/datum/proc/update_layout()
	return FALSE
