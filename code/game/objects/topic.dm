/obj/Topic(href, href_list = list(), datum/topic_state/state = GLOB.default_state)
	if((. = ..()))
		return
	if(CanUseTopic(usr, state, href_list) == STATUS_INTERACTIVE)
		CouldUseTopic(usr)
		return OnTopic(usr, href_list, state)
	CouldNotUseTopic(usr)

/obj/proc/OnTopic(mob/user, href_list, datum/topic_state/state)
	return TOPIC_NOACTION

/obj/CanUseTopic(mob/user, datum/topic_state/state, href_list)
	if(user.CanUseObjTopic(src))
		return ..()
	return STATUS_CLOSE

/mob/living/silicon/CanUseObjTopic(obj/O)
	var/id = src.get_id_card()
	if(id && O.check_access(id))
		return TRUE
	to_chat(src, "<span class='danger'>\icon[src]Access Denied!</span>")
	return FALSE

/mob/proc/CanUseObjTopic()
	return TRUE

/obj/proc/CouldUseTopic(mob/user)
	user.AddTopicPrint(src)

/mob/proc/AddTopicPrint(atom/target)
	if(!istype(target))
		return
	target.add_hiddenprint(src)

/mob/living/AddTopicPrint(atom/target)
	if(!istype(target))
		return
	if(Adjacent(target))
		target.add_fingerprint(src)
	else
		target.add_hiddenprint(src)

/mob/living/silicon/ai/AddTopicPrint(atom/target)
	if(!istype(target))
		return
	target.add_hiddenprint(src)

/obj/proc/CouldNotUseTopic(mob/user)
	return
