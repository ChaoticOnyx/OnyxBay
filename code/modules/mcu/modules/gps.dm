/obj/item/mcu_module/gps
	name = "GPS module"
	desc = "A GPS module"
	icon_state = "gps"

/obj/item/mcu_module/gps/proc/__get_position_function()
	var/obj/item/device/mcu/M = __host.resolve()
	var/turf/T = get_turf(M)

	M.__script.set_var(args[1], T.x, Z_SCRIPT_VAR_CAST_INT)
	M.__script.set_var(args[2], T.y, Z_SCRIPT_VAR_CAST_INT)
	M.__script.set_var(args[3], T.z, Z_SCRIPT_VAR_CAST_INT)

	return Z_SCRIPT_FUNCTION_OK
