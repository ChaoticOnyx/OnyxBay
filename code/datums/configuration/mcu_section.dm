/datum/configuration_section/mcu
	name = "mcu"

	var/enable
	var/hardcap
	var/power_scale
	var/rad_scale
	var/max_elf_size
	var/tts_cooldown_per_char
	var/signaler_send_cooldown

/datum/configuration_section/mcu/load_data(list/data)
	CONFIG_LOAD_BOOL(enable, data["enable"])
	CONFIG_LOAD_NUM(hardcap, data["hardcap"])
	CONFIG_LOAD_NUM(power_scale, data["power_scale"])
	CONFIG_LOAD_NUM(rad_scale, data["rad_scale"])
	CONFIG_LOAD_NUM(max_elf_size, data["max_elf_size"])
	CONFIG_LOAD_NUM(tts_cooldown_per_char, data["tts_cooldown_per_char"])
	CONFIG_LOAD_NUM(signaler_send_cooldown, data["signaler_send_cooldown"])
