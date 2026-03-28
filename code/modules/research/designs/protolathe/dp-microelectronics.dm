/datum/design/item/mcu
	category_items = list("Microelectronics")

/datum/design/item/mcu/standard
	name = "NCR-1000 MCU"
	id = "mcu_standard"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 2, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 200)
	build_path = /obj/item/device/mcu/standard
	sort_string = "VABAA"

/datum/design/item/mcu/standard/upgraded
	name = "NCR-2000 MCU"
	id = "mcu_standard_upgraded"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 3, TECH_MATERIAL = 3)
	materials = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 500, MATERIAL_SILVER = 200)
	build_path = /obj/item/device/mcu/standard/upgraded
	sort_string = "VABAB"

/datum/design/item/mcu/standard/pro
	name = "NCR-4000 Pro"
	id = "mcu_standard_pro"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 4, TECH_DATA = 2)
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 1000, MATERIAL_GOLD = 500)
	build_path = /obj/item/device/mcu/standard/pro
	sort_string = "VABAC"

/datum/design/item/mcu/lowpower
	name = "Whisper-LP8"
	id = "mcu_lowpower"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 2, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 300, MATERIAL_GLASS = 150)
	build_path = /obj/item/device/mcu/lowpower
	sort_string = "VABAD"

/datum/design/item/mcu/lowpower/plus
	name = "Whisper-LP16"
	id = "mcu_lowpower_plus"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 3, TECH_MATERIAL = 3)
	materials = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 250, MATERIAL_SILVER = 100)
	build_path = /obj/item/device/mcu/lowpower/plus
	sort_string = "VABAE"

/datum/design/item/mcu/lowpower/industrial
	name = "Whisper-LP32i"
	id = "mcu_lowpower_industrial"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 4)
	materials = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 500, MATERIAL_SILVER = 200)
	build_path = /obj/item/device/mcu/lowpower/industrial
	sort_string = "VABAF"

/datum/design/item/mcu/overclock/lite
	name = "Fury-S1 Starter"
	id = "mcu_overclock_lite"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 3, TECH_MATERIAL = 3, TECH_DATA = 2)
	materials = list(MATERIAL_STEEL = 1100, MATERIAL_GLASS = 500, MATERIAL_GOLD = 200)
	build_path = /obj/item/device/mcu/overclock/lite
	sort_string = "VABAG"

/datum/design/item/mcu/overclock
	name = "Fury-X1"
	id = "mcu_overclock"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 4, TECH_DATA = 3)
	materials = list(MATERIAL_STEEL = 1500, MATERIAL_GLASS = 750, MATERIAL_GOLD = 300, MATERIAL_DIAMOND = 100)
	build_path = /obj/item/device/mcu/overclock
	sort_string = "VABAG"

/datum/design/item/mcu/overclock/extreme
	name = "Fury-X2 Extreme"
	id = "mcu_overclock_extreme"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 5, TECH_MATERIAL = 5, TECH_DATA = 4, TECH_BLUESPACE = 2)
	materials = list(MATERIAL_STEEL = 3000, MATERIAL_GLASS = 1500, MATERIAL_GOLD = 600, MATERIAL_DIAMOND = 300, MATERIAL_PLASMA = 200)
	build_path = /obj/item/device/mcu/overclock/extreme
	sort_string = "VABAH"

/datum/design/item/mcu/flex
	name = "Flex-V1"
	id = "mcu_flex"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 3, TECH_MATERIAL = 3)
	materials = list(MATERIAL_STEEL = 800, MATERIAL_GLASS = 400, MATERIAL_SILVER = 150)
	build_path = /obj/item/device/mcu/flex
	sort_string = "VABAI"

/datum/design/item/mcu/flex/pro
	name = "Flex-V2 Pro"
	id = "mcu_flex_pro"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 4, TECH_DATA = 2)
	materials = list(MATERIAL_STEEL = 1200, MATERIAL_GLASS = 600, MATERIAL_SILVER = 300, MATERIAL_GOLD = 150)
	build_path = /obj/item/device/mcu/flex/pro
	sort_string = "VABAJ"

/datum/design/item/mcu/flex/max
	name = "Flex-V3 Max"
	id = "mcu_flex_max"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 5, TECH_MATERIAL = 5, TECH_DATA = 3)
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 1000, MATERIAL_SILVER = 500, MATERIAL_GOLD = 250)
	build_path = /obj/item/device/mcu/flex/max
	sort_string = "VABAK"

/datum/design/item/mcu/hardened
	name = "Aegis-H1 Hardened MCU"
	id = "mcu_hardened"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 5, TECH_BLUESPACE = 2)
	materials = list(MATERIAL_STEEL = 2500, MATERIAL_GLASS = 1250, MATERIAL_GOLD = 500, MATERIAL_DIAMOND = 200)
	build_path = /obj/item/device/mcu/hardened
	sort_string = "VABAL"

/datum/design/item/mcu/legacy
	name = "RetroTech Z80-NT"
	id = "mcu_legacy"
	build_type = IMPRINTER
	req_tech = list(TECH_ENGINEERING = 1, TECH_MATERIAL = 1)
	materials = list(MATERIAL_STEEL = 200, MATERIAL_GLASS = 100)
	build_path = /obj/item/device/mcu/legacy
	sort_string = "VABAM"

// Tools

/datum/design/item/mcu/jtag_programmer
	name = "JTAG Programmer"
	id = "jtag_programmer"
	build_type = PROTOLATHE
	req_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	materials = list(MATERIAL_STEEL = 300, MATERIAL_GLASS = 100)
	build_path = /obj/item/jtag_programmer
	sort_string = "VABBA"

/datum/design/item/mcu/mcu_debugger
	name = "Debugger Probe"
	id = "mcu_debugger"
	build_type = PROTOLATHE
	req_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 2)
	materials = list(MATERIAL_STEEL = 300)
	build_path = /obj/item/debugger
	sort_string = "VABCA"

// Modules

/datum/design/item/mcu/tts_module
	name = "Text-to-Speech Module"
	id = "tts_module"
	build_type = PROTOLATHE
	req_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 2, TECH_BIO = 2)
	materials = list(MATERIAL_STEEL = 200, MATERIAL_GLASS = 100)
	build_path = /obj/item/mcu_module/tts
	sort_string = "VABCA"

/datum/design/item/mcu/serial_terminal_module
	name = "Serial Terminal module"
	id = "serial_terminal_module"
	build_type = PROTOLATHE
	req_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	materials = list(MATERIAL_STEEL = 200, MATERIAL_GLASS = 100)
	build_path = /obj/item/mcu_module/serial_terminal
	sort_string = "VABCA"

/datum/design/item/mcu/signaler_module
	name = "Signaler module"
	id = "signaler_module"
	build_type = PROTOLATHE
	req_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	materials = list(MATERIAL_STEEL = 500)
	build_path = /obj/item/mcu_module/signaler
	sort_string = "VABCA"

/datum/design/item/mcu/gps_module
	name = "GPS module"
	id = "gps_module"
	build_type = PROTOLATHE
	req_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2, TECH_MAGNET = 1)
	materials = list(MATERIAL_STEEL = 200)
	build_path = /obj/item/mcu_module/gps
	sort_string = "VABCA"

/datum/design/item/mcu/light_module
	name = "Light module"
	id = "light_module"
	build_type = PROTOLATHE
	req_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 2)
	materials = list(MATERIAL_STEEL = 200)
	build_path = /obj/item/mcu_module/light
	sort_string = "VABCA"

/datum/design/item/mcu/env_sensor_module
	name = "Environment Sensor module"
	id = "env_sensor_module"
	build_type = PROTOLATHE
	req_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 4, TECH_BIO = 2)
	materials = list(MATERIAL_STEEL = 800, MATERIAL_GLASS = 100)
	build_path = /obj/item/mcu_module/env_sensor
	sort_string = "VABCA"
