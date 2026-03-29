// ========== BOMB DEFUSAL - TEAM RADIO ==========

// Bombdefusal headsets bypass the telecomms/subspace system entirely and
// call Broadcast_Message directly so they work on arena z-levels with no relay.

/obj/item/device/radio/headset/bombdefusal

/obj/item/device/radio/headset/bombdefusal/bombdefusal_t
	name = "terrorist radio headset"
	desc = "A radio headset tuned to the terrorist team frequency."
	icon_state = "headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/bombdefusal_t

/obj/item/device/radio/headset/bombdefusal/bombdefusal_ct
	name = "counter-terrorist radio headset"
	desc = "A radio headset tuned to the counter-terrorist team frequency."
	icon_state = "headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/bombdefusal_ct

// Encryption keys - use custom team channels (registered in post_setup)
// Players use :h (department) to talk on team radio
/obj/item/device/encryptionkey/bombdefusal_t
	name = "terrorist encryption key"
	icon_state = "cypherkey"
	channels = list("Terrorists" = 1)

/obj/item/device/encryptionkey/bombdefusal_ct
	name = "counter-terrorist encryption key"
	icon_state = "cypherkey"
	channels = list("Counter-Terrorists" = 1)

// Override talk_into to broadcast directly without telecomms.
// Uses Broadcast_Message with data=null which delivers to ALL registered radios
// (including headsets) on the current z-level, no relay required.
/obj/item/device/radio/headset/bombdefusal/talk_into(mob/living/M, message, channel, verb = "says", datum/language/speaking = null)
	if(!on || !M || !message)
		return 0

	if(wires.IsIndexCut(WIRE_TRANSMIT))
		return 0

	var/datum/frequency/connection = handle_message_mode(M, message, channel)
	if(!istype(connection))
		return 0

	var/turf/position = get_turf(src)
	if(!position)
		return 0

	var/displayname = M.name
	var/real_name = M.real_name
	var/voicemask = 0
	if(ishuman(M) && M.GetVoice() != real_name)
		displayname = M.GetVoice()
		voicemask = 1

	var/jobname = "Unknown"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		jobname = H.get_assignment()

	// data=null hits the "else" branch in Broadcast_Message which includes headsets
	Broadcast_Message(connection, M, voicemask, pick(M.speak_emote),
		src, message, displayname, jobname, real_name, M.voice_name,
		null, 0, list(position.z), connection.frequency,
		verb, speaking, FALSE)
	return 1
