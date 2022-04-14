/hook/startup/proc/init_fluent()
	if(world.system_type == UNIX)
		GLOB.fluent_dll = "./libfluent_onyx.so"
	else
		GLOB.fluent_dll = "fluent_onyx.dll"

	log_debug("Initializing Fluent-Onyx \"[GLOB.fluent_dll]\".")

	var/res = call(GLOB.fluent_dll, "init")(LOCALIZATION_FOLDER, json_encode(LOCALIZATION_FALLBACKS))

	if(res != "")
		log_debug("Fluent-Onyx initialization failed: [res]")
		CRASH(res)

	log_debug("Fluent-Onyx initialized.")
