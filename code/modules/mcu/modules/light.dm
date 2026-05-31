/obj/item/mcu_module/light
	name = "light module"
	desc = "A light module"
	icon_state = "light"

/obj/item/mcu_module/light/think()
	ready = TRUE

/obj/item/mcu_module/light/proc/__update_light(hex, brightness)
	set_light(1, brightness / 4, brightness, 2, hex)
	power_usage = brightness ? brightness * 2 : 0

/obj/item/mcu_module/light/__power_off()
	set_light(0)
	power_usage = 0

/obj/item/mcu_module/light/__reset(attached)
	set_next_think(0)
	__power_off()
	ready = TRUE

/obj/item/mcu_module/light/proc/__set_light_function()
	if(!ready)
		return Z_SCRIPT_FUNCTION_ERROR

	var/r = args[1]
	var/g = args[2]
	var/b = args[3]
	var/brightness = args[4]

	var/hex = "#[num2hex(r)][num2hex(g)][num2hex(b)]"

	__update_light(hex, brightness)
	ready = FALSE
	set_next_think(world.time + config.mcu.light_cooldown)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/mcu_module/light/proc/__power_off_function()
	if(!ready)
		return Z_SCRIPT_FUNCTION_ERROR

	__power_off()
	set_next_think(world.time + config.mcu.light_cooldown)

	return Z_SCRIPT_FUNCTION_OK
