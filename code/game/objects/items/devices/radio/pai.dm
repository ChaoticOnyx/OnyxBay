/obj/item/device/radio/pai
	name = "pAI Radio Configuration"

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