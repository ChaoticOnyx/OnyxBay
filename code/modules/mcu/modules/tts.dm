/obj/item/mcu_module/tts
	name = "Text-to-Speech Module"
	desc = "A microcontroller unit. This one seems to be a prototype."
	icon = 'icons/obj/mcu.dmi'
	icon_state = "tts"

	device_type = Z_DEVICE_TYPE_TTS

	var/mob/living/silicon/integrated_circuit/__speaker = null

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
			var/chars = length_char(text)

			__speaker.name = name
			__speaker.say(text)

			set_next_think(world.time + (chars * config.mcu.tts_cooldown_per_char))
			ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_TTS_B2N_CMD_READY_STATUS, FALSE) == TRUE)
		
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
