/datum/configuration_section/mcu
	name = "mcu"

	var/enable
	var/budget_percent
	var/hardcap
	var/power_scale
	var/rad_scale
	var/max_elf_size
	var/tts_cooldown_per_char
	var/signaler_set_cooldown
	var/signaler_send_cooldown
	var/light_cooldown
	var/env_sensor_cooldown
	var/battery_recharge_percent
	var/prize_box_cooldown

/datum/configuration_section/mcu/load_data(list/data)
	CONFIG_LOAD_BOOL(enable, data["enable"])
	CONFIG_LOAD_NUM(budget_percent, data["budget_percent"])
	CONFIG_LOAD_NUM(hardcap, data["hardcap"])
	CONFIG_LOAD_NUM(power_scale, data["power_scale"])
	CONFIG_LOAD_NUM(rad_scale, data["rad_scale"])
	CONFIG_LOAD_NUM(max_elf_size, data["max_elf_size"])
	CONFIG_LOAD_NUM(tts_cooldown_per_char, data["tts_cooldown_per_char"])
	CONFIG_LOAD_NUM(signaler_set_cooldown, data["signaler_set_cooldown"])
	CONFIG_LOAD_NUM(signaler_send_cooldown, data["signaler_send_cooldown"])
	CONFIG_LOAD_NUM(light_cooldown, data["light_cooldown"])
	CONFIG_LOAD_NUM(env_sensor_cooldown, data["env_sensor_cooldown"])
	CONFIG_LOAD_NUM(battery_recharge_percent, data["battery_recharge_percent"])
	CONFIG_LOAD_NUM(prize_box_cooldown, data["prize_box_cooldown"])
