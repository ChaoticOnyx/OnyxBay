/obj/item/modular_computer/console/preset/install_default_hardware()
	..()
	processor_unit = new /obj/item/weapon/computer_hardware/processor_unit(src)
	tesla_link = new /obj/item/weapon/computer_hardware/tesla_link(src)
	hard_drive = new /obj/item/weapon/computer_hardware/hard_drive/super(src)
	network_card = new /obj/item/weapon/computer_hardware/network_card/wired(src)

// Engineering
/obj/item/modular_computer/console/preset/engineering/install_default_hardware()
	..()
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/engineering/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/power_monitor(src))
	hard_drive.store_file(new /datum/computer_file/program/supermatter_monitor(src))
	hard_drive.store_file(new /datum/computer_file/program/alarm_monitor(src))
	hard_drive.store_file(new /datum/computer_file/program/atmos_control(src))
	hard_drive.store_file(new /datum/computer_file/program/rcon_console(src))
	hard_drive.store_file(new /datum/computer_file/program/camera_monitor(src))
	hard_drive.store_file(new /datum/computer_file/program/shields_monitor(src))

// Medical
/obj/item/modular_computer/console/preset/medical/install_default_hardware()
	..()
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/medical/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/suit_sensors(src))
	hard_drive.store_file(new /datum/computer_file/program/camera_monitor(src))
	hard_drive.store_file(new /datum/computer_file/program/records(src))
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor(src))
	set_autorun("sensormonitor")

// Research
/obj/item/modular_computer/console/preset/research/install_default_hardware()
	..()
	ai_slot = new /obj/item/weapon/computer_hardware/ai_slot(src)
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/research/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/ntnetmonitor(src))
	hard_drive.store_file(new /datum/computer_file/program/nttransfer(src))
	hard_drive.store_file(new /datum/computer_file/program/chatclient(src))
	hard_drive.store_file(new /datum/computer_file/program/camera_monitor(src))
	hard_drive.store_file(new /datum/computer_file/program/aidiag(src))
	hard_drive.store_file(new /datum/computer_file/program/email_client(src))
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor(src))

// Administrator
/obj/item/modular_computer/console/preset/sysadmin/install_default_hardware()
	..()
	ai_slot = new /obj/item/weapon/computer_hardware/ai_slot(src)
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/sysadmin/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/ntnetmonitor(src))
	hard_drive.store_file(new /datum/computer_file/program/nttransfer(src))
	hard_drive.store_file(new /datum/computer_file/program/chatclient(src))
	hard_drive.store_file(new /datum/computer_file/program/camera_monitor(src))
	hard_drive.store_file(new /datum/computer_file/program/aidiag(src))
	hard_drive.store_file(new /datum/computer_file/program/email_client(src))
	hard_drive.store_file(new /datum/computer_file/program/email_administration(src))
	hard_drive.store_file(new /datum/computer_file/program/records(src))
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor(src))

// Command
/obj/item/modular_computer/console/preset/command/install_default_hardware()
	..()
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)
	card_slot = new /obj/item/weapon/computer_hardware/card_slot(src)

/obj/item/modular_computer/console/preset/command/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/chatclient(src))
	hard_drive.store_file(new /datum/computer_file/program/card_mod(src))
	hard_drive.store_file(new /datum/computer_file/program/comm(src))
	hard_drive.store_file(new /datum/computer_file/program/camera_monitor(src))
	hard_drive.store_file(new /datum/computer_file/program/email_client(src))
	hard_drive.store_file(new /datum/computer_file/program/records(src))
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor(src))
	hard_drive.store_file(new /datum/computer_file/program/docking(src))

// Security
/obj/item/modular_computer/console/preset/security/install_default_hardware()
	..()
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/security/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/camera_monitor(src))
	hard_drive.store_file(new /datum/computer_file/program/digitalwarrant(src))
	hard_drive.store_file(new /datum/computer_file/program/forceauthorization(src))
	hard_drive.store_file(new /datum/computer_file/program/records(src))
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor(src))

// Civilian
/obj/item/modular_computer/console/preset/civilian/install_default_hardware()
	..()
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/civilian/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/chatclient(src))
	hard_drive.store_file(new /datum/computer_file/program/nttransfer(src))
	hard_drive.store_file(new /datum/computer_file/program/newsbrowser(src))
	hard_drive.store_file(new /datum/computer_file/program/camera_monitor(src))
	hard_drive.store_file(new /datum/computer_file/program/email_client(src))
	hard_drive.store_file(new /datum/computer_file/program/supply(src))
	hard_drive.store_file(new /datum/computer_file/program/records(src))
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor(src))

// Offices
/obj/item/modular_computer/console/preset/civilian/professional/install_default_hardware()
	..()
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)

//Dock control
/obj/item/modular_computer/console/preset/dock/install_default_hardware()
	..()
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/dock/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/nttransfer(src))
	hard_drive.store_file(new /datum/computer_file/program/email_client(src))
	hard_drive.store_file(new /datum/computer_file/program/supply(src))
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor(src))
	hard_drive.store_file(new /datum/computer_file/program/docking(src))

// Crew-facing supply ordering computer
/obj/item/modular_computer/console/preset/supply/install_default_hardware()
	..()
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/supply/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/supply())
	set_autorun("supply")

// ERT
/obj/item/modular_computer/console/preset/ert/install_default_hardware()
	..()
	ai_slot = new /obj/item/weapon/computer_hardware/ai_slot(src)
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)
	card_slot = new /obj/item/weapon/computer_hardware/card_slot(src)

/obj/item/modular_computer/console/preset/ert/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/nttransfer(src))
	hard_drive.store_file(new /datum/computer_file/program/camera_monitor/ert(src))
	hard_drive.store_file(new /datum/computer_file/program/alarm_monitor(src))
	hard_drive.store_file(new /datum/computer_file/program/comm(src))
	hard_drive.store_file(new /datum/computer_file/program/aidiag(src))
	hard_drive.store_file(new /datum/computer_file/program/records(src))
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor(src))

// Mercenary
/obj/item/modular_computer/console/preset/mercenary/
	computer_emagged = TRUE

/obj/item/modular_computer/console/preset/mercenary/install_default_hardware()
	..()
	ai_slot = new /obj/item/weapon/computer_hardware/ai_slot(src)
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)
	card_slot = new /obj/item/weapon/computer_hardware/card_slot(src)

/obj/item/modular_computer/console/preset/mercenary/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/camera_monitor/hacked(src))
	hard_drive.store_file(new /datum/computer_file/program/alarm_monitor(src))
	hard_drive.store_file(new /datum/computer_file/program/aidiag(src))

// Merchant
/obj/item/modular_computer/console/preset/merchant/install_default_hardware()
	..()
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/merchant/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/merchant(src))
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor(src))

// Library
/obj/item/modular_computer/console/preset/library/install_default_hardware()
	..()
	nano_printer = new /obj/item/weapon/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/library/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/nttransfer(src))
	hard_drive.store_file(new /datum/computer_file/program/newsbrowser(src))
	hard_drive.store_file(new /datum/computer_file/program/email_client(src))
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor(src))
	hard_drive.store_file(new /datum/computer_file/program/library(src))
	hard_drive.store_file(new /datum/computer_file/program/wiki(src))
