#define MCU_TTS_COOLDOWN_PER_CHAR (1 SECOND)

/obj/item/mcu_module/tts
	name = "Text-to-Speech Module"
	desc = "A microcontroller unit. This one seems to be a prototype."
	icon = 'icons/obj/assemblies/electronic_components.dmi'
	icon_state = "speaker"

	device_type = Z_DEVICE_TYPE_TTS

/obj/item/mcu_module/tts/__syscall(cmd, ...)
	switch(cmd)
		if(Z_TTS_N2B_CMD_SAY)
			var/text = args[2]
			var/chars = length_char(text)

			var/mob/living/silicon/integrated_circuit/speaker = new(src)
			speaker.name = name
			speaker.say(text)

			QDEL_IN(speaker, 1 SECOND)

			set_next_think(world.time + (chars * MCU_TTS_COOLDOWN_PER_CHAR))

			var/obj/item/device/mcu/M = __host.resolve()
			ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_TTS_B2N_CMD_READY_STATUS, FALSE) == TRUE)
			ASSERT(Z_MACHINE_APPEND_COUNTERS(M.id, 1000, 0))
		
			return TRUE
	
	return FALSE

/obj/item/mcu_module/tts/think()
	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_TTS_B2N_CMD_READY_STATUS, TRUE) == TRUE)

	return

/obj/item/mcu_module/tts/__reset(attached)
	if(!attached)
		set_next_think(0)
		return

	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_TTS_B2N_CMD_READY_STATUS, TRUE) == TRUE)

#undef MCU_TTS_COOLDOWN_PER_CHAR
