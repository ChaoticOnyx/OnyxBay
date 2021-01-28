/obj/item/device/radio/pai
	name = "pAI Radio Configuration"
	shut_up = 1
	canhear_range = 0

/obj/item/device/radio/pai/list_channels(mob/user)
	return list_secure_channels(user)

/obj/item/device/radio/pai/recalculateChannels(mob/user)
	src.channels = list()

	for(var/internal_chan in internal_channels)
		if(internal_chan in src.channels)
			continue

		if(has_channel_access(user, internal_chan))
			var/ch_name = get_frequency_name(text2num(internal_chan))

			src.channels += ch_name
			src.channels[ch_name] += channels[ch_name]

	for (var/ch_name in src.channels)
		if(!radio_controller)
			src.SetName("broken radio")
			return

		secure_radio_connections[ch_name] = radio_controller.add_object(src, radiochannels[ch_name],  RADIO_CHAT)

/obj/item/device/radio/proc/ToggleLoudspeaker()
	shut_up = !shut_up
	if(shut_up)
		canhear_range = 0
	else
		canhear_range = 3

/obj/item/device/radio/pai/Topic(href, href_list)
	if(..())
		return 1
	if (href_list["shutup"]) // Toggle loudspeaker mode, AKA everyone around you hearing your radio.
		var/do_shut_up = text2num(href_list["shutup"])
		if(do_shut_up != shut_up)
			shut_up = !shut_up
			if(shut_up)
				canhear_range = 0
				to_chat(usr, "<span class='notice'>Loadspeaker disabled.</span>")
			else
				canhear_range = 3
				to_chat(usr, "<span class='notice'>Loadspeaker enabled.</span>")
		. = 1

	if(.)
		SSnano.update_uis(src)