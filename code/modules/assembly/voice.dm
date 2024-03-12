/obj/item/device/assembly/voice
	name = "voice analyzer"
	desc = "A small electronic device able to record a voice sample, and send a signal when that sample is repeated."
	icon_state = "voice"
	origin_tech = list(TECH_MAGNET = 1)
	matter = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 50, MATERIAL_WASTE = 10)
	var/listening = FALSE
	var/recorded	//the activation message
	drop_sound = SFX_DROP_COMPONENT
	pickup_sound = SFX_PICKUP_COMPONENT

/obj/item/device/assembly/voice/hear_say(message, verb, datum/language/language, alt_name, italics, mob/speaker, sound/speech_sound, sound_vol)
	if(cooldown > 0)
		return

	if(listening)
		recorded = message
		listening = FALSE
		var/turf/T = get_turf(src)	//otherwise it won't work in hand
		T.visible_message("\icon[src] beeps, \"Activation message is '[recorded]'.\"")
	else
		if(findtext(message, recorded))
			pulse(0)
			cooldown = 2
			addtimer(CALLBACK(src, nameof(.proc/process_cooldown)), 1 SECOND)

/obj/item/device/assembly/voice/activate()
	if(!..())
		return FALSE
	listening = !listening
	var/turf/T = get_turf(src)
	T.visible_message("\icon[src] beeps, \"[listening ? "Now" : "No longer"] recording input.\"")
	return TRUE


/obj/item/device/assembly/voice/attack_self(mob/user)
	if(!user)
		return 0
	activate()
	return 1


/obj/item/device/assembly/voice/toggle_secure()
	. = ..()
	listening = FALSE
