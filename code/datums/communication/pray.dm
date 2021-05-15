/decl/communication_channel/pray
	name = "PRAY"
	expected_communicator_type = /mob
	log_proc = /proc/log_say
	flags = COMMUNICATION_ADMIN_FOLLOW
	mute_setting = MUTE_PRAY

/decl/communication_channel/pray/do_communicate(mob/communicator, message, speech_method_type)
	var/image/cross = image('icons/obj/storage.dmi',"bible")
	for(var/m in GLOB.player_list)
		var/mob/M = m
		if(!M.client)
			continue
		if(M.client.holder && M.client.get_preference_value(/datum/client_preference/staff/show_chat_prayers) == GLOB.PREF_SHOW)
			receive_communication(communicator, M, "\[<A HREF='?_src_=holder;adminspawncookie=\ref[communicator]'>SC</a>\] \[<A HREF='?_src_=holder;take_ic=\ref[src]'>TAKE</a>\]<span class='notice'>\icon[cross] <b><font color=purple>PRAY: </font>[key_name(communicator, 1)]: </b>[message]</span>")
		else if(communicator == M) //Give it to ourselves
			receive_communication(communicator, M, "<span class='notice'>\icon[cross] <b>You send the prayer, \"[message]\" out into the heavens.</b></span>")

/decl/communication_channel/pray/receive_communication(mob/communicator, mob/receiver, message)
	..()
	if(receiver.client.holder && !receiver.client.get_preference_value(/datum/client_preference/staff/govnozvuki) == GLOB.PREF_NO)
		sound_to(receiver, sound('sound/effects/ding.ogg'))
