/mob/living/tts
	name = "text-to-speech module"

/obj/item/mcu_module/tts
	name = "text-to-speech module"
	desc = "A text-to-speech module, may synthesize speech in many languages."
	icon_state = "tts"

	device_type = Z_DEVICE_TYPE_TTS

	var/mob/living/tts/__speaker = null

/obj/item/mcu_module/tts/Initialize()
	. = ..()
	
	__speaker = new(src)

/obj/item/mcu_module/tts/Destroy()
	if(!QDELETED(__speaker))
		qdel(__speaker)

	. = ..()

/obj/item/mcu_module/tts/__syscall(cmd, ...)
	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_APPEND_COUNTERS(M.id, 0, 1000, 0))

	switch(cmd)
		if(Z_TTS_N2B_CMD_SAY)
			var/text = args[2]
			var/datum/language/language = null

			switch(args[3])
				if(0)
					language = all_languages[LANGUAGE_GALCOM]
				if(1)
					language = all_languages[LANGUAGE_EAL]
				if(2)
					language = all_languages[LANGUAGE_SOL_COMMON]
				if(3)
					language = all_languages[LANGUAGE_UNATHI]
				if(4)
					language = all_languages[LANGUAGE_SIIK_MAAS]
				if(5)
					language = all_languages[LANGUAGE_SKRELLIAN]
				if(6)
					language = all_languages[LANGUAGE_ROOTLOCAL]
				if(7)
					language = all_languages[LANGUAGE_ROOTGLOBAL]
				if(8)
					language = all_languages[LANGUAGE_LUNAR]
				if(9)
					language = all_languages[LANGUAGE_GUTTER]
				if(10)
					language = all_languages[LANGUAGE_INDEPENDENT]
				if(11)
					language = all_languages[LANGUAGE_SPACER]
				if(12)
					language = all_languages[LANGUAGE_ROBOT]
				if(13)
					language = all_languages[LANGUAGE_DRONE]
				else
					return FALSE

			var/chars = length_char(text)

			__speaker.name = name
			__speaker.say(text, language)

			set_next_think(world.time + (chars * config.mcu.tts_cooldown_per_char))
			ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_TTS_B2N_CMD_READY_STATUS, FALSE) == TRUE)
		
			return TRUE
	
	return FALSE

/obj/item/mcu_module/tts/think()
	var/obj/item/device/mcu/M = __host.resolve()

	if(QDELETED(M))
		return

	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_TTS_B2N_CMD_READY_STATUS, TRUE) == TRUE)

	return

/obj/item/mcu_module/tts/__reset(attached)
	set_next_think(0)

	if(!attached)
		return

	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_TTS_B2N_CMD_READY_STATUS, TRUE) == TRUE)
