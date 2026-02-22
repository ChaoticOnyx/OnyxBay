/mob/observer/ghost/say(message)
	for(var/obj/item/device/ghost_gramophone/gg in GLOB.ghost_gramophones)
		if(!gg.active)
			continue

		if(get_dist(gg, src) > world.view)
			continue

		var/message_to_send = stars(message, 85)

		var/list/hearing_mobs = list()
		var/list/hearing_objs = list()
		get_mobs_and_objs_in_view_fast(get_turf(gg), world.view, hearing_mobs, hearing_objs, checkghosts = null)

		for(var/o in hearing_objs)
			var/obj/O = o
			O.show_message(SPAN_DEADSAY("<B>[gg]</B>: [message_to_send]"), AUDIBLE_MESSAGE)

		for(var/m in hearing_mobs)
			var/mob/M = m
			M.show_message(SPAN_DEADSAY("<B>[gg]</B>: [message_to_send]"), AUDIBLE_MESSAGE)
			if(!M.client)
				continue
			if(M.get_preference_value("CHAT_RUNECHAT") == GLOB.PREF_YES)
				M.create_chat_message(gg, message_to_send)

	sanitize_and_communicate(/decl/communication_channel/dsay, client, message)
