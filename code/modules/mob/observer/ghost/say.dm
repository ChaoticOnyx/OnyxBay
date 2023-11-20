/mob/observer/ghost/say(message)
	for(var/obj/item/device/ghost_gramophone/gg in GLOB.ghost_gramophones)
		if(!gg.active)
			continue

		if(get_dist(gg, src) > world.view)
			continue

		var/message_to_send = stars(message)
		gg.audible_message(SPAN_DEADSAY("<B>[gg]</B>: [message_to_send]"))

	sanitize_and_communicate(/decl/communication_channel/dsay, client, message)
