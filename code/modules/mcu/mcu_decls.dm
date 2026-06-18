#define SCRIPT_DEFINE(NAME) new /datum/script_define(#NAME, "[NAME]")

GLOBAL_DATUM_INIT(script_mcu_decls, /datum/script_decls/mcu, new)

/datum/script_define/shift_id/get_define_value()
	var/hashed_value = Z_HASH_XXHASH32(0, game_id)
	ASSERT(hashed_value != null)

	return hashed_value

/datum/script_file/array/register_builtins(datum/script/script)
	Z_SCRIPT_REGISTER_BUILTIN_ARRAY(script.id)

/datum/script_file/text/register_builtins(datum/script/script)
	Z_SCRIPT_REGISTER_BUILTIN_TEXT(script.id)

/datum/script_decls/mcu/New()
	. = ..()

	func_decls = list(
		new /datum/script_func_decl(
			"PRINTF",
			nameof(/obj/item/device/mcu.proc/__printf_function),
			list(
				list("name" = "format", "type" = Z_SCRIPT_TYPING_STRING),
				list("name" = "values", "type" = Z_SCRIPT_TYPING_VARARGS | Z_SCRIPT_TYPING_ANY),
			),
			FALSE,
			"Prints formatted message to the debug console.",
		),
		new /datum/script_func_decl(
			"VAR",
			nameof(/obj/item/device/mcu.proc/__var_function),
			list(
				list("name" = "var", "type" = Z_SCRIPT_TYPING_VARARGS | Z_SCRIPT_TYPING_SYMBOL),
			),
			FALSE,
			"Creates a new NULL variable with the specified name.",
		),
		new /datum/script_func_decl(
			"WAIT",
			nameof(/obj/item/device/mcu.proc/__wait_function),
			list(
				list("name" = "time", "type" = Z_SCRIPT_TYPING_INT | Z_SCRIPT_TYPING_FLOAT),
			),
			FALSE,
			"Waits the specified time in ms.",
		),
		new /datum/script_func_decl(
			"RAND_INT",
			nameof(/obj/item/device/mcu.proc/__rand_int_function),
			list(
				list("name" = "lower", "type" = Z_SCRIPT_TYPING_INT | Z_SCRIPT_TYPING_NULL),
				list("name" = "upper", "type" = Z_SCRIPT_TYPING_INT | Z_SCRIPT_TYPING_NULL),
				list("name" = "out", "type" = Z_SCRIPT_TYPING_SYMBOL),
			),
			FALSE,
			"Returns a random int in \[lower, upper).",
		),
		new /datum/script_func_decl(
			"RAND_FLOAT",
			nameof(/obj/item/device/mcu.proc/__rand_float_function),
			list(
				list("name" = "lower", "type" = Z_SCRIPT_TYPING_FLOAT | Z_SCRIPT_TYPING_NULL),
				list("name" = "upper", "type" = Z_SCRIPT_TYPING_FLOAT | Z_SCRIPT_TYPING_NULL),
				list("name" = "out", "type" = Z_SCRIPT_TYPING_SYMBOL),
			),
			FALSE,
			"Returns a random float in \[lower, upper).",
		),
		new /datum/script_func_decl(
			"CALL",
			nameof(/obj/item/device/mcu.proc/__call_function),
			list(
				list("name" = "address", "type" = Z_SCRIPT_TYPING_ADDRESS),
			),
			FALSE,
			"Pushes the return address to the call stack and jumps to the target address.",
		),
		new /datum/script_func_decl(
			"RETURN",
			nameof(/obj/item/device/mcu.proc/__return_function),
			list(),
			FALSE,
			"Pops the return address from the call stack and resumes execution."
		),
		new /datum/script_func_decl(
			"YIELD",
			nameof(/obj/item/device/mcu.proc/__yield_function),
			list(),
			FALSE,
			"Pauses the execution."
		),
	)

	files = list(
		new /datum/script_file(
			"nt/std.b26h",
			"A collection of basic things.",
			list(),
			list(),
			list(
				new /datum/script_define("TRUE", TRUE),
				new /datum/script_define("FALSE", FALSE),
			),
		),
		new /datum/script_file/array(
			"nt/array.b26h",
			"An array object.",
			list(
				new /datum/script_func_decl/builtin(
					"Array_Create",
					list(
						list("name" = "out", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					"Creates a new array instance.",
				),
				new /datum/script_func_decl/builtin(
					"Array_Push",
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "value", "type" = Z_SCRIPT_TYPING_VARARGS | Z_SCRIPT_TYPING_ANY),
					),
					"Pushes a value to the array.",
				),
				new /datum/script_func_decl/builtin(
					"Array_Pop",
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "out", "type" = Z_SCRIPT_TYPING_NULL | Z_SCRIPT_TYPING_ADDRESS),
					),
					"Returns the last element of the array.",
				),
				new /datum/script_func_decl/builtin(
					"Array_At",
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "idx", "type" = Z_SCRIPT_TYPING_INT),
						list("name" = "out", "type" = Z_SCRIPT_TYPING_ADDRESS),
					),
					"Returns an element at the index.",
				),
				new /datum/script_func_decl/builtin(
					"Array_Set",
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "idx", "type" = Z_SCRIPT_TYPING_INT),
						list("name" = "value", "type" = Z_SCRIPT_TYPING_ANY),
					),
					"Modifies a value at the specified index.",
				),
				new /datum/script_func_decl/builtin(
					"Array_Len",
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "out", "type" = Z_SCRIPT_TYPING_ADDRESS),
					),
					"Returns the length of the array.",
				),
				new /datum/script_func_decl/builtin(
					"Array_Remove",
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "idx", "type" = Z_SCRIPT_TYPING_INT),
						list("name" = "out", "type" = Z_SCRIPT_TYPING_NULL | Z_SCRIPT_TYPING_ADDRESS),
					),
					"Removes the element at the index.",
				),
				new /datum/script_func_decl/builtin(
					"Array_Insert",
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "idx", "type" = Z_SCRIPT_TYPING_INT),
						list("name" = "value", "type" = Z_SCRIPT_TYPING_ANY),
					),
					"Insert a value at the index.",
				),
				new /datum/script_func_decl/builtin(
					"Array_Clear",
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
					),
					"Clears the array.",
				),
			),
			list(),
			list(),
		),
		new /datum/script_file/text(
			"nt/text.b26h",
			"A text object.",
			list(
				new /datum/script_func_decl/builtin(
					"Text_Create",
					list(
						list("name" = "out", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					"Creates a text instance.",
				),
				new /datum/script_func_decl/builtin(
					"Text_Append",
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "values", "type" = Z_SCRIPT_TYPING_VARARGS | Z_SCRIPT_TYPING_ANY),
					),
					"Converts to a text and appends the result to the text instance.",
				),
				new /datum/script_func_decl/builtin(
					"Text_StartsWith",
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "value", "type" = Z_SCRIPT_TYPING_STRING | Z_SCRIPT_TYPING_OBJECT),
						list("name" = "out", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					"Tests whether the text starts with a string or not.",
				),
				new /datum/script_func_decl/builtin(
					"Text_EndsWith",
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "value", "type" = Z_SCRIPT_TYPING_STRING | Z_SCRIPT_TYPING_OBJECT),
						list("name" = "out", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					"Tests whether the text ends with a string or not.",
				),
				new /datum/script_func_decl/builtin(
					"Text_Clear",
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
					),
					"Clears the text instance.",
				),
			),
			list(),
			list(),
		),
		new /datum/script_file(
			"nt/meta.b26h",
			"A collection of meta information about the world.",
			list(),
			list(),
			list(
				new /datum/script_define/shift_id("META_SHIFT_ID", null),
			),
		),
		new /datum/script_file(
			"nt/radio.b26h",
			"A collection of constants for radio.",
			list(),
			list(),
			list(
				SCRIPT_DEFINE(RADIO_LOW_FREQ),
				SCRIPT_DEFINE(RADIO_HIGH_FREQ),
				new /datum/script_define("RADIO_PUBLIC_LOW_FREQ", "[PUBLIC_LOW_FREQ]"),
				new /datum/script_define("RADIO_PUBLIC_HIGH_FREQ", "[PUBLIC_HIGH_FREQ]"),
				new /datum/script_define("RADIO_AI_FREQ", "[AI_FREQ]"),
				new /datum/script_define("RADIO_BOT_FREQ", "[BOT_FREQ]"),
				new /datum/script_define("RADIO_ENT_FREQ", "[ENT_FREQ]"),
				new /datum/script_define("RADIO_ERT_FREQ", "[ERT_FREQ]"),
				new /datum/script_define("RADIO_COMM_FREQ", "[COMM_FREQ]"),
				new /datum/script_define("RADIO_PUB_FREQ", "[PUB_FREQ]"),
				new /datum/script_define("RADIO_SEC_FREQ", "[SEC_FREQ]"),
				new /datum/script_define("RADIO_ENG_FREQ", "[ENG_FREQ]"),
				new /datum/script_define("RADIO_MED_FREQ", "[MED_FREQ]"),
				new /datum/script_define("RADIO_SCI_FREQ", "[SCI_FREQ]"),
				new /datum/script_define("RADIO_SUP_FREQ", "[SRV_FREQ]"),
				new /datum/script_define("RADIO_SUP_FREQ", "[SUP_FREQ]"),
				new /datum/script_define("RADIO_MED_I_FREQ", "[MED_I_FREQ]"),
				new /datum/script_define("RADIO_SEC_I_FREQ", "[SEC_I_FREQ]"),
			),
		),
		new /datum/script_file(
			"nt/time.b26h",
			"A collection of API for working with time.",
			list(
				new /datum/script_func_decl(
					"Time_GetElapsedMs",
					nameof(/obj/item/device/mcu.proc/__time_get_elapsed_function),
					list(
						list("name" = "out", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					FALSE,
					"Sets the provided variable with the time elapsed from the start of the programm in ms.",
				),
			),
			list(),
			list(),
		),
		new /datum/script_file(
			"nt/mcu.b26h",
			"A collection of API for a MCU.",
			list(
				new /datum/script_func_decl(
					"MCU_GetTemperature",
					nameof(/obj/item/device/mcu.proc/__get_temperature_function),
					list(
						list("name" = "out", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					FALSE,
					"Sets the provided variable with the current temperature of the board in Kelvin.",
				),
				new /datum/script_func_decl(
					"MCU_IsOverheating",
					nameof(/obj/item/device/mcu.proc/__is_overheating_function),
					list(
						list("name" = "out", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					FALSE,
					"Sets the provided variable with whether the board is currently overheating.",
				),
				new /datum/script_func_decl(
					"MCU_IsThrottled",
					nameof(/obj/item/device/mcu.proc/__is_throttled_function),
					list(
						list("name" = "out", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					FALSE,
					"Sets the provided variable with whether the board is currently throttled.",
				),
				new /datum/script_func_decl(
					"MCU_GetBatteryCharge",
					nameof(/obj/item/device/mcu.proc/__get_battery_charge_function),
					list(
						list("name" = "out", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					FALSE,
					"Sets the provided variable with the current battery charge in mWh.",
				),
				new /datum/script_func_decl(
					"MCU_IsExternalPower",
					nameof(/obj/item/device/mcu.proc/__is_external_power_function),
					list(
						list("name" = "out", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					FALSE,
					"Sets the provided variable with whether the board is connected to an external power source.",
				),
				new /datum/script_func_decl(
					"MCU_SetInterrupts",
					nameof(/obj/item/device/mcu.proc/__set_interrupts_function),
					list(
						list("name" = "state", "type" = Z_SCRIPT_TYPING_INT),
					),
					FALSE,
					"Enables or disables any interrupts.",
				),
			),
			list(),
			list()
		),
		new /datum/script_file(
			"nt/mcu/pci.b26h",
			"API for the PCI.",
			list(
				new /datum/script_func_decl(
					"PCI_GetDeviceCount",
					nameof(/obj/item/device/mcu.proc/__pci_get_device_count_function),
					list(
						list("name" = "outLen", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					FALSE,
					"Sets the provided variable with the count of the connected PCI devices.",
				),
				new /datum/script_func_decl(
					"PCI_GetDevice",
					nameof(/obj/item/device/mcu.proc/__pci_get_device_function),
					list(
						list("name" = "idx", "type" = Z_SCRIPT_TYPING_INT),
						list("name" = "outDevice", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					FALSE,
					"Sets the provided variable with the PCI device on the specified slot.",
				),
				new /datum/script_func_decl(
					"PCI_WaitReady",
					nameof(/obj/item/device/mcu.proc/__pci_wait_ready_function),
					list(
						list("name" = "device", "type" = Z_SCRIPT_TYPING_OBJECT),
					),
					FALSE,
					"Waits for the device.",
				),
				new /datum/script_func_decl(
					"PCI_GetDeviceType",
					nameof(/obj/item/device/mcu.proc/__pci_get_device_type_function),
					list(
						list("name" = "device", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "outType", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					FALSE,
					"Sets the type of the specified device.",
				),
				new /datum/script_func_decl(
					"PCI_IsReady",
					nameof(/obj/item/device/mcu.proc/__is_ready_function),
					list(
						list("name" = "device", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "out", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					FALSE,
					"Checks the ready status of the PCI device.",
				)
			),
			list(),
			list(
				SCRIPT_DEFINE(PCI_DEVICE_TYPE_TTS),
				SCRIPT_DEFINE(PCI_DEVICE_TYPE_LIGHT),
				SCRIPT_DEFINE(PCI_DEVICE_TYPE_GPS),
				SCRIPT_DEFINE(PCI_DEVICE_TYPE_ENV_SENSOR),
				SCRIPT_DEFINE(PCI_DEVICE_TYPE_SIGNALER),
			),
		),
		new /datum/script_file(
			"nt/mcu/tts.b26h",
			"API for the TTS module.",
			list(
				new /datum/script_func_decl(
					"TTS_Speak",
					nameof(/obj/item/mcu_module/tts.proc/__speak_function),
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "language", "type" = Z_SCRIPT_TYPING_INT),
						list("name" = "text", "type" = Z_SCRIPT_TYPING_STRING),
					),
					TRUE,
					"Speaks the specified text in the specified language.",
				),
			),
			list(),
			list(
				SCRIPT_DEFINE(TTS_LANG_GALCOM),
				SCRIPT_DEFINE(TTS_LANG_EAL),
				SCRIPT_DEFINE(TTS_LANG_SOL_COMMON),
				SCRIPT_DEFINE(TTS_LANG_UNATHI),
				SCRIPT_DEFINE(TTS_LANG_SIIK_MAAS),
				SCRIPT_DEFINE(TTS_LANG_SKRELLIAN),
				SCRIPT_DEFINE(TTS_LANG_ROOTLOCAL),
				SCRIPT_DEFINE(TTS_LANG_ROOTGLOBAL),
				SCRIPT_DEFINE(TTS_LANG_LUNAR),
				SCRIPT_DEFINE(TTS_LANG_GUTTER),
				SCRIPT_DEFINE(TTS_LANG_INDEPENDENT),
				SCRIPT_DEFINE(TTS_LANG_SPACER),
				SCRIPT_DEFINE(TTS_LANG_ROBOT),
				SCRIPT_DEFINE(TTS_LANG_DRONE),
			)
		),
		new /datum/script_file(
			"nt/mcu/light.b26h",
			"API for the light module.",
			list(
				new /datum/script_func_decl(
					"Light_PowerOff",
					nameof(/obj/item/mcu_module/light.proc/__power_off_function),
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
					),
					TRUE,
					"Powers off the light.",
				),
				new /datum/script_func_decl(
					"Light_Set",
					nameof(/obj/item/mcu_module/light.proc/__set_light_function),
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "r", "type" = Z_SCRIPT_TYPING_INT),
						list("name" = "g", "type" = Z_SCRIPT_TYPING_INT),
						list("name" = "b", "type" = Z_SCRIPT_TYPING_INT),
						list("name" = "brightness", "type" = Z_SCRIPT_TYPING_INT),
					),
					TRUE,
					"Sets the light to the specified color and brightness."
				)
			),
			list(),
			list(),
		),
		new /datum/script_file(
			"nt/mcu/gps.b26h",
			"API for the GPS module.",
			list(
				new /datum/script_func_decl(
					"GPS_GetPosition",
					nameof(/obj/item/mcu_module/gps.proc/__get_position_function),
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "outX", "type" = Z_SCRIPT_TYPING_SYMBOL),
						list("name" = "outY", "type" = Z_SCRIPT_TYPING_SYMBOL),
						list("name" = "outZ", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					TRUE,
					"Gets the position of the board."
				)
			),
			list(),
			list(),
		),
		new /datum/script_file(
			"nt/mcu/env_sensor.b26h",
			"API for the environment sensor module.",
			list(
				new /datum/script_func_decl(
					"EnvSensor_GetStats",
					nameof(/obj/item/mcu_module/env_sensor.proc/__get_stats_function),
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "outTemperature", "type" = Z_SCRIPT_TYPING_SYMBOL),
						list("name" = "outPressure", "type" = Z_SCRIPT_TYPING_SYMBOL),
						list("name" = "outMoles", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					TRUE,
					"Gets the temperature in Kelvin, pressure in Pa and moles."
				),
				new /datum/script_func_decl(
					"EnvSensor_GetGases",
					nameof(/obj/item/mcu_module/env_sensor.proc/__get_gases_function),
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "outOxygen", "type" = Z_SCRIPT_TYPING_SYMBOL),
						list("name" = "outNitrogen", "type" = Z_SCRIPT_TYPING_SYMBOL),
						list("name" = "outCarbonDioxide", "type" = Z_SCRIPT_TYPING_SYMBOL),
						list("name" = "outHydrogen", "type" = Z_SCRIPT_TYPING_SYMBOL),
						list("name" = "outPlasma", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					TRUE,
					"Gets the moles of the gases.",
				),
				new /datum/script_func_decl(
					"EnvSensor_GetRadiation",
					nameof(/obj/item/mcu_module/env_sensor.proc/__get_radiation_function),
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "rays", "type" = Z_SCRIPT_TYPING_INT),
						list("name" = "outTotalDose", "type" = Z_SCRIPT_TYPING_SYMBOL),
						list("name" = "outTotalActivity", "type" = Z_SCRIPT_TYPING_SYMBOL),
						list("name" = "outTotalEnergy", "type" = Z_SCRIPT_TYPING_SYMBOL),
						list("name" = "outAvgActivity", "type" = Z_SCRIPT_TYPING_SYMBOL),
						list("name" = "outAvgEnergy", "type" = Z_SCRIPT_TYPING_SYMBOL),
					),
					TRUE,
					"Gets the dose (mGy), activity (Ci) and energy (eV) of the specified rays.",
				),
			),
			list(),
			list(
				SCRIPT_DEFINE(ENV_SENSOR_ALPHA_RAYS),
				SCRIPT_DEFINE(ENV_SENSOR_BETA_RAYS),
				SCRIPT_DEFINE(ENV_SENSOR_HAWKING_RAYS),
			),
		),
		new /datum/script_file(
			"nt/mcu/signaler.b26h",
			"API for the signaler module.",
			list(
				new /datum/script_func_decl(
					"Signaler_Send",
					nameof(/obj/item/mcu_module/signaler.proc/__send_function),
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
					),
					TRUE,
					"Send the code on the configured frequency",
				),
				new /datum/script_func_decl(
					"Signaler_SetFrequency",
					nameof(/obj/item/mcu_module/signaler.proc/__set_frequency_function),
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "frequency", "type" = Z_SCRIPT_TYPING_INT),
						list("name" = "code", "type" = Z_SCRIPT_TYPING_INT),
					),
					TRUE,
					"Sets the frequency and the code.",
				),
				new /datum/script_func_decl(
					"Signaler_SetPulseCallback",
					nameof(/obj/item/mcu_module/signaler.proc/__set_pulse_callback_function),
					list(
						list("name" = "this", "type" = Z_SCRIPT_TYPING_OBJECT),
						list("name" = "address", "type" = Z_SCRIPT_TYPING_ADDRESS | Z_SCRIPT_TYPING_NULL),
					),
					TRUE,
					"Sets the callback which will be called on a pulse.",
				),
			),
			list(),
			list(),
		),
	)

#undef SCRIPT_DEFINE
