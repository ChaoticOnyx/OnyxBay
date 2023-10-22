/proc/bxl_init(datum/bxl_settings/settings)
	if(world.system_type == MS_WINDOWS)
		__bxl_lib = "bxl.dll"
	else
		__bxl_lib = "./libbxl.so"

	call_ext(__bxl_lib, "byond:bxl_init")(settings)
	// call_ext(__bxl_lib, "byond:bxl_set_log_callback")(nameof(/proc/bxl_log_callback))

/proc/bxl_log_callback(ty, text)
	if(ty == BXL_LOG_DEBUG)
		log_to_dd("BXL: [text]")
	else if(ty == BXL_LOG_ERROR)
		log_error("BXL: [text]")
	else
		CRASH("Invalid log type: [ty]")
