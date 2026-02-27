/datum/configuration_section/mcu
	name = "mcu"

	var/enable
	var/hardcap
	var/power_scale
	var/rad_scale
	var/max_elf_size

/datum/configuration_section/mcu/load_data(list/data)
	CONFIG_LOAD_BOOL(enable, data["enable"])
	CONFIG_LOAD_NUM(hardcap, data["hardcap"])
	CONFIG_LOAD_NUM(power_scale, data["power_scale"])
	CONFIG_LOAD_NUM(rad_scale, data["rad_scale"])
	CONFIG_LOAD_NUM(max_elf_size, data["max_elf_size"])
