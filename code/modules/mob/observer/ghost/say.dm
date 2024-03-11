/mob/observer/ghost/say(message)
	for(var/obj/item/device/ghost_gramophone/gg in GLOB.ghost_gramophones)
		if(!gg.active)
			continue

		if(get_dist(gg, src) > world.view)
			continue

		var/message_to_send = stars(message, 85)

		var/list/hearers = get_hearers_in_view(world.view, gg)

		for(var/obj/O in hearers)
			O.show_message(SPAN_DEADSAY("<B>[gg]</B>: [message_to_send]"), AUDIBLE_MESSAGE)

		for(var/mob/M in hearers)
			M.show_message(SPAN_DEADSAY("<B>[gg]</B>: [message_to_send]"), AUDIBLE_MESSAGE)
			if(M.get_preference_value("CHAT_RUNECHAT") == GLOB.PREF_YES)
				M.create_chat_message(gg, message_to_send)

	sanitize_and_communicate(/decl/communication_channel/dsay, client, message)
