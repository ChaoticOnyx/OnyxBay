// Some premade papers lies here.

/obj/item/weapon/paper/eng_wires
	name = "Airlock Wires"

/obj/item/weapon/paper/eng_wires/Initialize()
	. = ..()
	var/list/airlock_wires = same_wires[/obj/machinery/door/airlock].Copy()

	var/message = ""
	message += "\[center]\[large]There is some information about standart airlock wires:\[/large]"

	var/list/wire_to_wire_purpose_list = list(
		num2text(AIRLOCK_WIRE_DOOR_BOLTS) = "Door bolts wire",
		num2text(AIRLOCK_WIRE_IDSCAN) = "ID scan wire",
		num2text(AIRLOCK_WIRE_MAIN_POWER1) = "First Power wire",
		num2text(AIRLOCK_WIRE_MAIN_POWER2) = "Second Power wire",
		num2text(AIRLOCK_WIRE_BACKUP_POWER1) = "First Backup Power wire",
		num2text(AIRLOCK_WIRE_BACKUP_POWER2) = "Second Backup Power wire",
		num2text(AIRLOCK_WIRE_OPEN_DOOR) = "Open door wire",
		num2text(AIRLOCK_WIRE_AI_CONTROL) = "AI control wire",
		num2text(AIRLOCK_WIRE_ELECTRIFY) = "Electrify door wire",
		num2text(AIRLOCK_WIRE_SAFETY) = "Door safety mechanism power wire",
		num2text(AIRLOCK_WIRE_SPEED) = "Door timing mechanism power wire",
		num2text(AIRLOCK_WIRE_LIGHT) = "Door bolt lights power wire"
		)

	for(var/wire_color in airlock_wires)
		var/airlock_num = airlock_wires[wire_color]
		message += "\[br]\[i][wire_color]\[/i] - [wire_to_wire_purpose_list[num2text(airlock_num)]]"
	message += "\[/center]"
	set_content(message)
	make_readonly()
